-- ============================================
-- ADVANCED SUPABASE DATABASE SETUP FOR SHOPPING LIST APP
-- ============================================
-- Copy and paste this entire file into your Supabase SQL Editor
-- and click "Run" to create all tables and security policies
-- ============================================

-- Step 1: Create user_profiles table for profile management
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security for user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only manage their own profile
DROP POLICY IF EXISTS "Users can manage their own profile" ON user_profiles;
CREATE POLICY "Users can manage their own profile"
  ON user_profiles
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================

-- Step 2: Create user_preferences table for settings
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  dark_mode BOOLEAN DEFAULT FALSE,
  default_category TEXT DEFAULT 'other',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security for user_preferences
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only manage their own preferences
DROP POLICY IF EXISTS "Users can manage their own preferences" ON user_preferences;
CREATE POLICY "Users can manage their own preferences"
  ON user_preferences
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================

-- Step 3: Create shopping_lists table
CREATE TABLE IF NOT EXISTS shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security for shopping_lists
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only manage their own lists
DROP POLICY IF EXISTS "Users can manage their own shopping lists" ON shopping_lists;
CREATE POLICY "Users can manage their own shopping lists"
  ON shopping_lists
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_shopping_lists_user_id ON shopping_lists(user_id);

-- ============================================

-- Step 4: Create shopping_items table with advanced fields
CREATE TABLE IF NOT EXISTS shopping_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity TEXT,
  notes TEXT,
  category TEXT DEFAULT 'other' CHECK (category IN ('produce', 'dairy', 'meat', 'bakery', 'frozen', 'beverages', 'snacks', 'household', 'personal_care', 'other')),
  price DECIMAL(10, 2),
  is_bought BOOLEAN DEFAULT FALSE,
  bought_count INTEGER DEFAULT 0,
  last_bought_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security for shopping_items
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only manage items in their own lists
DROP POLICY IF EXISTS "Users can manage items in their own lists" ON shopping_items;
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

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_shopping_items_list_id ON shopping_items(list_id);
CREATE INDEX IF NOT EXISTS idx_shopping_items_category ON shopping_items(category);
CREATE INDEX IF NOT EXISTS idx_shopping_items_bought_count ON shopping_items(bought_count);

-- ============================================

-- Step 5: Create purchase_history table for analytics
CREATE TABLE IF NOT EXISTS purchase_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_id UUID,
  item_name TEXT NOT NULL,
  category TEXT CHECK (category IN ('produce', 'dairy', 'meat', 'bakery', 'frozen', 'beverages', 'snacks', 'household', 'personal_care', 'other')),
  price DECIMAL(10, 2),
  quantity TEXT,
  bought_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  list_name TEXT
);

-- Enable Row Level Security for purchase_history
ALTER TABLE purchase_history ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only view their own purchase history
DROP POLICY IF EXISTS "Users can manage their own purchase history" ON purchase_history;
CREATE POLICY "Users can manage their own purchase history"
  ON purchase_history
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create indexes for analytics queries
CREATE INDEX IF NOT EXISTS idx_purchase_history_user_id ON purchase_history(user_id);
CREATE INDEX IF NOT EXISTS idx_purchase_history_bought_at ON purchase_history(bought_at);
CREATE INDEX IF NOT EXISTS idx_purchase_history_category ON purchase_history(category);
CREATE INDEX IF NOT EXISTS idx_purchase_history_item_name ON purchase_history(item_name);

-- ============================================

-- Step 6: Create function to track purchases
CREATE OR REPLACE FUNCTION track_item_purchase()
RETURNS TRIGGER AS $$
BEGIN
  -- If item was just marked as bought (prevent redundant TRUE→TRUE updates)
  IF NEW.is_bought = TRUE AND (OLD.is_bought = FALSE OR OLD.is_bought IS NULL) THEN
    -- Update bought count (use COALESCE to handle NULL) and last bought timestamp
    NEW.bought_count := COALESCE(OLD.bought_count, 0) + 1;
    NEW.last_bought_at := NOW();
    
    -- Insert into purchase history with item_id for dimensional joins
    INSERT INTO purchase_history (user_id, item_id, item_name, category, price, quantity, list_name)
    SELECT 
      sl.user_id,
      NEW.id,
      NEW.name,
      NEW.category,
      NEW.price,
      NEW.quantity,
      sl.name
    FROM shopping_lists sl
    WHERE sl.id = NEW.list_id;
  END IF;
  
  -- Always update the updated_at timestamp
  NEW.updated_at := NOW();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tracking purchases and updated_at
DROP TRIGGER IF EXISTS track_purchase_trigger ON shopping_items;
CREATE TRIGGER track_purchase_trigger
  BEFORE UPDATE ON shopping_items
  FOR EACH ROW
  EXECUTE FUNCTION track_item_purchase();

-- Create function to auto-update updated_at for shopping_lists
CREATE OR REPLACE FUNCTION update_shopping_list_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for shopping_lists updated_at
DROP TRIGGER IF EXISTS update_shopping_list_timestamp_trigger ON shopping_lists;
CREATE TRIGGER update_shopping_list_timestamp_trigger
  BEFORE UPDATE ON shopping_lists
  FOR EACH ROW
  EXECUTE FUNCTION update_shopping_list_timestamp();

-- ============================================

-- Step 7: Create storage bucket for profile photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage policy: Users can upload their own profile photos
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
CREATE POLICY "Users can upload their own profile photos"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Create storage policy: Users can update their own profile photos
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
CREATE POLICY "Users can update their own profile photos"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Create storage policy: Users can delete their own profile photos
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;
CREATE POLICY "Users can delete their own profile photos"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Create storage policy: Everyone can view profile photos
DROP POLICY IF EXISTS "Profile photos are publicly accessible" ON storage.objects;
CREATE POLICY "Profile photos are publicly accessible"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'profile-photos');

-- ============================================
-- SETUP COMPLETE!
-- ============================================
-- Your advanced database is now ready with:
-- ✅ User profiles with photo upload support
-- ✅ User preferences (dark mode, etc.)
-- ✅ Shopping lists and items with categories and prices
-- ✅ Purchase history tracking for analytics
-- ✅ Automatic purchase tracking trigger
-- ✅ Storage bucket for profile photos
--
-- Categories supported:
-- - produce (fruits, vegetables)
-- - dairy (milk, cheese, yogurt)
-- - meat (chicken, beef, pork)
-- - bakery (bread, pastries)
-- - frozen (ice cream, frozen meals)
-- - beverages (drinks, juice)
-- - snacks (chips, candy)
-- - household (cleaning supplies)
-- - personal_care (toiletries)
-- - other (miscellaneous)
--
-- Go back to your app and start using the new features!
-- ============================================
