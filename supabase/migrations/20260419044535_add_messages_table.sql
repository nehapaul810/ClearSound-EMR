/*
  # Add Messages Table

  ## Summary
  Creates a messages table for direct messaging between users in the application.

  ## New Tables
  1. `messages`
     - Stores direct messages between users
     - `id` - UUID primary key
     - `sender_id` - UUID of the user sending the message
     - `recipient_id` - UUID of the user receiving the message
     - `content` - Text content of the message
     - `is_read` - Boolean flag for read status
     - `created_at` - Timestamp when message was sent

  ## Security
  - RLS enabled on messages table
  - Users can only view messages they sent or received
  - Users can only insert messages they're sending
  - Users can only update read status on messages they received
  - Indexes on sender_id, recipient_id, and created_at for query performance
*/

CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages they sent"
  ON messages FOR SELECT
  TO authenticated
  USING (auth.uid() = sender_id);

CREATE POLICY "Users can view messages they received"
  ON messages FOR SELECT
  TO authenticated
  USING (auth.uid() = recipient_id);

CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can mark their received messages as read"
  ON messages FOR UPDATE
  TO authenticated
  USING (auth.uid() = recipient_id)
  WITH CHECK (auth.uid() = recipient_id);

CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(sender_id, recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
