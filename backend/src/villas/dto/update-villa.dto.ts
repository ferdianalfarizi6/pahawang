import { PartialType } from '@nestjs/swagger';
import { CreateVillaDto } from './create-villa.dto';

export class UpdateVillaDto extends PartialType(CreateVillaDto) {}
