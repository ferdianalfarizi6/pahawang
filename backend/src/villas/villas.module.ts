import { Module } from '@nestjs/common';
import { VillasService } from './villas.service';
import { VillasController } from './villas.controller';

@Module({
  controllers: [VillasController],
  providers: [VillasService],
  exports: [VillasService],
})
export class VillasModule {}
