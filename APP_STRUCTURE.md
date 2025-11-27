# Shopping List App - Project Structure

## Overview
A Flutter web/mobile application for managing shopping lists with Supabase backend.

## Directory Structure

```
shopping-list-app/
├── lib/                          # Main application source code
│   ├── main.dart                 # App entry point, theme configuration, Supabase init
│   │
│   ├── models/                   # Data models (Plain Dart classes)
│   │   ├── category.dart         # Category model for item categorization
│   │   ├── purchase_history.dart # Purchase history tracking model
│   │   ├── shopping_item.dart    # Shopping item model (name, quantity, bought status)
│   │   ├── shopping_list.dart    # Shopping list model (name, items, timestamps)
│   │   ├── user_preferences.dart # User settings and preferences
│   │   └── user_profile.dart     # User profile data (display name, photo URL)
│   │
│   ├── screens/                  # UI screens (full-page views)
│   │   ├── login_screen.dart     # User login with email/password
│   │   ├── signup_screen.dart    # New user registration
│   │   ├── home_hub_screen.dart  # Main navigation hub with bottom nav bar
│   │   ├── dashboard_screen.dart # Home dashboard with stats and quick actions
│   │   ├── shopping_lists_screen.dart    # All shopping lists view
│   │   ├── shopping_list_detail_screen.dart # Single list with items
│   │   ├── analytics_screen.dart # Shopping analytics and insights
│   │   └── profile_screen.dart   # User profile management
│   │
│   ├── services/                 # Business logic and API calls
│   │   └── supabase_service.dart # Supabase API wrapper (auth, database, storage)
│   │
│   └── widgets/                  # Reusable UI components
│       ├── custom_button.dart    # Styled button with gradient
│       └── custom_text_field.dart # Styled text input field
│
├── build/                        # Compiled output (auto-generated)
│   └── web/                      # Flutter web build files
│
├── assets/                       # Static assets (images, fonts)
│
├── pubspec.yaml                  # Flutter dependencies and configuration
├── serve.py                      # Python HTTP server for web deployment
├── replit.md                     # Project documentation and preferences
├── DESIGN_SYSTEM.md              # UI/UX design guidelines
└── README.md                     # Setup and usage instructions
```

## Architecture Pattern

### Layer Overview
```
┌─────────────────────────────────────────────────────┐
│                    PRESENTATION                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ Screens  │  │ Widgets  │  │ Theme (main.dart)│   │
│  └────┬─────┘  └────┬─────┘  └──────────────────┘   │
│       │             │                                │
├───────┴─────────────┴───────────────────────────────┤
│                    BUSINESS LOGIC                    │
│  ┌──────────────────────────────────────────────┐   │
│  │            SupabaseService                    │   │
│  │  - Authentication (login, signup, logout)     │   │
│  │  - Database CRUD (lists, items)               │   │
│  │  - Storage (profile photos)                   │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
├──────────────────────────────────────────────────────┤
│                    DATA LAYER                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │  Models  │  │ Supabase │  │ Local State      │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
└──────────────────────────────────────────────────────┘
```

## Screen Flow

```
                    ┌─────────────┐
                    │   App Start │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ Check Auth  │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼─────┐    ┌─────▼─────┐         │
    │  Login    │    │  Signup   │         │
    │  Screen   │◄──►│  Screen   │         │
    └─────┬─────┘    └─────┬─────┘         │
          │                │                │
          └────────┬───────┘                │
                   │                        │
            ┌──────▼──────┐                 │
            │  Home Hub   │◄────────────────┘
            │ (Main Nav)  │
            └──────┬──────┘
                   │
     ┌─────────────┼─────────────┐
     │             │             │
┌────▼────┐  ┌─────▼─────┐  ┌────▼────┐
│Dashboard│  │ Analytics │  │ Profile │
│  (Tab 1)│  │  (Tab 2)  │  │ (Tab 3) │
└────┬────┘  └───────────┘  └─────────┘
     │
┌────▼────────────┐
│ Shopping Lists  │
│    Screen       │
└────┬────────────┘
     │
┌────▼────────────┐
│  List Detail    │
│    Screen       │
└─────────────────┘
```

## Models

| Model | Purpose | Key Fields |
|-------|---------|------------|
| `ShoppingList` | Represents a shopping list | id, name, userId, createdAt, updatedAt |
| `ShoppingItem` | Item within a list | id, listId, name, quantity, isBought, category, price |
| `UserProfile` | User account data | id, email, displayName, photoUrl |
| `UserPreferences` | User settings | theme, notifications, defaultCategory |
| `Category` | Item categorization | id, name, color, icon |
| `PurchaseHistory` | Historical purchases | itemName, purchaseDate, price, quantity |

## Services

### SupabaseService
Central service handling all backend operations:

```dart
// Authentication
- signUp(email, password, displayName)
- signIn(email, password)
- signOut()
- getCurrentUser()
- getUserProfile()

// Shopping Lists
- getShoppingLists()
- createShoppingList(name)
- updateShoppingList(id, name)
- deleteShoppingList(id)

// Shopping Items
- getShoppingItems(listId)
- createShoppingItem(listId, name, quantity)
- updateShoppingItem(id, {...})
- deleteShoppingItem(id)
- toggleItemBought(id, isBought)

// Storage
- uploadProfilePhoto(bytes, fileName)
- updateUserProfile(displayName, photoUrl)
```

## Screens

| Screen | File | Purpose |
|--------|------|---------|
| Login | `login_screen.dart` | Email/password authentication |
| Signup | `signup_screen.dart` | New user registration |
| Home Hub | `home_hub_screen.dart` | Bottom navigation container |
| Dashboard | `dashboard_screen.dart` | Stats cards, quick actions |
| Shopping Lists | `shopping_lists_screen.dart` | All user's lists |
| List Detail | `shopping_list_detail_screen.dart` | Items in a list |
| Analytics | `analytics_screen.dart` | Shopping insights |
| Profile | `profile_screen.dart` | User profile management |

## Widgets

| Widget | File | Purpose |
|--------|------|---------|
| CustomButton | `custom_button.dart` | Gradient button with loading state |
| CustomTextField | `custom_text_field.dart` | Styled input with validation |

## Design System

### Color Palette (Midnight Emerald)
- **Deep Space**: `#0B0F2A` - Main background
- **Midnight Blue**: `#111936` - Card surfaces
- **Emerald Glow**: `#27E8A7` - Primary accent
- **Purple Accent**: `#8B5CF6` - Secondary accent
- **Glass**: 85% opacity overlays

### Typography
- **Headings**: Poppins (Semi-Bold, Bold)
- **Body**: Inter (Regular, Medium)

### Effects
- Glassmorphism with 24px backdrop blur
- Gradient accents (emerald to purple)
- Smooth fade/slide animations

## Dependencies

```yaml
dependencies:
  flutter: sdk
  supabase_flutter: ^2.8.0   # Backend services
  provider: ^6.1.2           # State management
  google_fonts: ^6.2.1       # Custom typography
  file_picker: ^8.3.7        # Photo upload (web)
  intl: ^0.19.0              # Date formatting
  http: ^1.2.2               # HTTP requests
```

## Database Schema

### Tables
```sql
shopping_lists
├── id (uuid, primary key)
├── user_id (uuid, foreign key)
├── name (text)
├── created_at (timestamp)
└── updated_at (timestamp)

shopping_items
├── id (uuid, primary key)
├── list_id (uuid, foreign key)
├── name (text)
├── quantity (integer)
├── is_bought (boolean)
├── category (text, optional)
├── price (decimal, optional)
├── created_at (timestamp)
└── updated_at (timestamp)

user_profiles
├── id (uuid, primary key)
├── email (text)
├── display_name (text, optional)
├── photo_url (text, optional)
└── created_at (timestamp)
```

## Running the App

### Development
```bash
# Build for web
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Serve locally
python3 serve.py
```

### Deployment
The app is deployed as a static web build on port 5000.
