import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsEnum, IsOptional, IsInt, Min, IsISO8601, ValidateIf } from 'class-validator';

export class CreateBookingDto {
  @ApiProperty({ example: 'villa', enum: ['villa', 'package'] })
  @IsString()
  @IsNotEmpty()
  @IsEnum(['villa', 'package'])
  booking_type: string;

  @ApiPropertyOptional({ example: 'villa-uuid-here' })
  @ValidateIf((o) => o.booking_type === 'villa')
  @IsString()
  @IsNotEmpty()
  villa_id?: string;

  @ApiPropertyOptional({ example: 'package-uuid-here' })
  @ValidateIf((o) => o.booking_type === 'package')
  @IsString()
  @IsNotEmpty()
  package_id?: string;

  @ApiPropertyOptional({ example: '2026-06-15T00:00:00.000Z' })
  @ValidateIf((o) => o.booking_type === 'villa')
  @IsISO8601()
  @IsNotEmpty()
  check_in?: string;

  @ApiPropertyOptional({ example: '2026-06-17T00:00:00.000Z' })
  @ValidateIf((o) => o.booking_type === 'villa')
  @IsISO8601()
  @IsNotEmpty()
  check_out?: string;

  @ApiProperty({ example: 2 })
  @IsInt()
  @Min(1)
  total_guest: number;

  @ApiProperty({ example: 'QRIS', enum: ['QRIS', 'Bank Transfer', 'Dana', 'OVO', 'GoPay'] })
  @IsString()
  @IsNotEmpty()
  @IsEnum(['QRIS', 'Bank Transfer', 'Dana', 'OVO', 'GoPay'])
  payment_method: string;
}
