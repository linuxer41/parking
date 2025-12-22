-- Migration: Add originId, originType and update type column in t_movement table
-- Description: Add originId and originType columns, change type to income/expense
-- Date: 2024-12-22

-- Add originId column if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 't_movement' AND column_name = 'originId') THEN
        ALTER TABLE t_movement ADD COLUMN "originId" uuid NOT NULL;
    END IF;
END $$;

-- Add originType column if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 't_movement' AND column_name = 'originType') THEN
        ALTER TABLE t_movement ADD COLUMN "originType" TEXT;
        -- Set originType to current type value for existing rows
        UPDATE t_movement SET "originType" = "type" WHERE "originType" IS NULL;
        -- Now make it NOT NULL
        ALTER TABLE t_movement ALTER COLUMN "originType" SET NOT NULL;
    END IF;
END $$;

-- Update type column: first drop old constraint, then update data, then add new constraint
ALTER TABLE t_movement DROP CONSTRAINT IF EXISTS t_movement_type_check;
UPDATE t_movement SET "type" = 'income' WHERE "type" IN ('access', 'booking', 'subscription');
ALTER TABLE t_movement ADD CONSTRAINT t_movement_type_check CHECK ("type" IN ('income', 'expense'));

-- Add constraint for originType if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 't_movement' AND constraint_name = 't_movement_originType_check') THEN
        ALTER TABLE t_movement ADD CONSTRAINT t_movement_originType_check CHECK ("originType" IN ('access', 'booking', 'subscription'));
    END IF;
END $$;

-- Add comment for originId
COMMENT ON COLUMN t_movement."originId" IS 'ID de la entidad origen (access, booking o subscription)';

-- Add comment for originType
COMMENT ON COLUMN t_movement."originType" IS 'Tipo de origen del movimiento: access (acceso), booking (reserva), subscription (suscripción)';

-- Update comment for type
COMMENT ON COLUMN t_movement."type" IS 'Tipo de movimiento: income (ingreso), expense (gasto)';