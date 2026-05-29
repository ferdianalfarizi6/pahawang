import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@ApiTags('Admin')
@Controller('admin')
@UseGuards(FirebaseAuthGuard, RolesGuard)
@Roles('admin')
@ApiBearerAuth()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get core admin dashboard KPIs and analytical records (Admin Only)' })
  @ApiResponse({ status: 200, description: 'Return analytical dashboard details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not Admin)' })
  getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  @Get('bookings')
  @ApiOperation({ summary: 'List and search through all system bookings (Admin Only)' })
  @ApiResponse({ status: 200, description: 'Return booking monitoring list' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not Admin)' })
  getAllBookings(@Query() query: { page?: number; limit?: number; search?: string }) {
    return this.adminService.getAllBookings(query);
  }

  @Get('users')
  @ApiOperation({ summary: 'Monitor registered users with filters (Admin Only)' })
  @ApiResponse({ status: 200, description: 'Return users list' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not Admin)' })
  getAllUsers(@Query() query: { page?: number; limit?: number; search?: string }) {
    return this.adminService.getAllUsers(query);
  }
}
