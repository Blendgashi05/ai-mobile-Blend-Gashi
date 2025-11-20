# Shopping List App - Project Documentation

## Overview
A modern, premium Flutter web application for managing shopping lists with Supabase backend integration. Features a sleek glassmorphism design with dark theme, gradient accents, and smooth animations. Built on November 20, 2025.

## Project Status
- **Status**: Phase 1 redesign in progress
- **Type**: Flutter web application
- **Backend**: Supabase (Authentication + PostgreSQL)
- **Deployment**: Static build served on port 5000
- **Design Phase**: Modern glassmorphism UI implemented

## Tech Stack
- **Frontend**: Flutter 3.32.0 / Dart 3.8
- **Backend**: Supabase (Auth + Database)
- **State Management**: Provider pattern
- **UI**: Material 3 with custom dark theme
- **Design**: Glassmorphism with Midnight Emerald palette
- **Fonts**: Google Fonts (Poppins + Inter)
- **Dependencies**: supabase_flutter, provider, http, intl, google_fonts

## Project Architecture

### Folder Structure
```
lib/
├── models/              # Data models (ShoppingList, ShoppingItem)
├── services/            # Business logic (SupabaseService)
├── screens/             # UI screens (Login, Signup, Lists, Details)
├── widgets/             # Reusable components (CustomButton, CustomTextField)
└── main.dart            # App entry point with theming
```

### Key Files
- `serve.py`: Production HTTP server for Flutter web build
- `build/web/`: Compiled Flutter web application
- `README.md`: Comprehensive setup and usage documentation

## Features Implemented
1. ✅ Email/password authentication (signup, login, logout)
2. ✅ CRUD operations for shopping lists
3. ✅ CRUD operations for shopping items
4. ✅ Mark items as bought/unbought
5. ✅ Modern Material 3 UI with indigo theme
6. ✅ Input validation and error handling
7. ✅ Loading states throughout
8. ✅ Pull-to-refresh functionality
9. ✅ Responsive design
10. ✅ Clean code with comments

## Environment Variables
- `SUPABASE_URL`: Supabase project API URL (configured)
- `SUPABASE_ANON_KEY`: Supabase anonymous key (configured)

## Database Schema
See README.md for complete SQL schema. Tables:
- `shopping_lists`: User's shopping lists
- `shopping_items`: Items within lists
- Row Level Security (RLS) enabled on both tables

## Running the Application

### Development
The app is configured to build and serve a production Flutter web build:
```bash
flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
python3 serve.py
```

### Workflow
The "Flutter App" workflow runs `python3 serve.py` which:
1. Changes to build/web directory
2. Serves static files on port 5000 with cache disabled
3. Allows address reuse for quick restarts

### Rebuilding
To rebuild after code changes:
```bash
flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
# Then restart the workflow
```

## Recent Changes (November 20, 2025)

### Phase 1: Initial Development
- Initial project setup from empty GitHub import
- Installed Flutter/Dart 3.8 and dependencies
- Created complete folder structure
- Implemented all authentication screens
- Implemented all shopping list management screens
- Created reusable widget components
- Set up Supabase integration
- Added comprehensive error handling
- Created detailed README with database schema
- Configured production build workflow
- Set up deployment configuration

### Phase 2: Modern Redesign
- Created comprehensive design system documentation (DESIGN_SYSTEM.md)
- Implemented Midnight Emerald dark theme with glassmorphism
- Added Google Fonts integration (Poppins for headings, Inter for body)
- Redesigned login screen with:
  - Gradient background with floating orbs
  - Glassmorphic card with backdrop blur
  - Gradient button (emerald to purple)
  - Smooth fade-in animations
  - Modern icon with gradient glow
- Redesigned signup screen with:
  - Matching glassmorphism design
  - Slide and fade animations
  - Glassmorphic back button
  - Reversed gradient (purple to emerald)
- Updated theme with:
  - Deep Space background (#0B0F2A)
  - Glass panels (#111936 at 85% opacity)
  - Emerald (#27E8A7) and Purple (#8B5CF6) accents
  - Custom typography scale
  - Enhanced input fields, buttons, cards
- Built comprehensive roadmap for future phases

## User Preferences
- Clean, production-ready code with comments
- Modern UI with consistent theming
- Comprehensive error handling
- Clear documentation

## Design System
- **Color Palette**: Midnight Emerald theme
  - Deep Space: #0B0F2A (background)
  - Midnight Blue: #111936 (surfaces)
  - Emerald Glow: #27E8A7 (primary)
  - Purple Accent: #8B5CF6 (secondary)
- **Typography**:
  - Headings: Poppins (Semi-Bold, Bold)
  - Body: Inter (Regular, Medium)
- **Effects**: Glassmorphism with 24px blur, gradient accents
- **Animations**: Fade, slide, and scale transitions

## Roadmap
See DESIGN_SYSTEM.md for complete roadmap. Key phases:
- **Phase 1 (Current)**: Foundation & Redesign
  - ✅ Design system & documentation
  - ✅ Modern dark theme with glassmorphism
  - ✅ Custom fonts (Google Fonts)
  - ✅ Login/Signup redesign
  - 🔄 Home Hub with dashboard
  - 🔄 Enhanced list views
  - 🔄 Improved detail screens
- **Phase 2 (Next)**: Collaboration & Intelligence
  - Categories & tags
  - Smart suggestions
  - Shared lists with real-time sync
  - Budget tracking
- **Phase 3 (Future)**: Insights & Polish
  - Shopping history & analytics
  - Price tracking
  - Barcode scanner
  - Custom themes

## Known Issues / Notes
- Service worker warnings in browser console (expected, doesn't affect functionality)
- WebGL fallback to CPU rendering (expected in some environments)
- Uses production build instead of debug mode for better stability in Replit
- Database tables need to be created in Supabase using SQL from supabase_setup.sql

## Next Steps for Users
1. Set up Supabase database using SQL from README
2. Test signup/login functionality
3. Create shopping lists and add items
4. Customize theme colors if desired (lib/main.dart)
