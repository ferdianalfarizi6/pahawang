import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateVillaDto } from './dto/create-villa.dto';
import { UpdateVillaDto } from './dto/update-villa.dto';
import { QueryVillaDto } from './dto/query-villa.dto';

@Injectable()
export class VillasService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createVillaDto: CreateVillaDto) {
    return this.prisma.villa.create({
      data: createVillaDto,
    });
  }

  async findAll(query: QueryVillaDto) {
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { location: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.villa.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
      }),
      this.prisma.villa.count({ where }),
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

  async findOne(id: string) {
    const villa = await this.prisma.villa.findUnique({
      where: { id },
    });
    if (!villa) {
      throw new NotFoundException(`Villa with ID "${id}" not found`);
    }
    return villa;
  }

  async update(id: string, updateVillaDto: UpdateVillaDto) {
    await this.findOne(id); // Ensure existence
    return this.prisma.villa.update({
      where: { id },
      data: updateVillaDto,
    });
  }

  async remove(id: string) {
    await this.findOne(id); // Ensure existence
    return this.prisma.villa.delete({
      where: { id },
    });
  }
}
