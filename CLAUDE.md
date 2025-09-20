# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Medusa e-commerce application (v2+) built with TypeScript. Medusa is a composable commerce platform that provides modular building blocks for e-commerce functionality.

## Development Commands

### Core Development
- `npm run dev` - Start development server with hot reload
- `npm run build` - Build the application for production
- `npm start` - Start production server
- `npm run seed` - Run database seeding script

### Testing
- `npm run test:unit` - Run unit tests
- `npm run test:integration:http` - Run HTTP integration tests
- `npm run test:integration:modules` - Run module integration tests

### Docker
- `npm run docker:up` - Start application with Docker Compose
- `npm run docker:down` - Stop Docker containers

### Database
- `npx medusa db:generate <module-name>` - Generate migrations for a module
- `npx medusa db:migrate` - Run database migrations

## Architecture

### Project Structure
```
src/
├── admin/          # Admin dashboard customizations (widgets, pages)
├── api/            # REST API routes (file-based routing)
│   ├── admin/      # Admin API routes
│   └── store/      # Storefront API routes
├── jobs/           # Background job definitions
├── links/          # Module linking definitions
├── modules/        # Custom modules (business logic containers)
├── scripts/        # Utility scripts (seeding, etc.)
├── subscribers/    # Event subscribers
└── workflows/      # Multi-step business processes
```

### Key Concepts

**Modules**: Self-contained packages of functionality with models, services, and business logic. Each module should have:
- `models/` - Database models
- `service.ts` - Main service class extending MedusaService
- `index.ts` - Module definition export

**API Routes**: File-based REST endpoints under `/api`. File must be named `route.ts` and export HTTP method functions (GET, POST, etc.). Use `[param]` directories for dynamic routes.

**Workflows**: Multi-step processes using `createWorkflow` and `createStep`. Execute workflows in API routes or other contexts using `workflow(req.scope).run()`.

**Subscribers**: Event handlers that listen to system events. Export an async function and a config object with the event name.

**Admin Extensions**: React components for extending the admin dashboard. Widgets inject into existing pages, custom pages create new admin sections.

## Configuration

- `medusa-config.ts` - Main application configuration
- Environment variables for database, CORS, secrets
- Module registration in `modules` array
- Database driver options (PostgreSQL with SSL disabled)

## Dependencies

**Core**: @medusajs/framework, @medusajs/medusa, @medusajs/admin-sdk
**Database**: @mikro-orm/postgresql, pg
**Testing**: Jest with @swc/jest for TypeScript transformation

## Testing Configuration

Tests are categorized by TEST_TYPE environment variable:
- `integration:http` - HTTP endpoint tests
- `integration:modules` - Module integration tests  
- `unit` - Unit tests (*.unit.spec.ts)

## Container Usage

Access Medusa's dependency injection container via `req.scope.resolve()` to get module services and other registered resources in API routes, workflows, and subscribers.

## Development Notes

- Node.js 20+ required
- Uses TypeScript with strict configuration
- MikroORM for database operations
- File-based routing for API endpoints
- Event-driven architecture with subscribers
- Modular design with custom modules