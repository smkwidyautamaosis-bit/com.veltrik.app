class SupabaseConstants {
  static const String supabaseUrl = 'https://idfmdjtkvvjyqbffjugt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkZm1kanRrdnZqeXFiZmZqdWd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2MjgxNTUsImV4cCI6MjA5NTIwNDE1NX0.02lo4r_sbw51ywEYW_gE_9vwsJ6C0tQQkSXPRAq3Uoc';

  // Table Names
  static const String usersTable = 'users';
  static const String documentsTable = 'documents';
  static const String documentAccessTable = 'document_access';
  static const String sessionsTable = 'sessions';
  static const String notificationsTable = 'notifications';
  static const String inviteCodesTable = 'invite_codes';
  static const String creatorProfileTable = 'creator_profile';
  static const String adminConfigTable = 'admin_config';

  // Storage Buckets
  static const String pdfsBucket = 'veltrik-pdfs';
  static const String thumbnailsBucket = 'veltrik-thumbnails';
}
