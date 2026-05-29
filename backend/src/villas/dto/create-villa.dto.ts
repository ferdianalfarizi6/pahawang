import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsNumber, IsArray, IsPositive, Min } from 'class-validator';

export class CreateVillaDto {
  @ApiProperty({ example: 'Andreas Resort' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'Resort terapung bernuansa Maldives di Lampung.' })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({ example: 'Pulau Pahawang, Pesawaran, Lampung' })
  @IsString()
  @IsNotEmpty()
  location: string;

  @ApiProperty({ example: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef' })
  @IsString()
  @IsNotEmpty()
  thumbnail: string;

  @ApiProperty({
    example: [
      'https://images.unsplash.com/photo-1540555700478-4be289fbecef',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d',
    ],
  })
  @IsArray()
  @IsString({ each: true })
  gallery: string[];

  @ApiProperty({ example: 1500000 })
  @IsNumber()
  @IsPositive()
  price_per_night: number;

  @ApiProperty({ example: 6 })
  @IsNumber()
  @Min(1)
  max_guest: number;

  @ApiProperty({ example: 5 })
  @IsNumber()
  @Min(0)
  available_room: number;

  @ApiProperty({ example: ['AC', 'Infinity Pool', 'Floating Breakfast', 'WiFi', 'Water Heater'] })
  @IsArray()
  @IsString({ each: true })
  facilities: string[];
}
