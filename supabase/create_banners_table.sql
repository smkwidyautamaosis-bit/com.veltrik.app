-- SQL Script: Create banners table for Veltrik
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS banners (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  description text,
  image_url text,
  is_active boolean DEFAULT true,
  "order" integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read active banners" ON banners;
CREATE POLICY "Public read active banners" ON banners 
  FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Admin full access banners" ON banners;
CREATE POLICY "Admin full access banners" ON banners 
  USING (true) WITH CHECK (true);
