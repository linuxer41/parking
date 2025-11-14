-- =====================================================
-- ESQUEMA DE BASE DE DATOS - SISTEMA DE ESTACIONAMIENTO
-- =====================================================
-- Descripción: Esquema completo para el sistema de gestión de estacionamientos
-- Autor: Sistema de Estacionamiento
-- Versión: 1.0.0
-- Fecha: 2024

-- =====================================================
-- TABLAS PRINCIPALES
-- =====================================================

-- Tabla de usuarios del sistema
DROP TABLE IF EXISTS t_user CASCADE;
CREATE TABLE t_user (
  "id" uuid  primary key not null default gen_random_uuid(),
  "name" text not null,
  "email" text not null unique,
  "phone" text not null,
  "passwordHash" text not null,
  "avatarUrl" text,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_user IS 'Usuarios del sistema con credenciales de acceso';
COMMENT ON COLUMN t_user.email IS 'Email único del usuario para autenticación';
COMMENT ON COLUMN t_user."passwordHash" IS 'Contraseña hasheada del usuario';


DROP TABLE IF EXISTS t_parking CASCADE;
CREATE TABLE t_parking (
  "id" uuid  primary key not null default gen_random_uuid(),
  "name" text not null,
  "email" text,
  "phone" text,
  "address" text,
  "location" jsonb not null default '{}',
  "logoUrl" text,
  "status" text not null default 'active',
  "ownerId" uuid not null references t_user(id) on delete cascade,
  "params" jsonb not null default '{}', -- Configuración del estacionamiento
  "rates" jsonb not null default '[]', -- Tarifas del estacionamiento
  "operationMode" text not null default 'map' check ("operationMode" in ('map', 'list')), -- 'map', 'list'
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_parking IS 'Estacionamientos registrados en el sistema';
COMMENT ON COLUMN t_parking."operationMode" IS 'Modo de operación del parqueo: map (con slots) o list (pantalla y botones)';
COMMENT ON COLUMN t_parking.params IS 'Parámetros de configuración del estacionamiento:
* currency: Moneda utilizada (USD, EUR, etc.)
* timeZone: Zona horaria (America/New_York, Europe/Madrid, etc.)
* decimalPlaces: Lugares decimales para montos (2, 0, etc.)
* theme: Tema map (dark, light)
* slogan: Eslogan del estacionamiento
* countryCode: Código de país ISO (US, ES, etc.)';
COMMENT ON COLUMN t_parking.rates IS 'Tarifas del estacionamiento en formato JSON:
* hourlyPrice: Precio por hora
* dailyPrice: Precio por día
* weeklyPrice: Precio por semana
* monthlyPrice: Precio por mes';

-- Tabla de empleados
DROP TABLE IF EXISTS t_employee CASCADE;
CREATE TABLE t_employee (
  "id" uuid  primary key not null default gen_random_uuid(),
  "userId" uuid not null references t_user(id) on delete cascade,
  "parkingId" uuid not null references t_parking(id) on delete cascade,
  "role" text not null default 'operator', -- 'admin', 'operator', 'supervisor'
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_employee IS 'Empleados que trabajan en los estacionamientos';
COMMENT ON COLUMN t_employee.role IS 'Rol del empleado: admin (administrador), operator (operador), supervisor (supervisor)';

-- =====================================================
-- TABLAS DE ESTRUCTURA DEL ESTACIONAMIENTO
-- =====================================================

-- Tabla de áreas del estacionamiento
DROP TABLE IF EXISTS t_area CASCADE;
CREATE TABLE t_area (
  "id" uuid  primary key not null default gen_random_uuid(),
  "name" text not null,
  "parkingId" uuid not null references t_parking(id) on delete cascade,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_area IS 'Áreas o secciones del estacionamiento (Piso 1, Piso 2, etc.)';

-- Tabla de elementos del estacionamiento (spots, facilidades, señalizaciones)
DROP TABLE IF EXISTS t_element CASCADE;
CREATE TABLE t_element (
  "id" uuid  primary key not null default gen_random_uuid(),
  "parkingId" uuid not null references t_parking(id) on delete cascade,
  "areaId" uuid not null references t_area(id) on delete cascade,
  "name" text not null,
  "type" text not null default 'spot', -- 'spot', 'facility', 'signage'
  "subType" integer not null default 0, -- Tipo específico según type
  "posX" numeric not null default 0,
  "posY" numeric not null default 0,
  "posZ" numeric not null default 0,
  "rotation" numeric not null default 0,
  "scale" numeric not null default 1,
  "isActive" boolean not null default true,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_element IS 'Elementos del estacionamiento: spots de estacionamiento, facilidades y señalizaciones';
COMMENT ON COLUMN t_element."type" IS 'Tipo de elemento: spot (estacionamiento), facility (facilidad), signage (señalización)';
COMMENT ON COLUMN t_element."subType" IS 'Subtipo específico según type:
- Para spots: 1=motocicleta, 2=auto, 3=camión, 4=bus, 5=van
- Para facilidades: 1=oficina, 2=baño, 3=cafetería, 4=elevador, 5=escaleras, 6=información
- Para señalizaciones: 1=entrada, 2=salida, 3=dirección, 4=advertencia, 5=información, 6=stop';

-- =====================================================
-- TABLAS DE VEHÍCULOS Y SERVICIOS
-- =====================================================

-- Tabla de vehículos
DROP TABLE IF EXISTS t_vehicle CASCADE;
CREATE TABLE t_vehicle (
  "id" uuid  primary key not null default gen_random_uuid(),
  "parkingId" uuid not null references t_parking(id) on delete cascade,
  "type" text not null, -- 'motorcycle', 'car', 'truck', 'bus', 'van'
  "plate" text not null,
  "color" text,
  "ownerName" text,
  "ownerDocument" text,
  "ownerPhone" text,
  "isSubscribed" boolean not null default false,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_vehicle IS 'Vehículos registrados en el sistema';
COMMENT ON COLUMN t_vehicle."type" IS 'Tipo de vehículo: motorcycle, car, truck, bus, van';
COMMENT ON COLUMN t_vehicle."isSubscribed" IS 'Indica si el vehículo tiene una suscripción activa';

-- =====================================================
-- TABLAS SEPARADAS: BOOKING, ENTRY_EXIT Y SUBSCRIPTION
-- =====================================================

-- Tabla de bookings (solo para reservas)
DROP TABLE IF EXISTS t_booking CASCADE;
CREATE TABLE t_booking (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "createdAt" timestamptz NOT NULL DEFAULT NOW(),
  "updatedAt" timestamptz,
  "deletedAt" timestamptz,
  
  "number" INTEGER NOT NULL,
  "parkingId" UUID NOT NULL REFERENCES t_parking("id") ON DELETE CASCADE,
  "employeeId" UUID NOT NULL REFERENCES t_employee("id") ON DELETE CASCADE,
  "vehicleId" UUID NOT NULL REFERENCES t_vehicle("id") ON DELETE CASCADE,
  "spotId" UUID REFERENCES t_element("id") ON DELETE SET NULL,
  "startDate" timestamptz NOT NULL,
  "endDate" timestamptz,
  "amount" DECIMAL(10,2) NOT NULL DEFAULT 0,
  "status" VARCHAR(20) NOT NULL DEFAULT 'pending',
  "notes" TEXT,
  
  UNIQUE("number", "parkingId")
);

-- Tabla de entradas y salidas (accesos)
DROP TABLE IF EXISTS t_entry_exit CASCADE;
CREATE TABLE t_entry_exit (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "createdAt" timestamptz NOT NULL DEFAULT NOW(),
  "updatedAt" timestamptz,
  "deletedAt" timestamptz,
  
  "number" INTEGER NOT NULL,
  "parkingId" UUID NOT NULL REFERENCES t_parking("id") ON DELETE CASCADE,
  "employeeId" UUID NOT NULL REFERENCES t_employee("id") ON DELETE CASCADE,
  "vehicleId" UUID NOT NULL REFERENCES t_vehicle("id") ON DELETE CASCADE,
  "spotId" UUID REFERENCES t_element("id") ON DELETE SET NULL,
  "entryTime" timestamptz NOT NULL DEFAULT NOW(),
  "exitTime" timestamptz,
  "exitEmployeeId" UUID REFERENCES t_employee("id") ON DELETE SET NULL,
  "amount" DECIMAL(10,2) NOT NULL DEFAULT 0,
  "status" VARCHAR(20) NOT NULL DEFAULT 'entered',
  "notes" TEXT,
  
  UNIQUE("number", "parkingId")
);

-- Tabla de suscripciones
DROP TABLE IF EXISTS t_subscription CASCADE;
CREATE TABLE t_subscription (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "createdAt" timestamptz NOT NULL DEFAULT NOW(),
  "updatedAt" timestamptz,
  "deletedAt" timestamptz,
  
  "number" INTEGER NOT NULL,
  "parkingId" UUID NOT NULL REFERENCES t_parking("id") ON DELETE CASCADE,
  "employeeId" UUID NOT NULL REFERENCES t_employee("id") ON DELETE CASCADE,
  "vehicleId" UUID NOT NULL REFERENCES t_vehicle("id") ON DELETE CASCADE,
  "spotId" UUID REFERENCES t_element("id") ON DELETE SET NULL,
  "startDate" timestamptz NOT NULL,
  "endDate" timestamptz NOT NULL,
  "amount" DECIMAL(10,2) NOT NULL DEFAULT 0,
  "status" VARCHAR(20) NOT NULL DEFAULT 'active',
  "period" VARCHAR(20) NOT NULL DEFAULT 'monthly',
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "parentId" UUID REFERENCES t_subscription("id") ON DELETE SET NULL,
  "notes" TEXT,
  
  UNIQUE("number", "parkingId")
);

-- Índices para t_booking (reservas)
CREATE INDEX idx_booking_parking_id ON t_booking ("parkingId");
CREATE INDEX idx_booking_employee_id ON t_booking ("employeeId");
CREATE INDEX idx_booking_vehicle_id ON t_booking ("vehicleId");
CREATE INDEX idx_booking_spot_id ON t_booking ("spotId");
CREATE INDEX idx_booking_status ON t_booking ("status");
CREATE INDEX idx_booking_dates ON t_booking ("startDate", "endDate");
CREATE INDEX idx_booking_number ON t_booking ("number", "parkingId");

-- Índices para t_entry_exit
CREATE INDEX idx_entry_exit_parking_id ON t_entry_exit ("parkingId");
CREATE INDEX idx_entry_exit_employee_id ON t_entry_exit ("employeeId");
CREATE INDEX idx_entry_exit_vehicle_id ON t_entry_exit ("vehicleId");
CREATE INDEX idx_entry_exit_spot_id ON t_entry_exit ("spotId");
CREATE INDEX idx_entry_exit_status ON t_entry_exit ("status");
CREATE INDEX idx_entry_exit_entry_time ON t_entry_exit ("entryTime");
CREATE INDEX idx_entry_exit_exit_time ON t_entry_exit ("exitTime");
CREATE INDEX idx_entry_exit_number ON t_entry_exit ("number", "parkingId");

-- Índices para t_subscription
CREATE INDEX idx_subscription_parking_id ON t_subscription ("parkingId");
CREATE INDEX idx_subscription_employee_id ON t_subscription ("employeeId");
CREATE INDEX idx_subscription_vehicle_id ON t_subscription ("vehicleId");
CREATE INDEX idx_subscription_spot_id ON t_subscription ("spotId");
CREATE INDEX idx_subscription_status ON t_subscription ("status");
CREATE INDEX idx_subscription_is_active ON t_subscription ("isActive");
CREATE INDEX idx_subscription_dates ON t_subscription ("startDate", "endDate");
CREATE INDEX idx_subscription_period ON t_subscription ("period");
CREATE INDEX idx_subscription_parent_id ON t_subscription ("parentId");
CREATE INDEX idx_subscription_number ON t_subscription ("number", "parkingId");

-- Comentarios para documentar la estructura
COMMENT ON TABLE t_booking IS 'Tabla para reservas de estacionamiento';
COMMENT ON COLUMN t_booking."status" IS 'Estado: pending, active, completed, cancelled';
COMMENT ON COLUMN t_booking."number" IS 'Número secuencial de reserva por parking';

COMMENT ON TABLE t_entry_exit IS 'Entradas y salidas de vehículos (accesos)';
COMMENT ON COLUMN t_entry_exit."number" IS 'Número secuencial de entrada por parking';
COMMENT ON COLUMN t_entry_exit."entryTime" IS 'Hora de entrada del vehículo';
COMMENT ON COLUMN t_entry_exit."exitTime" IS 'Hora de salida del vehículo';
COMMENT ON COLUMN t_entry_exit."exitEmployeeId" IS 'Empleado que registró la salida';
COMMENT ON COLUMN t_entry_exit."status" IS 'Estado: entered, exited, cancelled';

COMMENT ON TABLE t_subscription IS 'Suscripciones de vehículos';
COMMENT ON COLUMN t_subscription."number" IS 'Número secuencial de suscripción por parking';
COMMENT ON COLUMN t_subscription."period" IS 'Periodo: weekly, monthly, yearly';
COMMENT ON COLUMN t_subscription."isActive" IS 'Indica si la suscripción está activa';
COMMENT ON COLUMN t_subscription."parentId" IS 'Referencia a suscripción anterior (renovaciones)';
COMMENT ON COLUMN t_subscription."status" IS 'Estado: active, suspended, expired, cancelled, renewed';





-- =====================================================
-- TABLAS DE ACCESOS Y OPERACIONES
-- =====================================================

-- Tabla de cajas registradoras
DROP TABLE IF EXISTS t_cash_register CASCADE;
CREATE TABLE t_cash_register (
  "id" uuid  primary key not null default gen_random_uuid(),
  "number" integer not null,
  "parkingId" uuid not null references t_parking(id) on delete cascade,
  "employeeId" uuid not null references t_employee(id) on delete cascade,
  "startDate" timestamptz not null,
  "endDate" timestamptz,
  "status" text not null default 'open', -- 'open', 'closed'
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_cash_register IS 'Cajas registradoras de los estacionamientos';
COMMENT ON COLUMN t_cash_register."status" IS 'Estado de la caja: open (abierta), closed (cerrada)';

-- Tabla de movimientos de caja
DROP TABLE IF EXISTS t_movement CASCADE;
CREATE TABLE t_movement (
  "id" uuid  primary key not null default gen_random_uuid(),
  "cashRegisterId" uuid not null references t_cash_register(id) on delete cascade,
  "type" text not null, -- 'income', 'expense', 'refund'
  "amount" numeric not null,
  "description" text not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_movement IS 'Movimientos de dinero en las cajas registradoras';
COMMENT ON COLUMN t_movement."type" IS 'Tipo de movimiento: income (ingreso), expense (gasto), refund (reembolso)';

-- =====================================================
-- TABLAS DE NOTIFICACIONES
-- =====================================================

-- Tabla de notificaciones
DROP TABLE IF EXISTS t_notification CASCADE;
CREATE TABLE t_notification (
  "id" uuid  primary key not null default gen_random_uuid(),
  "type" text not null, -- 'email', 'sms', 'push', 'system'
  "title" text not null,
  "message" text not null,
  "recipientId" uuid not null,
  "recipientType" text not null, -- 'user', 'employee', 'parking'
  "channel" text not null, -- 'email', 'sms', 'push', 'system'
  "parkingId" uuid not null references t_parking(id) on delete cascade,
  "relatedEntityId" uuid,
  "relatedEntityType" text, -- 'access', 'reservation', 'subscription'
  "status" text not null default 'pending', -- 'pending', 'sent', 'failed'
  "metadata" jsonb default '{}',
  "scheduledFor" timestamptz,
  "sentAt" timestamptz,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz,
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_notification IS 'Sistema de notificaciones del estacionamiento';
COMMENT ON COLUMN t_notification."type" IS 'Tipo de notificación: email, sms, push, system';
COMMENT ON COLUMN t_notification."recipientType" IS 'Tipo de destinatario: user, employee, parking';
COMMENT ON COLUMN t_notification."channel" IS 'Canal de envío: email, sms, push, system';
COMMENT ON COLUMN t_notification."relatedEntityType" IS 'Tipo de entidad relacionada: access, reservation, subscription';
COMMENT ON COLUMN t_notification."status" IS 'Estado de la notificación: pending (pendiente), sent (enviada), failed (fallida)';

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para t_employee
CREATE INDEX idx_employee_user_id ON t_employee ("userId");
CREATE INDEX idx_employee_parking_id ON t_employee ("parkingId");
CREATE INDEX idx_employee_role ON t_employee ("role");

-- Índices para t_parking
CREATE INDEX idx_parking_owner_id ON t_parking ("ownerId");
CREATE INDEX idx_parking_status ON t_parking ("status");

-- Índices para t_area
CREATE INDEX idx_area_parking_id ON t_area ("parkingId");

-- Índices para t_element
CREATE INDEX idx_element_parking_id ON t_element ("parkingId");
CREATE INDEX idx_element_area_id ON t_element ("areaId");
CREATE INDEX idx_element_type ON t_element ("type");
CREATE INDEX idx_element_sub_type ON t_element ("subType");
CREATE INDEX idx_element_active ON t_element ("isActive");

-- Índices para t_vehicle
CREATE INDEX idx_vehicle_parking_id ON t_vehicle ("parkingId");
CREATE INDEX idx_vehicle_type ON t_vehicle ("type");
CREATE INDEX idx_vehicle_plate ON t_vehicle ("plate");
CREATE INDEX idx_vehicle_subscribed ON t_vehicle ("isSubscribed");



-- Índices para t_cash_register
CREATE INDEX idx_cash_register_parking_id ON t_cash_register ("parkingId");
CREATE INDEX idx_cash_register_employee_id ON t_cash_register ("employeeId");
CREATE INDEX idx_cash_register_status ON t_cash_register ("status");

-- Índices para t_movement
CREATE INDEX idx_movement_cash_register_id ON t_movement ("cashRegisterId");
CREATE INDEX idx_movement_type ON t_movement ("type");
CREATE INDEX idx_movement_created_at ON t_movement ("createdAt");

-- Índices para t_notification
CREATE INDEX idx_notification_recipient_id ON t_notification ("recipientId");
CREATE INDEX idx_notification_parking_id ON t_notification ("parkingId");
CREATE INDEX idx_notification_status ON t_notification ("status");
CREATE INDEX idx_notification_type ON t_notification ("type");
CREATE INDEX idx_notification_scheduled_for ON t_notification ("scheduledFor");
CREATE INDEX idx_notification_created_at ON t_notification ("createdAt");

-- =====================================================
-- VISTAS PARA CONSULTAS COMPLEJAS
-- =====================================================

-- Vista para el estado de ocupación de los elementos
CREATE OR REPLACE VIEW v_element_occupancy AS
WITH entry_exit_cte AS (
  SELECT
    e.id as "elementId",
    CASE WHEN ee.id IS NOT NULL THEN
      json_build_object(
        'id', ee.id,
        'number', ee.number,
        'vehiclePlate', v.plate,
        'ownerName', v."ownerName",
        'ownerPhone', v."ownerPhone",
        'startDate', ee."entryTime",
        'amount', ee.amount,
        'status', ee.status
      )
    ELSE NULL END as entry_data
  FROM t_element e
  LEFT JOIN t_entry_exit ee ON e.id = ee."spotId" AND ee.status = 'entered'
  LEFT JOIN t_vehicle v ON ee."vehicleId" = v.id
  WHERE e.type = 'spot' AND e."deletedAt" IS NULL
),
booking_cte AS (
  SELECT
    e.id as "elementId",
    CASE WHEN b.id IS NOT NULL THEN
      json_build_object(
        'id', b.id,
        'number', b.number,
        'vehiclePlate', v.plate,
        'ownerName', v."ownerName",
        'ownerPhone', v."ownerPhone",
        'startDate', b."startDate",
        'endDate', b."endDate",
        'amount', b.amount,
        'status', b.status
      )
    ELSE NULL END as booking_data
  FROM t_element e
  LEFT JOIN t_booking b ON e.id = b."spotId" AND b.status IN ('pending', 'active')
  LEFT JOIN t_vehicle v ON b."vehicleId" = v.id
  WHERE e.type = 'spot' AND e."deletedAt" IS NULL
),
subscription_cte AS (
  SELECT
    e.id as "elementId",
    CASE WHEN s.id IS NOT NULL THEN
      json_build_object(
        'id', s.id,
        'number', s.number,
        'vehiclePlate', v.plate,
        'ownerName', v."ownerName",
        'ownerPhone', v."ownerPhone",
        'startDate', s."startDate",
        'endDate', s."endDate",
        'amount', s.amount,
        'status', s.status,
        'period', s.period
      )
    ELSE NULL END as subscription_data
  FROM t_element e
  LEFT JOIN t_subscription s ON e.id = s."spotId" AND s.status = 'active' AND s."isActive" = true
  LEFT JOIN t_vehicle v ON s."vehicleId" = v.id
  WHERE e.type = 'spot' AND e."deletedAt" IS NULL
)
SELECT
  e.id as "elementId",
  (SELECT entry_data FROM entry_exit_cte WHERE "elementId" = e.id LIMIT 1) as entry,
  (SELECT subscription_data FROM subscription_cte WHERE "elementId" = e.id LIMIT 1) as subscription,
  (SELECT booking_data FROM booking_cte WHERE "elementId" = e.id LIMIT 1) as booking
FROM t_element e
WHERE e."deletedAt" IS NULL;


COMMENT ON VIEW v_element_occupancy IS 'Vista que muestra el estado actual de ocupación de todos los elementos del estacionamiento';

-- =====================================================
-- FIN DEL ESQUEMA
-- =====================================================


