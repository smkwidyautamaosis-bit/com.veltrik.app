-- ============================================================
-- Jalankan script ini di Supabase SQL Editor
-- Storage Policies untuk bucket "avatars"
-- ============================================================

-- 1. Izinkan semua user yang terautentikasi untuk UPLOAD (INSERT)
INSERT INTO storage.policies (name, bucket_id, operation, definition)
VALUES (
  'Allow authenticated uploads',
  'avatars',
  'INSERT',
  'true'
) ON CONFLICT DO NOTHING;

-- 2. Izinkan semua orang untuk READ/SELECT (karena bucket public)
INSERT INTO storage.policies (name, bucket_id, operation, definition)
VALUES (
  'Allow public reads',
  'avatars',
  'SELECT',
  'true'
) ON CONFLICT DO NOTHING;

-- 3. Izinkan UPDATE (upsert)
INSERT INTO storage.policies (name, bucket_id, operation, definition)
VALUES (
  'Allow authenticated updates',
  'avatars',
  'UPDATE',
  'true'
) ON CONFLICT DO NOTHING;

-- ATAU gunakan cara yang lebih mudah dengan RLS policies:
-- Pergi ke Supabase Dashboard > Storage > avatars > Policies
-- Klik "New Policy" > "For full customization"
-- Policy name: "Allow all"
-- Allowed operation: SELECT, INSERT, UPDATE, DELETE
-- Target roles: (kosongkan = semua user)
-- USING expression: true
-- WITH CHECK expression: true
