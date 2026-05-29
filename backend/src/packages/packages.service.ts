import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePackageDto } from './dto/create-package.dto';
import { UpdatePackageDto } from './dto/update-package.dto';
import { QueryPackageDto } from './dto/query-package.dto';

@Injectable()
export class PackagesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createPackageDto: CreatePackageDto) {
    return this.prisma.tourPackage.create({
      data: createPackageDto,
    });
  }

  async findAll(query: QueryPackageDto) {
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { location: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.tourPackage.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
      }),
      this.prisma.tourPackage.count({ where }),
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
    const tourPackage = await this.prisma.tourPackage.findUnique({
      where: { id },
    });
    if (!tourPackage) {
      throw new NotFoundException(`Tour package with ID "${id}" not found`);
    }
    return tourPackage;
  }

  async update(id: string, updatePackageDto: UpdatePackageDto) {
    await this.findOne(id); // Ensure existence
    return this.prisma.tourPackage.update({
      where: { id },
      data: updatePackageDto,
    });
  }

  async remove(id: string) {
    await this.findOne(id); // Ensure existence
    return this.prisma.tourPackage.delete({
      where: { id },
    });
  }
}
