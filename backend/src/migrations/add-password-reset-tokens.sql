-- Migration: Add password reset tokens table
-- Description: Table to store password reset tokens with expiration

DROP TABLE IF EXISTS t_password_reset_token CASCADE;
CREATE TABLE t_password_reset_token (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" uuid NOT NULL REFERENCES t_user(id) ON DELETE CASCADE,
  "token" text NOT NULL UNIQUE,
  "expiresAt" timestamptz NOT NULL,
  "used" boolean NOT NULL DEFAULT false,
  "createdAt" timestamptz DEFAULT now() NOT NULL,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_password_reset_token IS 'Tokens para resetear contraseñas de usuarios';
COMMENT ON COLUMN t_password_reset_token."token" IS 'Token de 6 dígitos para resetear contraseña';
COMMENT ON COLUMN t_password_reset_token."expiresAt" IS 'Fecha de expiración del token';
COMMENT ON COLUMN t_password_reset_token."used" IS 'Indica si el token ya fue utilizado';

-- Índices para optimización
CREATE INDEX idx_password_reset_token_user_id ON t_password_reset_token ("userId");
CREATE INDEX idx_password_reset_token_token ON t_password_reset_token ("token");
CREATE INDEX idx_password_reset_token_expires_at ON t_password_reset_token ("expiresAt");
CREATE INDEX idx_password_reset_token_used ON t_password_reset_token ("used");