import { createClient } from '@supabase/supabase-js';
import AsyncStorage from '@react-native-async-storage/async-storage';

const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

export const supabaseService = {
  async signUp(email, password, displayName) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { display_name: displayName }
      }
    });
    if (error) throw error;
    
    if (data.user) {
      await supabase.from('user_profiles').insert({
        id: data.user.id,
        email: email,
        display_name: displayName,
      });
    }
    return data;
  },

  async signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    return data;
  },

  async signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  getCurrentUser() {
    return supabase.auth.getUser();
  },

  async getSession() {
    const { data } = await supabase.auth.getSession();
    return data.session;
  },

  async getUserProfile() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', user.id)
      .single();
    
    if (error && error.code !== 'PGRST116') throw error;
    return data;
  },

  async updateUserProfile({ displayName, photoUrl }) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const updates = {};
    if (displayName !== undefined) updates.display_name = displayName;
    if (photoUrl !== undefined) updates.photo_url = photoUrl;
    updates.updated_at = new Date().toISOString();

    const { data, error } = await supabase
      .from('user_profiles')
      .upsert({ id: user.id, email: user.email, ...updates })
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async getShoppingLists() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const { data, error } = await supabase
      .from('shopping_lists')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data || [];
  },

  async createShoppingList(name) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const { data, error } = await supabase
      .from('shopping_lists')
      .insert({ name, user_id: user.id })
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async updateShoppingList(id, name) {
    const { data, error } = await supabase
      .from('shopping_lists')
      .update({ name, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async deleteShoppingList(id) {
    await supabase.from('shopping_items').delete().eq('list_id', id);
    
    const { error } = await supabase
      .from('shopping_lists')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
  },

  async getShoppingItems(listId) {
    const { data, error } = await supabase
      .from('shopping_items')
      .select('*')
      .eq('list_id', listId)
      .order('created_at', { ascending: true });
    
    if (error) throw error;
    return data || [];
  },

  async createShoppingItem(listId, name, quantity = 1) {
    const { data, error } = await supabase
      .from('shopping_items')
      .insert({ list_id: listId, name, quantity, is_bought: false })
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async updateShoppingItem(id, updates) {
    const { data, error } = await supabase
      .from('shopping_items')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async deleteShoppingItem(id) {
    const { error } = await supabase
      .from('shopping_items')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
  },

  async toggleItemBought(id, isBought) {
    return this.updateShoppingItem(id, { is_bought: isBought });
  },

  async uploadProfilePhoto(uri) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const response = await fetch(uri);
    const blob = await response.blob();
    
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => {
        const base64data = reader.result;
        resolve(base64data);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  },

  onAuthStateChange(callback) {
    return supabase.auth.onAuthStateChange(callback);
  }
};
