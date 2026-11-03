INSERT INTO api_keys (name, key_hash, is_active)
VALUES ('local-dev-key', 'c709867c218606676b2b1ee84ea7afab71747c44c866fafb6cda36006aaf3656', true)
ON CONFLICT (key_hash) DO NOTHING;
