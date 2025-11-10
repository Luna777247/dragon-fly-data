import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('Supabase credentials not configured - features requiring auth will be disabled');
}

export const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '');

// User session management
export const sessionService = {
  async startSession(deviceType: 'desktop' | 'tablet' | 'mobile', source: string = 'direct') {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from('user_sessions')
      .insert({
        user_id: user.id,
        device_type: deviceType,
        source,
        started_at: new Date().toISOString()
      })
      .select()
      .maybeSingle();

    if (error) {
      console.error('Error starting session:', error);
      return null;
    }

    return data;
  },

  async updateSession(sessionId: string, lastSlide: number, totalViewed: number) {
    const { error } = await supabase
      .from('user_sessions')
      .update({
        last_slide_viewed: lastSlide,
        total_slides_viewed: totalViewed,
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId);

    if (error) {
      console.error('Error updating session:', error);
    }
  },

  async endSession(sessionId: string) {
    const { error } = await supabase
      .from('user_sessions')
      .update({ ended_at: new Date().toISOString() })
      .eq('id', sessionId);

    if (error) {
      console.error('Error ending session:', error);
    }
  }
};

// Bookmark management
export const bookmarkService = {
  async addBookmark(slideId: string, type: 'slide' | 'insight' | 'comparison', note?: string, metadata?: Record<string, any>) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from('bookmarks')
      .insert({
        user_id: user.id,
        slide_id: slideId,
        bookmark_type: type,
        note,
        metadata: metadata || {}
      })
      .select()
      .maybeSingle();

    if (error) {
      console.error('Error adding bookmark:', error);
      return null;
    }

    return data;
  },

  async getBookmarks() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return [];

    const { data, error } = await supabase
      .from('bookmarks')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching bookmarks:', error);
      return [];
    }

    return data || [];
  },

  async removeBookmark(bookmarkId: string) {
    const { error } = await supabase
      .from('bookmarks')
      .delete()
      .eq('id', bookmarkId);

    if (error) {
      console.error('Error removing bookmark:', error);
      return false;
    }

    return true;
  }
};

// User preferences
export const preferenceService = {
  async getPreferences() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from('user_preferences')
      .select('*')
      .eq('user_id', user.id)
      .maybeSingle();

    if (error) {
      console.error('Error fetching preferences:', error);
      return null;
    }

    return data;
  },

  async updatePreferences(preferences: Record<string, any>) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from('user_preferences')
      .upsert({
        user_id: user.id,
        ...preferences,
        updated_at: new Date().toISOString()
      })
      .select()
      .maybeSingle();

    if (error) {
      console.error('Error updating preferences:', error);
      return null;
    }

    return data;
  }
};

// Slide interactions tracking
export const interactionService = {
  async trackInteraction(
    slideId: string,
    interactionType: 'view' | 'expand' | 'fullscreen' | 'export' | 'compare',
    durationSeconds: number = 0,
    data?: Record<string, any>
  ) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const { data: result, error } = await supabase
      .from('slide_interactions')
      .insert({
        user_id: user.id,
        slide_id: slideId,
        interaction_type: interactionType,
        duration_seconds: durationSeconds,
        data: data || {}
      })
      .select()
      .maybeSingle();

    if (error) {
      console.error('Error tracking interaction:', error);
      return null;
    }

    return result;
  },

  async getInteractionStats(slideId?: string) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    let query = supabase
      .from('slide_interactions')
      .select('*')
      .eq('user_id', user.id);

    if (slideId) {
      query = query.eq('slide_id', slideId);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching interaction stats:', error);
      return null;
    }

    return data;
  }
};

// Shared insights
export const sharingService = {
  async createShare(slideId: string, metadata?: Record<string, any>) {
    const { data: { user } } = await supabase.auth.getUser();

    const shareToken = `share_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    const { data, error } = await supabase
      .from('shared_insights')
      .insert({
        user_id: user?.id || null,
        share_token: shareToken,
        slide_id: slideId,
        metadata: metadata || {},
        expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString() // 30 days
      })
      .select()
      .maybeSingle();

    if (error) {
      console.error('Error creating share:', error);
      return null;
    }

    return data;
  },

  async getSharedInsight(shareToken: string) {
    const { data, error } = await supabase
      .from('shared_insights')
      .select('*')
      .eq('share_token', shareToken)
      .maybeSingle();

    if (error) {
      console.error('Error fetching shared insight:', error);
      return null;
    }

    // Increment view count
    if (data) {
      supabase
        .from('shared_insights')
        .update({ view_count: (data.view_count || 0) + 1 })
        .eq('share_token', shareToken)
        .then();
    }

    return data;
  },

  async getMyShares() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return [];

    const { data, error } = await supabase
      .from('shared_insights')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching shares:', error);
      return [];
    }

    return data || [];
  }
};
