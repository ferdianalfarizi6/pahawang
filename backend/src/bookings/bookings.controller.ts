import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';
import { UpdateBookingStatusDto } from './dto/update-booking-status.dto';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { GetUser } from '../common/decorators/get-user.decorator';

@ApiTags('Bookings')
@Controller('bookings')
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  @ApiOperation({ summary: 'Create new booking (Villa or Tour Package)' })
  @ApiResponse({ status: 201, description: 'Booking successfully created' })
  @ApiResponse({ status: 400, description: 'Bad request / sold out / invalid data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  create(@Body() createBookingDto: CreateBookingDto, @GetUser('id') userId: string) {
    return this.bookingsService.create(createBookingDto, userId);
  }

  @Get('my')
  @ApiOperation({ summary: 'Get logged-in user\'s booking history' })
  @ApiResponse({ status: 200, description: 'Return booking history' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  getMyBookings(
    @GetUser('id') userId: string,
    @Query() query: { page?: number; limit?: number },
  ) {
    return this.bookingsService.getMyBookings(userId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get booking detail' })
  @ApiResponse({ status: 200, description: 'Return booking details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not owner or admin)' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  findOne(
    @Param('id') id: string,
    @GetUser('id') userId: string,
    @GetUser('role') role: any,
  ) {
    return this.bookingsService.findOne(id, userId, role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Edit check-in, check-out, or guests (Forbidden if paid)' })
  @ApiResponse({ status: 200, description: 'Booking successfully updated' })
  @ApiResponse({ status: 400, description: 'Forbidden if paid / validation error' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not owner or admin)' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  update(
    @Param('id') id: string,
    @Body() updateBookingDto: UpdateBookingDto,
    @GetUser('id') userId: string,
    @GetUser('role') role: any,
  ) {
    return this.bookingsService.update(id, updateBookingDto, userId, role);
  }

  @Patch(':id/cancel')
  @ApiOperation({ summary: 'Cancel booking (Forbidden if paid)' })
  @ApiResponse({ status: 200, description: 'Booking successfully cancelled' })
  @ApiResponse({ status: 400, description: 'Forbidden if paid' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not owner or admin)' })
  cancelBooking(
    @Param('id') id: string,
    @GetUser('id') userId: string,
    @GetUser('role') role: any,
  ) {
    return this.bookingsService.cancelBooking(id, userId, role);
  }

  @Patch(':id/status')
  @UseGuards(RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'Update payment & booking status (Admin Only)' })
  @ApiResponse({ status: 200, description: 'Status successfully updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not Admin)' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  updateStatus(
    @Param('id') id: string,
    @Body() updateBookingStatusDto: UpdateBookingStatusDto,
  ) {
    return this.bookingsService.updateStatus(id, updateBookingStatusDto);
  }
}
