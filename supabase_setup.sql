-- ============================================
-- SUPABASE DATABASE SETUP FOR SHOPPING LIST APP
-- ============================================
-- Copy and paste this entire file into your Supabase SQL Editor
-- and click "Run" to create all tables and security policies
-- ============================================

-- Step 1: Create shopping_lists table
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

-- Step 2: Create shopping_items table
CREATE TABLE IF NOT EXISTS shopping_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity TEXT,
  notes TEXT,
  is_bought BOOLEAN DEFAULT FALSE,
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

-- ============================================
-- SETUP COMPLETE!
-- ============================================
-- Your database is now ready. Go back to your app and:
-- 1. Refresh the page
-- 2. Click "Sign Up" to create a new account
-- 3. Start creating shopping lists!
-- ============================================
