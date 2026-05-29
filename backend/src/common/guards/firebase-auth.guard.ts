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

    try {
      const decodedToken = await this.firebaseService.verifyToken(token);
      if (!decodedToken || !decodedToken.uid) {
        throw new UnauthorizedException('Invalid authentication token');
      }

      // Find user in PostgreSQL by firebase_uid
      let user = await this.prisma.user.findUnique({
        where: { firebase_uid: decodedToken.uid },
      });

      if (!user) {
        // Auto-create user in PostgreSQL database
        const email = decodedToken.email || '';
        const role = email.toLowerCase() === 'admin@gmail.com' ? 'admin' : 'user';
        
        user = await this.prisma.user.create({
          data: {
            firebase_uid: decodedToken.uid,
            email: email,
            full_name: decodedToken.name || email.split('@')[0],
            avatar: decodedToken.picture || '',
            phone: request.body?.phone || decodedToken.phone_number || '',
            role: role,
          },
        });
      } else if (request.body?.phone && !user.phone) {
        user = await this.prisma.user.update({
          where: { id: user.id },
          data: { phone: request.body.phone },
        });
      }

      // Attach PostgreSQL user instance to Request
      request.user = user;
      return true;
    } catch (error) {
      throw new UnauthorizedException('Invalid or expired authentication token');
    }
  }

  private extractTokenFromHeader(request: any): string | null {
    const authHeader = request.headers['authorization'];
    if (!authHeader) return null;
    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : null;
  }
}
