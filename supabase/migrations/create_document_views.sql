-- Create document_views table
CREATE TABLE document_views (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster analytics queries
CREATE INDEX idx_document_views_document_id ON document_views(document_id);
CREATE INDEX idx_document_views_user_id ON document_views(user_id);
