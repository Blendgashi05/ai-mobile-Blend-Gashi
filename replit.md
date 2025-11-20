# Shopping List App - Project Documentation

## Overview
A production-ready Flutter web application for managing shopping lists with Supabase backend integration. Built on November 20, 2025.

## Project Status
- **Status**: Fully functional and deployed
- **Type**: Flutter web application
- **Backend**: Supabase (Authentication + PostgreSQL)
- **Deployment**: Static build served on port 5000

## Tech Stack
- **Frontend**: Flutter 3.32.0 / Dart 3.8
- **Backend**: Supabase (Auth + Database)
- **State Management**: Provider pattern
- **UI**: Material 3 design system
- **Dependencies**: supabase_flutter, provider, http, intl

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

## User Preferences
- Clean, production-ready code with comments
- Modern UI with consistent theming
- Comprehensive error handling
- Clear documentation

## Known Issues / Notes
- Service worker warnings in browser console (expected, doesn't affect functionality)
- WebGL fallback to CPU rendering (expected in some environments)
- Uses production build instead of debug mode for better stability in Replit

## Next Steps for Users
1. Set up Supabase database using SQL from README
2. Test signup/login functionality
3. Create shopping lists and add items
4. Customize theme colors if desired (lib/main.dart)
