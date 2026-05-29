import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsInt, Min, IsISO8601 } from 'class-validator';

export class UpdateBookingDto {
  @ApiPropertyOptional({ example: '2026-06-16T00:00:00.000Z' })
  @IsOptional()
  @IsISO8601()
  check_in?: string;

  @ApiPropertyOptional({ example: '2026-06-18T00:00:00.000Z' })
  @IsOptional()
  @IsISO8601()
  check_out?: string;

  @ApiPropertyOptional({ example: 4 })
  @IsOptional()
  @IsInt()
  @Min(1)
  total_guest?: number;
}
