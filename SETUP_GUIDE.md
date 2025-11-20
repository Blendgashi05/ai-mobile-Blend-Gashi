# Quick Setup Guide - Fix "Failed to fetch shopping lists" Error

## The Problem
Your app is trying to fetch shopping lists from Supabase, but the database tables don't exist yet.

## The Solution (5 minutes)
Follow these steps to create the required database tables:

### Step 1: Open Your Supabase Dashboard
1. Go to [supabase.com](https://supabase.com)
2. Sign in to your account
3. Select the project you're using for this app

### Step 2: Open the SQL Editor
1. In the left sidebar, click **SQL Editor**
2. Click **+ New Query** button

### Step 3: Run the Setup SQL
1. Open the `supabase_setup.sql` file in this project
2. **Copy the entire contents** of that file
3. **Paste** it into the Supabase SQL Editor
4. Click the **Run** button (or press Ctrl+Enter)

You should see a success message!

### Step 4: Verify Tables Were Created
1. In Supabase left sidebar, click **Table Editor**
2. You should now see two tables:
   - ✅ `shopping_lists`
   - ✅ `shopping_items`

### Step 5: Test Your App
1. Come back to this Replit app
2. **Refresh the browser page**
3. Click **Sign Up** to create a new account
4. The error should be gone!

---

## What Did This Do?

The SQL script created:
- **shopping_lists table**: Stores your shopping lists with names and descriptions
- **shopping_items table**: Stores items within each list (name, quantity, notes, bought status)
- **Security Policies**: Ensures users can only see their own data (Row Level Security)
- **Performance Indexes**: Makes queries faster

---

## Still Having Issues?

### Error: "relation shopping_lists already exists"
This means the tables are already created. You're good to go! Just refresh the app.

### Error: Authentication issues
Make sure you're creating a **new account** after setting up the database. Old test accounts won't have the proper permissions.

### Error: Still seeing "Failed to fetch shopping lists"
1. Make sure you're logged in (created an account)
2. Check that both tables exist in Supabase Table Editor
3. Verify Row Level Security is enabled on both tables

---

## Need Help?
Check the main `README.md` file for more detailed documentation.
