-- ============================================
-- MIGRATION: Add Advanced Features to Existing Database
-- This script safely adds new columns and tables to your existing shopping app
-- Run this in your Supabase SQL Editor
-- ============================================

-- Step 1: Add new columns to existing shopping_items table
DO $$ 
BEGIN
    -- Add category column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='shopping_items' AND column_name='category') THEN
        ALTER TABLE shopping_items ADD COLUMN category TEXT DEFAULT 'other';
        ALTER TABLE shopping_items ADD CONSTRAINT shopping_items_category_check 
            CHECK (category IN ('produce', 'dairy', 'meat', 'bakery', 'frozen', 'beverages', 'snacks', 'household', 'personal_care', 'other'));
    END IF;

    -- Add price column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='shopping_items' AND column_name='price') THEN
        ALTER TABLE shopping_items ADD COLUMN price DECIMAL(10, 2);
    END IF;

    -- Add bought_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='shopping_items' AND column_name='bought_count') THEN
        ALTER TABLE shopping_items ADD COLUMN bought_count INTEGER DEFAULT 0;
    END IF;

    -- Add last_bought_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='shopping_items' AND column_name='last_bought_at') THEN
        ALTER TABLE shopping_items ADD COLUMN last_bought_at TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- Step 2: Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);

-- Step 3: Create user_preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  dark_mode BOOLEAN DEFAULT FALSE,
  default_category TEXT DEFAULT 'other' CHECK (default_category IN ('produce', 'dairy', 'meat', 'bakery', 'frozen', 'beverages', 'snacks', 'household', 'personal_care', 'other')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view own preferences" ON user_preferences;
CREATE POLICY "Users can view own preferences" ON user_preferences FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own preferences" ON user_preferences;
CREATE POLICY "Users can insert own preferences" ON user_preferences FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own preferences" ON user_preferences;
CREATE POLICY "Users can update own preferences" ON user_preferences FOR UPDATE USING (auth.uid() = id);

-- Step 4: Create purchase_history table
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

-- Enable RLS
ALTER TABLE purchase_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view own purchase history" ON purchase_history;
CREATE POLICY "Users can view own purchase history" ON purchase_history FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own purchase history" ON purchase_history;
CREATE POLICY "Users can insert own purchase history" ON purchase_history FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Step 5: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_purchase_history_user_id ON purchase_history(user_id);
CREATE INDEX IF NOT EXISTS idx_purchase_history_bought_at ON purchase_history(bought_at);
CREATE INDEX IF NOT EXISTS idx_purchase_history_item_name ON purchase_history(item_name);
CREATE INDEX IF NOT EXISTS idx_shopping_items_bought_count ON shopping_items(bought_count);

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

-- Step 7: Create function to auto-update updated_at for shopping_lists
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

-- Step 8: Create storage bucket for profile photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS policies
DROP POLICY IF EXISTS "Users can upload own profile photos" ON storage.objects;
CREATE POLICY "Users can upload own profile photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Users can update own profile photos" ON storage.objects;
CREATE POLICY "Users can update own profile photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Users can delete own profile photos" ON storage.objects;
CREATE POLICY "Users can delete own profile photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Profile photos are publicly accessible" ON storage.objects;
CREATE POLICY "Profile photos are publicly accessible"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-photos');

-- Step 9: Backfill existing data with safe defaults
UPDATE shopping_items 
SET bought_count = 0 
WHERE bought_count IS NULL;

-- ============================================
-- Migration Complete!
-- ============================================
-- Your database now has:
-- ✅ Category, price, and analytics fields on shopping_items
-- ✅ User profiles table
-- ✅ User preferences table
-- ✅ Purchase history table
-- ✅ Automatic purchase tracking
-- ✅ Auto-updating timestamps
-- ✅ Profile photo storage with RLS
-- ============================================
