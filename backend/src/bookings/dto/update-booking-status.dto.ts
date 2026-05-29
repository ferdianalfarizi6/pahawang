import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsEnum } from 'class-validator';
import { PaymentStatus, BookingStatus } from '@prisma/client';

export class UpdateBookingStatusDto {
  @ApiProperty({ example: 'paid', enum: ['unpaid', 'pending', 'paid', 'cancelled'] })
  @IsString()
  @IsNotEmpty()
  @IsEnum(['unpaid', 'pending', 'paid', 'cancelled'])
  payment_status: PaymentStatus;

  @ApiProperty({ example: 'confirmed', enum: ['waiting', 'confirmed', 'completed', 'cancelled'] })
  @IsString()
  @IsNotEmpty()
  @IsEnum(['waiting', 'confirmed', 'completed', 'cancelled'])
  booking_status: BookingStatus;
}
