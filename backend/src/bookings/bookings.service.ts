import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';
import { UpdateBookingStatusDto } from './dto/update-booking-status.dto';
import { PaymentStatus, BookingStatus, Role } from '@prisma/client';

@Injectable()
export class BookingsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createBookingDto: CreateBookingDto, userId: string) {
    const {
      booking_type,
      villa_id,
      package_id,
      check_in,
      check_out,
      total_guest,
      payment_method,
    } = createBookingDto;

    let total_price = 0;
    const bookingCode = `PB-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;

    return this.prisma.$transaction(async (tx) => {
      if (booking_type === 'villa') {
        if (!villa_id || !check_in || !check_out) {
          throw new BadRequestException('Villa ID, check-in, and check-out dates are required.');
        }

        const villa = await tx.villa.findUnique({ where: { id: villa_id } });
        if (!villa) {
          throw new NotFoundException(`Villa with ID "${villa_id}" not found.`);
        }

        if (villa.available_room < 1) {
          throw new BadRequestException('Maaf, tidak ada kamar villa yang tersedia.');
        }

        if (total_guest > villa.max_guest) {
          throw new BadRequestException(`Jumlah tamu melebihi kapasitas maksimum villa (${villa.max_guest} orang).`);
        }

        // Recalculate nights
        const inDate = new Date(check_in);
        const outDate = new Date(check_out);
        const diffTime = outDate.getTime() - inDate.getTime();
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        const nights = diffDays > 0 ? diffDays : 1;

        total_price = villa.price_per_night * nights;

        // Decrement available room
        await tx.villa.update({
          where: { id: villa_id },
          data: { available_room: villa.available_room - 1 },
        });

      } else if (booking_type === 'package') {
        if (!package_id) {
          throw new BadRequestException('Package ID is required.');
        }

        const tourPackage = await tx.tourPackage.findUnique({ where: { id: package_id } });
        if (!tourPackage) {
          throw new NotFoundException(`Tour package with ID "${package_id}" not found.`);
        }

        if (tourPackage.quota < total_guest) {
          throw new BadRequestException(`Maaf, sisa kuota paket tidak mencukupi (sisa kuota: ${tourPackage.quota}).`);
        }

        total_price = tourPackage.price * total_guest;

        // Decrement quota
        await tx.tourPackage.update({
          where: { id: package_id },
          data: { quota: tourPackage.quota - total_guest },
        });
      }

      // Create Booking
      const booking = await tx.booking.create({
        data: {
          booking_code: bookingCode,
          user_id: userId,
          booking_type,
          villa_id: booking_type === 'villa' ? villa_id : null,
          package_id: booking_type === 'package' ? package_id : null,
          check_in: booking_type === 'villa' ? new Date(check_in!) : null,
          check_out: booking_type === 'villa' ? new Date(check_out!) : null,
          total_guest,
          total_price,
          payment_method,
          payment_status: PaymentStatus.pending,
          booking_status: BookingStatus.waiting,
        },
        include: {
          villa: true,
          package: true,
        },
      });

      // Create dummy payment record
      const paymentCode = `PAY-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
      await tx.payment.create({
        data: {
          booking_id: booking.id,
          payment_code: paymentCode,
          amount: total_price,
          payment_method,
          payment_status: PaymentStatus.pending,
        },
      });

      return booking;
    });
  }

  async getMyBookings(userId: string, query: { page?: number; limit?: number }) {
    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 10;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      this.prisma.booking.findMany({
        where: { user_id: userId },
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          villa: true,
          package: true,
        },
      }),
      this.prisma.booking.count({ where: { user_id: userId } }),
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

  async findOne(id: string, userId: string, userRole: Role) {
    const booking = await this.prisma.booking.findUnique({
      where: { id },
      include: {
        villa: true,
        package: true,
        payments: true,
        user: true,
      },
    });

    if (!booking) {
      throw new NotFoundException(`Booking with ID "${id}" not found.`);
    }

    if (userRole !== Role.admin && booking.user_id !== userId) {
      throw new ForbiddenException('You do not have access to view this booking.');
    }

    return booking;
  }

  async update(id: string, updateBookingDto: UpdateBookingDto, userId: string, userRole: Role) {
    const booking = await this.prisma.booking.findUnique({
      where: { id },
      include: { villa: true, package: true },
    });

    if (!booking) {
      throw new NotFoundException(`Booking with ID "${id}" not found.`);
    }

    if (userRole !== Role.admin && booking.user_id !== userId) {
      throw new ForbiddenException('You do not have access to modify this booking.');
    }

    // BUSINESS RULE: Cannot edit booking if paid
    if (booking.payment_status === PaymentStatus.paid) {
      throw new BadRequestException('Booking tidak dapat diedit karena sudah dibayar.');
    }

    // Recalculate if dates or guests change
    const checkInStr = updateBookingDto.check_in || booking.check_in?.toISOString();
    const checkOutStr = updateBookingDto.check_out || booking.check_out?.toISOString();
    const totalGuest = updateBookingDto.total_guest !== undefined ? updateBookingDto.total_guest : booking.total_guest;

    let updatedTotalPrice = booking.total_price;
    let oldGuestDiff = 0;

    return this.prisma.$transaction(async (tx) => {
      if (booking.booking_type === 'villa' && booking.villa_id) {
        const villa = await tx.villa.findUnique({ where: { id: booking.villa_id } });
        if (!villa) throw new NotFoundException('Villa not found.');

        if (totalGuest > villa.max_guest) {
          throw new BadRequestException(`Jumlah tamu melebihi kapasitas villa (${villa.max_guest} orang).`);
        }

        if (checkInStr && checkOutStr) {
          const inDate = new Date(checkInStr);
          const outDate = new Date(checkOutStr);
          const diffDays = Math.ceil((outDate.getTime() - inDate.getTime()) / (1000 * 60 * 60 * 24));
          const nights = diffDays > 0 ? diffDays : 1;
          updatedTotalPrice = villa.price_per_night * nights;
        }
      } else if (booking.booking_type === 'package' && booking.package_id) {
        const tourPackage = await tx.tourPackage.findUnique({ where: { id: booking.package_id } });
        if (!tourPackage) throw new NotFoundException('Package not found.');

        oldGuestDiff = totalGuest - booking.total_guest;
        if (oldGuestDiff > 0 && tourPackage.quota < oldGuestDiff) {
          throw new BadRequestException(`Kuota paket tidak mencukupi untuk penambahan tamu (sisa: ${tourPackage.quota}).`);
        }

        updatedTotalPrice = tourPackage.price * totalGuest;

        // Adjust package quota
        if (oldGuestDiff !== 0) {
          await tx.tourPackage.update({
            where: { id: booking.package_id },
            data: { quota: tourPackage.quota - oldGuestDiff },
          });
        }
      }

      // Update Booking
      const updatedBooking = await tx.booking.update({
        where: { id },
        data: {
          check_in: checkInStr ? new Date(checkInStr) : null,
          check_out: checkOutStr ? new Date(checkOutStr) : null,
          total_guest: totalGuest,
          total_price: updatedTotalPrice,
        },
        include: { villa: true, package: true },
      });

      // Update linked payment amount
      await tx.payment.updateMany({
        where: { booking_id: id },
        data: { amount: updatedTotalPrice },
      });

      return updatedBooking;
    });
  }

  async cancelBooking(id: string, userId: string, userRole: Role) {
    const booking = await this.prisma.booking.findUnique({
      where: { id },
    });

    if (!booking) {
      throw new NotFoundException(`Booking with ID "${id}" not found.`);
    }

    if (userRole !== Role.admin && booking.user_id !== userId) {
      throw new ForbiddenException('You do not have access to cancel this booking.');
    }

    if (booking.payment_status === PaymentStatus.paid) {
      throw new BadRequestException('Pemesanan yang telah lunas tidak dapat dibatalkan.');
    }

    if (booking.booking_status === BookingStatus.cancelled) {
      return booking; // Already cancelled
    }

    return this.prisma.$transaction(async (tx) => {
      // Restore inventory
      if (booking.booking_type === 'villa' && booking.villa_id) {
        const villa = await tx.villa.findUnique({ where: { id: booking.villa_id } });
        if (villa) {
          await tx.villa.update({
            where: { id: booking.villa_id },
            data: { available_room: villa.available_room + 1 },
          });
        }
      } else if (booking.booking_type === 'package' && booking.package_id) {
        const tourPackage = await tx.tourPackage.findUnique({ where: { id: booking.package_id } });
        if (tourPackage) {
          await tx.tourPackage.update({
            where: { id: booking.package_id },
            data: { quota: tourPackage.quota + booking.total_guest },
          });
        }
      }

      // Update Booking
      const cancelledBooking = await tx.booking.update({
        where: { id },
        data: {
          booking_status: BookingStatus.cancelled,
          payment_status: PaymentStatus.cancelled,
        },
      });

      // Update Payments
      await tx.payment.updateMany({
        where: { booking_id: id },
        data: { payment_status: PaymentStatus.cancelled },
      });

      return cancelledBooking;
    });
  }

  async updateStatus(id: string, updateBookingStatusDto: UpdateBookingStatusDto) {
    const { payment_status, booking_status } = updateBookingStatusDto;

    const booking = await this.prisma.booking.findUnique({
      where: { id },
    });

    if (!booking) {
      throw new NotFoundException(`Booking with ID "${id}" not found.`);
    }

    return this.prisma.$transaction(async (tx) => {
      // If we are transitioning to cancelled from a non-cancelled state, restore inventory
      if (booking_status === BookingStatus.cancelled && booking.booking_status !== BookingStatus.cancelled) {
        if (booking.booking_type === 'villa' && booking.villa_id) {
          const villa = await tx.villa.findUnique({ where: { id: booking.villa_id } });
          if (villa) {
            await tx.villa.update({
              where: { id: booking.villa_id },
              data: { available_room: villa.available_room + 1 },
            });
          }
        } else if (booking.booking_type === 'package' && booking.package_id) {
          const tourPackage = await tx.tourPackage.findUnique({ where: { id: booking.package_id } });
          if (tourPackage) {
            await tx.tourPackage.update({
              where: { id: booking.package_id },
              data: { quota: tourPackage.quota + booking.total_guest },
            });
          }
        }
      }

      // If we are transitioning OUT of cancelled back to waiting/confirmed, decrement inventory again
      if (booking.booking_status === BookingStatus.cancelled && booking_status !== BookingStatus.cancelled) {
        if (booking.booking_type === 'villa' && booking.villa_id) {
          const villa = await tx.villa.findUnique({ where: { id: booking.villa_id } });
          if (villa && villa.available_room > 0) {
            await tx.villa.update({
              where: { id: booking.villa_id },
              data: { available_room: villa.available_room - 1 },
            });
          } else {
            throw new BadRequestException('Rooms are no longer available to restore booking.');
          }
        } else if (booking.booking_type === 'package' && booking.package_id) {
          const tourPackage = await tx.tourPackage.findUnique({ where: { id: booking.package_id } });
          if (tourPackage && tourPackage.quota >= booking.total_guest) {
            await tx.tourPackage.update({
              where: { id: booking.package_id },
              data: { quota: tourPackage.quota - booking.total_guest },
            });
          } else {
            throw new BadRequestException('Package quota is no longer available to restore booking.');
          }
        }
      }

      // Update Booking
      const updatedBooking = await tx.booking.update({
        where: { id },
        data: {
          payment_status,
          booking_status,
        },
        include: { villa: true, package: true },
      });

      // Update linked Payments
      await tx.payment.updateMany({
        where: { booking_id: id },
        data: {
          payment_status,
          paid_at: payment_status === PaymentStatus.paid ? new Date() : null,
        },
      });

      return updatedBooking;
    });
  }
}
