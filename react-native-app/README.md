# Shopping List App - React Native / Expo

A modern, premium shopping list application built with React Native and Expo, featuring the same beautiful glassmorphism UI as the Flutter version.

## Features

- Email/password authentication with Supabase
- Full CRUD operations for shopping lists and items
- Modern glassmorphism dark theme (Midnight Emerald)
- Bottom navigation with Dashboard, Analytics, Profile tabs
- Profile photo upload
- Real-time shopping statistics
- Animated floating orbs on auth screens
- Gradient accents and smooth animations

## Running on Expo Snack

### Step 1: Create New Snack
1. Go to [snack.expo.dev](https://snack.expo.dev)
2. Create a new Snack

### Step 2: Add Dependencies
In the Snack, click on the package icon and add these dependencies:
```
@react-navigation/native
@react-navigation/native-stack
@react-navigation/bottom-tabs
react-native-screens
react-native-safe-area-context
@supabase/supabase-js
expo-linear-gradient
expo-blur
expo-image-picker
expo-font
@expo-google-fonts/poppins
@expo-google-fonts/inter
@react-native-async-storage/async-storage
```

### Step 3: Configure Supabase
Open `src/services/supabaseService.js` and replace:
```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```
With your actual Supabase project credentials.

### Step 4: Copy Files
Copy all files from this `react-native-app` folder to your Snack:
- `App.js` - Main app entry
- `src/screens/` - All screen components
- `src/components/` - Reusable UI components
- `src/services/` - Supabase service
- `src/theme/` - Colors, typography, spacing

### Step 5: Database Setup
Make sure your Supabase database has these tables:

```sql
-- User profiles table
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Shopping lists table
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Shopping items table
CREATE TABLE shopping_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID REFERENCES shopping_lists(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  is_bought BOOLEAN DEFAULT FALSE,
  category TEXT,
  price DECIMAL(10,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage own lists" ON shopping_lists
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage items in own lists" ON shopping_items
  FOR ALL USING (
    list_id IN (
      SELECT id FROM shopping_lists WHERE user_id = auth.uid()
    )
  );
```

### Step 6: Storage Setup (Optional)
For profile photo uploads, create a storage bucket:
1. Go to Supabase Dashboard > Storage
2. Create a new bucket called `profile-photos`
3. Make it public
4. Add policy to allow authenticated users to upload

## Project Structure

```
react-native-app/
├── App.js                 # Main app with navigation
├── src/
│   ├── components/        # Reusable UI components
│   │   ├── GlassCard.js
│   │   ├── CustomButton.js
│   │   ├── CustomTextField.js
│   │   └── GradientBackground.js
│   ├── screens/           # App screens
│   │   ├── LoginScreen.js
│   │   ├── SignupScreen.js
│   │   ├── HomeHubScreen.js
│   │   ├── DashboardScreen.js
│   │   ├── ShoppingListsScreen.js
│   │   ├── ShoppingListDetailScreen.js
│   │   ├── AnalyticsScreen.js
│   │   └── ProfileScreen.js
│   ├── services/          # Backend services
│   │   └── supabaseService.js
│   └── theme/             # Design system
│       ├── colors.js
│       ├── typography.js
│       └── spacing.js
└── package.json
```

## Design System

### Colors (Midnight Emerald Theme)
- **Deep Space**: `#0B0F2A` (background)
- **Midnight Blue**: `#111936` (surfaces)
- **Emerald Glow**: `#27E8A7` (primary accent)
- **Purple Accent**: `#8B5CF6` (secondary accent)
- **Glass**: 85% opacity overlays

### Typography
- **Headings**: Poppins (Semi-Bold, Bold)
- **Body**: Inter (Regular, Medium)

### Effects
- Glassmorphism with expo-blur
- LinearGradient accents
- Animated floating orbs
- Smooth fade/slide transitions

## Comparison with Flutter Version

| Feature | Flutter | React Native |
|---------|---------|--------------|
| Language | Dart | JavaScript |
| UI Framework | Flutter Widgets | React Native + Expo |
| Blur Effect | BackdropFilter | expo-blur |
| Gradients | LinearGradient | expo-linear-gradient |
| Image Picker | file_picker | expo-image-picker |
| Animations | AnimationController | Animated API |
| Navigation | Navigator | React Navigation |

Both versions maintain the same:
- Visual design and color scheme
- Screen layouts and functionality
- Supabase integration
- User experience

## Troubleshooting

### "Module not found" errors
Make sure all dependencies are installed in Expo Snack.

### Auth not working
Verify your Supabase URL and anon key are correct.

### Photos not uploading
Create the `profile-photos` bucket in Supabase Storage.

### Blur not showing on web
expo-blur has limited web support; effects may appear differently.

## License

MIT License - Free to use and modify.
