import { supabase } from './supabase';

export const messagesService = {
  async sendMessage(recipientId, content) {
    const { data, error } = await supabase
      .from('messages')
      .insert({
        recipient_id: recipientId,
        content,
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  async getConversation(userId) {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .or(
        `and(sender_id.eq.${userId}),and(recipient_id.eq.${userId})`
      )
      .order('created_at', { ascending: true });

    if (error) throw error;
    return data;
  },

  async getInbox() {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  },

  async markAsRead(messageId) {
    const { data, error } = await supabase
      .from('messages')
      .update({ is_read: true })
      .eq('id', messageId)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  async getUnreadCount() {
    const { data, error } = await supabase
      .from('messages')
      .select('id', { count: 'exact', head: 0 })
      .eq('is_read', false);

    if (error) throw error;
    return data?.length || 0;
  },
};
