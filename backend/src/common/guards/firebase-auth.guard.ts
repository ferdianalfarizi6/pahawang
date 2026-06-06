import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseService: FirebaseService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);
    if (!token) {
      throw new UnauthorizedException('Authentication token is missing');
    }

    let decodedToken: any;
    try {
      decodedToken = await this.firebaseService.verifyToken(token);
      if (!decodedToken || !decodedToken.uid) {
        throw new UnauthorizedException('Invalid authentication token');
      }
    } catch (error) {
      console.error('🔴 FirebaseAuthGuard Token Verification Error:', error);
      throw new UnauthorizedException('Invalid or expired authentication token');
    }
    console.log('🟢 [FirebaseAuthGuard] Decoded Token:', JSON.stringify(decodedToken, null, 2));
    console.log('🟢 [FirebaseAuthGuard] Request Body:', JSON.stringify(request.body, null, 2));

    try {
      const email = decodedToken.email || '';
      const role = email.toLowerCase() === 'admin@gmail.com' ? 'admin' : 'user';
      const phone = request.body?.phone || decodedToken.phone_number || '';

      // 1. Try to find user by firebase_uid
      let user = await this.prisma.user.findUnique({
        where: { firebase_uid: decodedToken.uid },
      });

      // 2. If not found by firebase_uid, check if user exists with the same email to avoid unique constraint conflict
      if (!user && email) {
        user = await this.prisma.user.findUnique({
          where: { email },
        });

        if (user) {
          // Link/update existing user record with the new firebase_uid
          user = await this.prisma.user.update({
            where: { id: user.id },
            data: {
              firebase_uid: decodedToken.uid,
              ...(phone && !user.phone ? { phone } : {}),
            },
          });
          console.log(`🟢 [FirebaseAuthGuard] Linked existing user ${email} with new firebase_uid`);
        }
      }

      // 3. If still not found, create new user
      if (!user) {
        user = await this.prisma.user.create({
          data: {
            firebase_uid: decodedToken.uid,
            email,
            full_name: decodedToken.name || email.split('@')[0],
            avatar: decodedToken.picture || '',
            phone,
            role,
          },
        });
        console.log(`🟢 [FirebaseAuthGuard] Created new user in PostgreSQL for ${email}`);
      } else {
        // User exists, check if phone number needs to be updated/added
        if (phone && !user.phone) {
          user = await this.prisma.user.update({
            where: { id: user.id },
            data: { phone },
          });
          console.log(`🟢 [FirebaseAuthGuard] Updated phone number for user ${email}`);
        }
      }

      request.user = user;
      return true;
    } catch (error) {
      console.error('🔴 FirebaseAuthGuard Database/Internal Error:', error);
      throw error; // Rethrow to let NestJS return a 500 error instead of misleading 401
    }
  }

  private extractTokenFromHeader(request: any): string | null {
    const authHeader = request.headers['authorization'];
    if (!authHeader) return null;
    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : null;
  }
}
