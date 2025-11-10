/*
  # User Interactions & Preferences Schema

  1. New Tables
    - `user_sessions` - Track user journey and session data
      - `id` (uuid, primary key)
      - `user_id` (uuid, from auth.users)
      - `started_at` (timestamp)
      - `ended_at` (timestamp, nullable)
      - `device_type` (text: desktop/tablet/mobile)
      - `last_slide_viewed` (integer)
      - `total_slides_viewed` (integer)
      - `source` (text: direct/referral/search)
      - `session_data` (jsonb: custom metadata)

    - `bookmarks` - Store user-saved slides and insights
      - `id` (uuid, primary key)
      - `user_id` (uuid, from auth.users)
      - `slide_id` (text)
      - `timestamp` (timestamp)
      - `note` (text, nullable)
      - `bookmark_type` (text: slide/insight/comparison)
      - `metadata` (jsonb: associated data)

    - `user_preferences` - Store personalization settings
      - `id` (uuid, primary key)
      - `user_id` (uuid, from auth.users, unique)
      - `theme` (text: dark/light)
      - `language` (text: vi/en)
      - `tour_mode` (text: none/student/researcher/policymaker/general)
      - `auto_play_enabled` (boolean)
      - `animation_intensity` (text: low/medium/high)
      - `accessibility_enabled` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `slide_interactions` - Track engagement with specific slides
      - `id` (uuid, primary key)
      - `user_id` (uuid, from auth.users)
      - `slide_id` (text)
      - `interaction_type` (text: view/expand/fullscreen/export/compare)
      - `duration_seconds` (integer)
      - `timestamp` (timestamp)
      - `data` (jsonb: interaction details)

    - `shared_insights` - Store shareable slide/data exports
      - `id` (uuid, primary key)
      - `user_id` (uuid, from auth.users, nullable for anonymous)
      - `share_token` (text, unique)
      - `slide_id` (text)
      - `metadata` (jsonb)
      - `created_at` (timestamp)
      - `expires_at` (timestamp, nullable)
      - `view_count` (integer, default 0)

  2. Security
    - Enable RLS on all tables
    - User-specific access policies
    - Public read access for shared insights
    - Proper authentication checks

  3. Performance
    - Create indexes on frequently queried columns
    - Composite indexes for common filter combinations
    - Partition strategy for large tables if needed
*/

CREATE TABLE IF NOT EXISTS user_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  started_at timestamptz DEFAULT now(),
  ended_at timestamptz,
  device_type text DEFAULT 'unknown',
  last_slide_viewed integer DEFAULT 0,
  total_slides_viewed integer DEFAULT 0,
  source text DEFAULT 'direct',
  session_data jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  slide_id text NOT NULL,
  timestamp timestamptz DEFAULT now(),
  note text,
  bookmark_type text DEFAULT 'slide',
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  theme text DEFAULT 'dark',
  language text DEFAULT 'vi',
  tour_mode text DEFAULT 'none',
  auto_play_enabled boolean DEFAULT false,
  animation_intensity text DEFAULT 'medium',
  accessibility_enabled boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS slide_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  slide_id text NOT NULL,
  interaction_type text NOT NULL,
  duration_seconds integer DEFAULT 0,
  timestamp timestamptz DEFAULT now(),
  data jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS shared_insights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  share_token text UNIQUE NOT NULL,
  slide_id text NOT NULL,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz,
  view_count integer DEFAULT 0
);

ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE slide_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions"
  ON user_sessions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own sessions"
  ON user_sessions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions"
  ON user_sessions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own bookmarks"
  ON bookmarks FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own bookmarks"
  ON bookmarks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks"
  ON bookmarks FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view own preferences"
  ON user_preferences FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own preferences"
  ON user_preferences FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
  ON user_preferences FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can create own interactions"
  ON slide_interactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own interactions"
  ON slide_interactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view public shared insights"
  ON shared_insights FOR SELECT
  USING (true);

CREATE POLICY "Users can create own shared insights"
  ON shared_insights FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update own shared insights"
  ON shared_insights FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_created_at ON user_sessions(created_at DESC);
CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_slide_id ON bookmarks(slide_id);
CREATE INDEX idx_slide_interactions_user_id ON slide_interactions(user_id);
CREATE INDEX idx_slide_interactions_slide_id ON slide_interactions(slide_id);
CREATE INDEX idx_shared_insights_token ON shared_insights(share_token);
