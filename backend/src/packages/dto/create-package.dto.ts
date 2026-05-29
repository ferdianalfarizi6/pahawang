import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsNumber, IsArray, IsPositive, Min } from 'class-validator';

export class CreatePackageDto {
  @ApiProperty({ example: 'Pahawang Snorkeling & Hopping Island' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ example: 'Paket snorkeling seharian penuh dengan guide profesional.' })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({ example: '1 Day (08:00 - 16:00)' })
  @IsString()
  @IsNotEmpty()
  duration: string;

  @ApiProperty({ example: 'Pulau Pahawang Besar & Kecil' })
  @IsString()
  @IsNotEmpty()
  location: string;

  @ApiProperty({ example: 350000 })
  @IsNumber()
  @IsPositive()
  price: number;

  @ApiProperty({ example: 20 })
  @IsNumber()
  @Min(1)
  quota: number;

  @ApiProperty({ example: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5' })
  @IsString()
  @IsNotEmpty()
  thumbnail: string;

  @ApiProperty({
    example: [
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
    ],
  })
  @IsArray()
  @IsString({ each: true })
  gallery: string[];

  @ApiProperty({ example: ['Snorkeling Gear', 'Lunch Box', 'Documentation', 'Boat Transport', 'Entry Ticket'] })
  @IsArray()
  @IsString({ each: true })
  facilities: string[];
}
