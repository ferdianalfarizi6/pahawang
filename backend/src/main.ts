import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable CORS for Flutter mobile and web clients
  app.enableCors();

  // Set global prefix for API endpoints
  app.setGlobalPrefix('api');

  // Register Global Validation Pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );

  // Register Global HttpException Filter for clean JSON errors
  app.useGlobalFilters(new HttpExceptionFilter());

  // Setup Swagger API Documentation
  const config = new DocumentBuilder()
    .setTitle('Pulau Pahawang Tourism API')
    .setDescription(
      'REST API Documentation for Pulau Pahawang Villa & Tour Booking Application. Built with NestJS, Prisma, and PostgreSQL.',
    )
    .setVersion('1.0')
    .addBearerAuth({
      type: 'http',
      scheme: 'bearer',
      bearerFormat: 'JWT',
      description: 'Input your Firebase ID Token (use "admin_token" for mock testing in bypass mode)',
    })
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 Pulau Pahawang backend is running on: http://localhost:${port}/api`);
  console.log(`📄 Swagger documentation is available at: http://localhost:${port}/api/docs`);
}
bootstrap();
