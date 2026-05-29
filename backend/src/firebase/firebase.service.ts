import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private firebaseApp: admin.app.App | null = null;
  private bypassFirebase = false;

  constructor(private configService: ConfigService) {
    this.bypassFirebase = this.configService.get<string>('BYPASS_FIREBASE') === 'true';
  }

  onModuleInit() {
    if (this.bypassFirebase) {
      this.logger.warn('Firebase Authentication is bypassed. Running in offline/bypass mode.');
      return;
    }

    try {
      const serviceAccountPath = this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT_PATH');
      const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
      const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
      const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');

      if (serviceAccountPath) {
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.cert(serviceAccountPath),
        });
        this.logger.log('Firebase Admin SDK initialized using service account JSON path.');
      } else if (projectId && clientEmail && privateKey) {
        // Format private key (replace escaped newlines if any)
        const formattedPrivateKey = privateKey.replace(/\\n/g, '\n');
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey: formattedPrivateKey,
          }),
        });
        this.logger.log('Firebase Admin SDK initialized using inline environment credentials.');
      } else {
        this.logger.warn(
          'No Firebase credentials provided. Falling back to BYPASS mode automatically.',
        );
        this.bypassFirebase = true;
      }
    } catch (error) {
      this.logger.error('Failed to initialize Firebase Admin SDK. Falling back to BYPASS mode.', error);
      this.bypassFirebase = true;
    }
  }

  async verifyToken(token: string): Promise<any> {
    if (this.bypassFirebase) {
      // Allow testing with custom bypass tokens or mock credentials
      if (token === 'admin_token') {
        return {
          uid: 'admin-firebase-uid',
          email: 'admin@gmail.com',
          name: 'Admin Pahawang',
          picture: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
        };
      }

      // If token is a JWT, decode the payload without verifying signature (since we are in bypass mode)
      const parts = token.split('.');
      if (parts.length === 3) {
        try {
          const payloadJson = Buffer.from(parts[1], 'base64').toString('utf8');
          const decoded = JSON.parse(payloadJson);
          if (decoded && (decoded.user_id || decoded.sub || decoded.uid)) {
            return {
              uid: decoded.user_id || decoded.sub || decoded.uid,
              email: decoded.email || '',
              name: decoded.name || decoded.email?.split('@')[0] || '',
              picture: decoded.picture || '',
              phone_number: decoded.phone_number || '',
            };
          }
        } catch (e) {
          this.logger.debug('Failed to parse JWT payload in bypass mode, falling back');
        }
      }
      
      // If token is a JSON, try to parse it
      try {
        const decoded = JSON.parse(token);
        if (decoded && decoded.uid && decoded.email) {
          return decoded;
        }
      } catch (e) {
        // Not a JSON string
      }

      // Default mock regular user
      return {
        uid: 'user-firebase-uid',
        email: 'user@gmail.com',
        name: 'User Pahawang',
        picture: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      };
    }

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      return decodedToken;
    } catch (error) {
      this.logger.error('Firebase token verification failed', error);
      throw error;
    }
  }
}
