-- ═══════════════════════════════════════════
-- YZY CRM · Supabase Database Schema
-- Execute este script no SQL Editor do Supabase
-- Modo: uso pessoal (sem autenticacao / RLS)
-- ═══════════════════════════════════════════

-- ───── FOLDERS ─────
CREATE TABLE IF NOT EXISTS folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  parent_id UUID REFERENCES folders(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ───── PROJECTS ─────
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  folder_id UUID REFERENCES folders(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'completed', 'blocked', 'archived')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  company TEXT CHECK (company IN ('SOLAIRE', 'AVANTE', 'PESSOAL')),
  due_date DATE,
  url TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add image_url column if it doesn't exist (for existing tables)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'image_url') THEN
    ALTER TABLE projects ADD COLUMN image_url TEXT;
  END IF;
END $$;

-- Ensure archived status is supported on existing projects tables
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE table_name = 'projects'
      AND constraint_name = 'projects_status_check'
  ) THEN
    ALTER TABLE projects DROP CONSTRAINT projects_status_check;
  END IF;

  ALTER TABLE projects
    ADD CONSTRAINT projects_status_check
    CHECK (status IN ('todo', 'in_progress', 'review', 'completed', 'blocked', 'archived'));
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ───── MEETINGS ─────
CREATE TABLE IF NOT EXISTS meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  time TIME,
  duration_minutes INTEGER DEFAULT 30,
  company TEXT CHECK (company IN ('SOLAIRE', 'AVANTE', 'PESSOAL')),
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'done', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ───── NOTES ─────
CREATE TABLE IF NOT EXISTS notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════ INDEXES ═══════════
CREATE INDEX IF NOT EXISTS idx_folders_user ON folders(user_id);
CREATE INDEX IF NOT EXISTS idx_folders_parent ON folders(parent_id);
CREATE INDEX IF NOT EXISTS idx_projects_user ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_folder ON projects(folder_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_company ON projects(company);
CREATE INDEX IF NOT EXISTS idx_meetings_user ON meetings(user_id);
CREATE INDEX IF NOT EXISTS idx_meetings_date ON meetings(date);
CREATE INDEX IF NOT EXISTS idx_meetings_project ON meetings(project_id);
CREATE INDEX IF NOT EXISTS idx_notes_project ON notes(project_id);

-- ═══════════ FUNCTIONS (auto-update updated_at) ═══════════
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS folders_updated_at ON folders;
DROP TRIGGER IF EXISTS projects_updated_at ON projects;

CREATE TRIGGER folders_updated_at BEFORE UPDATE ON folders FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ═══════════ Disable RLS (uso pessoal, sem auth) ═══════════
ALTER TABLE folders DISABLE ROW LEVEL SECURITY;
ALTER TABLE projects DISABLE ROW LEVEL SECURITY;
ALTER TABLE meetings DISABLE ROW LEVEL SECURITY;
ALTER TABLE notes DISABLE ROW LEVEL SECURITY;

-- ═══════════ Remove FK to auth.users (schema antigo) ═══════════
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'folders_user_id_fkey' AND table_name = 'folders') THEN
    ALTER TABLE folders DROP CONSTRAINT folders_user_id_fkey;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'projects_user_id_fkey' AND table_name = 'projects') THEN
    ALTER TABLE projects DROP CONSTRAINT projects_user_id_fkey;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'meetings_user_id_fkey' AND table_name = 'meetings') THEN
    ALTER TABLE meetings DROP CONSTRAINT meetings_user_id_fkey;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'notes_user_id_fkey' AND table_name = 'notes') THEN
    ALTER TABLE notes DROP CONSTRAINT notes_user_id_fkey;
  END IF;
END $$;

-- ───── PROJECT IMAGES ─────
CREATE TABLE IF NOT EXISTS project_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_images_project ON project_images(project_id);

-- ═══════════ Drop old RLS policies (schema antigo) ═══════════
DROP POLICY IF EXISTS folders_select_policy ON folders;
DROP POLICY IF EXISTS folders_insert_policy ON folders;
DROP POLICY IF EXISTS folders_update_policy ON folders;
DROP POLICY IF EXISTS folders_delete_policy ON folders;
DROP POLICY IF EXISTS projects_select_policy ON projects;
DROP POLICY IF EXISTS projects_insert_policy ON projects;
DROP POLICY IF EXISTS projects_update_policy ON projects;
DROP POLICY IF EXISTS projects_delete_policy ON projects;
DROP POLICY IF EXISTS meetings_select_policy ON meetings;
DROP POLICY IF EXISTS meetings_insert_policy ON meetings;
DROP POLICY IF EXISTS meetings_update_policy ON meetings;
DROP POLICY IF EXISTS meetings_delete_policy ON meetings;
DROP POLICY IF EXISTS notes_select_policy ON notes;
DROP POLICY IF EXISTS notes_insert_policy ON notes;
DROP POLICY IF EXISTS notes_update_policy ON notes;
DROP POLICY IF EXISTS notes_delete_policy ON notes;

-- ═══════════ STORAGE BUCKET & POLICIES (upload de imagens) ═══════════
-- 1. Cria o bucket (ignora se ja existe)
INSERT INTO storage.buckets (id, name, public, avif_autodetection, file_size_limit, allowed_mime_types)
VALUES ('project-images', 'project-images', true, false, 5242880, ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET public = true, file_size_limit = 5242880, allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];

-- 2. Policies do storage (anon pode ler, inserir e deletar)
DROP POLICY IF EXISTS "Allow public select project-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public insert project-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public delete project-images" ON storage.objects;

CREATE POLICY "Allow public select project-images"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'project-images');

CREATE POLICY "Allow public insert project-images"
ON storage.objects FOR INSERT
TO anon, authenticated
WITH CHECK (bucket_id = 'project-images');

CREATE POLICY "Allow public delete project-images"
ON storage.objects FOR DELETE
TO anon, authenticated
USING (bucket_id = 'project-images');
