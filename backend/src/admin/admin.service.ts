import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
// Using string literals instead of Prisma enums (matches schema.prisma values)
type PaymentStatusType = 'unpaid' | 'pending' | 'paid' | 'cancelled';
type BookingStatusType = 'waiting' | 'confirmed' | 'completed' | 'cancelled';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboardStats() {
    // Total Revenue (Sum of all paid payments)
    const paidPayments = await this.prisma.payment.aggregate({
      where: { payment_status: 'paid' as PaymentStatusType },
      _sum: { amount: true },
    });
    const totalRevenue = paidPayments._sum.amount || 0;

    // Core Counts
    const [
      totalBookings,
      activeBookings,
      totalUsers,
      totalVillas,
      totalPackages,
    ] = await Promise.all([
      this.prisma.booking.count(),
      this.prisma.booking.count({
        where: {
          booking_status: { in: ['waiting', 'confirmed'] as BookingStatusType[] },
        },
      }),
      this.prisma.user.count({ where: { role: 'user' as any } }),
      this.prisma.villa.count(),
      this.prisma.tourPackage.count(),
    ]);

    // Recent Bookings (last 5)
    const recentBookings = await this.prisma.booking.findMany({
      take: 5,
      orderBy: { created_at: 'desc' },
      include: {
        user: {
          select: { id: true, full_name: true, email: true, avatar: true },
        },
        villa: { select: { id: true, name: true } },
        package: { select: { id: true, title: true } },
      },
    });

    // Recent Payments (last 5 paid)
    const recentPayments = await this.prisma.payment.findMany({
      where: { payment_status: 'paid' as PaymentStatusType },
      take: 5,
      orderBy: { paid_at: 'desc' },
      include: {
        booking: {
          select: {
            id: true,
            booking_code: true,
            booking_type: true,
            user: { select: { full_name: true, email: true } },
          },
        },
      },
    });

    return {
      stats: {
        totalRevenue,
        totalBookings,
        activeBookings,
        totalUsers,
        totalVillas,
        totalPackages,
      },
      recentBookings,
      recentPayments,
    };
  }

  async getAllBookings(query: { page?: number; limit?: number; search?: string }) {
    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 10;
    const skip = (page - 1) * limit;
    const { search } = query;

    const where: any = {};
    if (search) {
      where.OR = [
        { booking_code: { contains: search, mode: 'insensitive' } },
        {
          user: {
            OR: [
              { email: { contains: search, mode: 'insensitive' } },
              { full_name: { contains: search, mode: 'insensitive' } },
            ],
          },
        },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.booking.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          user: {
            select: { id: true, full_name: true, email: true, phone: true },
          },
          villa: true,
          package: true,
        },
      }),
      this.prisma.booking.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getAllUsers(query: { page?: number; limit?: number; search?: string }) {
    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 10;
    const skip = (page - 1) * limit;
    const { search } = query;

    const where: any = { role: 'user' }; // Only monitor standard users, omit other admins
    if (search) {
      where.OR = [
        { email: { contains: search, mode: 'insensitive' } },
        { full_name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
