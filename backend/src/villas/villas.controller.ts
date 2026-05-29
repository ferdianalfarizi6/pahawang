import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { VillasService } from './villas.service';
import { CreateVillaDto } from './dto/create-villa.dto';
import { UpdateVillaDto } from './dto/update-villa.dto';
import { QueryVillaDto } from './dto/query-villa.dto';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@ApiTags('Villas')
@Controller('villas')
export class VillasController {
  constructor(private readonly villasService: VillasService) {}

  @Get()
  @ApiOperation({ summary: 'Get all villas with pagination and search' })
  @ApiResponse({ status: 200, description: 'Return villas list' })
  findAll(@Query() query: QueryVillaDto) {
    return this.villasService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get villa detail' })
  @ApiResponse({ status: 200, description: 'Return villa details' })
  @ApiResponse({ status: 404, description: 'Villa not found' })
  findOne(@Param('id') id: string) {
    return this.villasService.findOne(id);
  }

  @Post()
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create new villa (Admin Only)' })
  @ApiResponse({ status: 201, description: 'Villa successfully created' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not Admin)' })
  create(@Body() createVillaDto: CreateVillaDto) {
    return this.villasService.create(createVillaDto);
  }

  @Patch(':id')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a villa (Admin Only)' })
  @ApiResponse({ status: 200, description: 'Villa successfully updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not Admin)' })
  @ApiResponse({ status: 404, description: 'Villa not found' })
  update(@Param('id') id: string, @Body() updateVillaDto: UpdateVillaDto) {
    return this.villasService.update(id, updateVillaDto);
  }

  @Delete(':id')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a villa (Admin Only)' })
  @ApiResponse({ status: 200, description: 'Villa successfully deleted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not Admin)' })
  @ApiResponse({ status: 404, description: 'Villa not found' })
  remove(@Param('id') id: string) {
    return this.villasService.remove(id);
  }
}
