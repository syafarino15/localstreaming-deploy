-- ============================================================================
-- POV / initial database provisioning
--
-- The official postgres image creates POSTGRES_DB (stayin_main) on first boot.
-- This script adds the SECOND database so the two applications never share one
-- database object. It runs only while the data directory is empty, which is the
-- correct moment for provisioning.
--
-- stayin_main  = server utama: CMS, katalog master, distribusi, akun admin
-- stayin_local = server lokal kapal: TV, streaming, mst_movie_local, layout
-- ============================================================================

SELECT 'CREATE DATABASE stayin_local OWNER ' || quote_ident(current_user)
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'stayin_local')\gexec

SELECT 'CREATE DATABASE stayin_main OWNER ' || quote_ident(current_user)
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'stayin_main')\gexec
