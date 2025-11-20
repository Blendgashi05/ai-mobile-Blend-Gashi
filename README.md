# Shopping List App

A modern, full-featured shopping list application built with Flutter and Supabase. This app allows users to create, manage, and organize their shopping lists with a clean, intuitive interface.

## Features

- **User Authentication**: Secure email/password signup and login
- **Shopping Lists**: Create and manage multiple shopping lists
- **Shopping Items**: Add items with quantities, notes, and mark as bought
- **Real-time Sync**: All data syncs with Supabase backend
- **Modern UI**: Clean, responsive design with Material 3
- **Input Validation**: Comprehensive form validation and error handling
- **Loading States**: User-friendly loading indicators throughout

## Tech Stack

- **Frontend**: Flutter (Dart 3.8)
- **Backend**: Supabase (Authentication & PostgreSQL Database)
- **State Management**: Provider pattern
- **Architecture**: Clean folder structure with separation of concerns

## Project Structure

```
lib/
├── models/              # Data models
│   ├── shopping_list.dart
│   └── shopping_item.dart
├── services/            # Business logic and API calls
│   └── supabase_service.dart
├── screens/             # UI screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── shopping_lists_screen.dart
│   └── shopping_list_detail_screen.dart
├── widgets/             # Reusable UI components
│   ├── custom_button.dart
│   └── custom_text_field.dart
└── main.dart            # App entry point
```

## Prerequisites

Before running this app, you need:

1. **Supabase Account**: Create a free account at [supabase.com](https://supabase.com)
2. **Supabase Project**: Set up a new project in your Supabase dashboard

## Supabase Database Setup

You need to create two tables in your Supabase database. Run these SQL commands in the Supabase SQL Editor:

### 1. Shopping Lists Table

```sql
-- Create shopping_lists table
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage their own lists
CREATE POLICY "Users can manage their own shopping lists"
  ON shopping_lists
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create index for performance
CREATE INDEX idx_shopping_lists_user_id ON shopping_lists(user_id);
```

### 2. Shopping Items Table

```sql
-- Create shopping_items table
CREATE TABLE shopping_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity TEXT,
  notes TEXT,
  is_bought BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage items in their lists
CREATE POLICY "Users can manage items in their own lists"
  ON shopping_items
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_items.list_id
      AND shopping_lists.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_items.list_id
      AND shopping_lists.user_id = auth.uid()
    )
  );

-- Create index for performance
CREATE INDEX idx_shopping_items_list_id ON shopping_items(list_id);
```

## Environment Variables

This app requires two Supabase credentials stored as environment variables:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous/public key

### Finding Your Credentials

1. Go to your Supabase project dashboard
2. Navigate to **Settings** → **API**
3. Copy the **Project URL** (this is your `SUPABASE_URL`)
4. Copy the **anon public** key (this is your `SUPABASE_ANON_KEY`)

### Setting Environment Variables (Replit)

The environment variables are already configured in Replit Secrets. No additional setup needed!

### Setting Environment Variables (Local Development)

If running locally, you can pass them as compile-time variables:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=your_url_here --dart-define=SUPABASE_ANON_KEY=your_key_here
```

## Running the App

### On Replit

1. Click the **Run** button
2. The app will open in the browser preview
3. Create an account or sign in to start using the app

### Local Development

1. **Install Flutter**: Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install)

2. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd shopping_list_app
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run -d chrome --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
   ```

## Usage Guide

### 1. Sign Up / Login
- Create a new account with email and password (minimum 6 characters)
- Or login with existing credentials

### 2. Create Shopping Lists
- Tap the **+** button on the main screen
- Enter a name and optional description for your list
- Tap **Create** to save

### 3. Manage Lists
- Tap a list to view its items
- Use the menu (⋮) to edit or delete lists

### 4. Add Items
- Open a shopping list
- Tap the **+** button
- Enter item name, quantity (optional), and notes (optional)
- Tap **Add** to save

### 5. Mark Items as Bought
- Tap the checkbox next to an item to mark it as bought
- Bought items appear in a separate section with strikethrough text

### 6. Edit/Delete Items
- Use the menu (⋮) on each item to edit or delete

### 7. Logout
- Tap the logout icon in the top-right corner

## Features Highlights

### Authentication
- Secure email/password authentication via Supabase Auth
- Form validation with helpful error messages
- Persistent login sessions

### Data Management
- Full CRUD operations for shopping lists and items
- Real-time data sync with Supabase PostgreSQL
- Optimistic UI updates for smooth user experience

### UI/UX
- Material 3 design with modern theming
- Responsive layouts
- Loading states and error handling
- Pull-to-refresh functionality
- Empty states with helpful guidance

### Code Quality
- Clean architecture with separation of concerns
- Comprehensive error handling
- Input validation throughout
- Well-commented, production-ready code
- Reusable components and widgets

## Development Notes

### Adding New Features

The codebase is structured to make it easy to extend:

- **New screens**: Add to `lib/screens/`
- **New models**: Add to `lib/models/`
- **New services**: Add to `lib/services/`
- **New widgets**: Add to `lib/widgets/`

### Database Migrations

If you need to modify the database schema:

1. Create a new migration in Supabase SQL Editor
2. Update the corresponding Dart models in `lib/models/`
3. Update service methods in `lib/services/supabase_service.dart`

## Security

- Row Level Security (RLS) is enabled on all tables
- Users can only access their own data
- API keys are stored as environment variables (never in code)
- Passwords are hashed by Supabase Auth

## Troubleshooting

### "Missing Supabase credentials" Error
- Ensure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set correctly
- On Replit, check the Secrets panel
- Locally, verify your `--dart-define` arguments

### Database Errors
- Verify the database tables are created with the SQL above
- Check that Row Level Security policies are in place
- Ensure your user is authenticated

### Authentication Issues
- Email must be valid format
- Password must be at least 6 characters
- Check Supabase Auth settings allow email signup

## License

This project is open source and available under the MIT License.

## Credits

Built with Flutter and Supabase for a modern, scalable shopping list experience.
