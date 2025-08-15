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
  "id" text primary key not null,
  "name" text not null,
  "email" text not null unique,
  "phone" text not null,
  "password" text not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_user IS 'Usuarios del sistema con credenciales de acceso';
COMMENT ON COLUMN t_user.email IS 'Email único del usuario para autenticación';
COMMENT ON COLUMN t_user.password IS 'Contraseña hasheada del usuario';


DROP TABLE IF EXISTS t_parking CASCADE;
CREATE TABLE t_parking (
  "id" text primary key not null,
  "name" text not null,
  "email" text not null,
  "phone" text,
  "address" text,
  "logoUrl" text,
  "status" text not null default 'active',
  "ownerId" text not null,
  "params" jsonb not null default '{}', -- Configuración del estacionamiento
  "rates" jsonb not null default '[]', -- Tarifas del estacionamiento
  "operationMode" text not null default 'visual' check ("operationMode" in ('visual', 'simple')), -- 'visual', 'simple'
  "capacity" integer not null default 0,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_parking IS 'Estacionamientos registrados en el sistema';
COMMENT ON COLUMN t_parking."operationMode" IS 'Modo de operación del parqueo: visual (con slots) o simple (pantalla y botones)';
COMMENT ON COLUMN t_parking.capacity IS 'Capacidad máxima del parqueo';
COMMENT ON COLUMN t_parking.params IS 'Parámetros de configuración del estacionamiento:
* currency: Moneda utilizada (USD, EUR, etc.)
* timeZone: Zona horaria (America/New_York, Europe/Madrid, etc.)
* decimalPlaces: Lugares decimales para montos (2, 0, etc.)
* theme: Tema visual (dark, light)
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
  "id" text primary key not null,
  "userId" text not null references t_user(id) on delete cascade,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "role" text not null default 'operator', -- 'admin', 'operator', 'supervisor'
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
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
  "id" text primary key not null,
  "name" text not null,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_area IS 'Áreas o secciones del estacionamiento (Piso 1, Piso 2, etc.)';

-- Tabla de elementos del estacionamiento (spots, facilidades, señalizaciones)
DROP TABLE IF EXISTS t_element CASCADE;
CREATE TABLE t_element (
  "id" text primary key not null,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "areaId" text not null references t_area(id) on delete cascade,
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
  "updatedAt" timestamptz default now(),
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
  "id" text primary key not null,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "type" text not null, -- 'motorcycle', 'car', 'truck', 'bus', 'van'
  "plate" text not null,
  "color" text not null,
  "ownerName" text,
  "ownerDocument" text,
  "ownerPhone" text,
  "isSubscribed" boolean not null default false,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_vehicle IS 'Vehículos registrados en el sistema';
COMMENT ON COLUMN t_vehicle."type" IS 'Tipo de vehículo: motorcycle, car, truck, bus, van';
COMMENT ON COLUMN t_vehicle."isSubscribed" IS 'Indica si el vehículo tiene una suscripción activa';

-- Tabla de suscripciones
DROP TABLE IF EXISTS t_subscription CASCADE;
CREATE TABLE t_subscription (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "employeeId" text not null references t_employee(id) on delete cascade,
  "vehicleId" text not null references t_vehicle(id) on delete cascade,
  "spotId" text not null references t_element(id) on delete cascade,
  "startDate" timestamptz not null,
  "endDate" timestamptz not null,
  "amount" numeric not null,
  "status" text not null default 'active', -- 'active', 'completed', 'cancelled'
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_subscription IS 'Suscripciones de estacionamiento para vehículos';

-- Tabla de reservas
DROP TABLE IF EXISTS t_reservation CASCADE;
CREATE TABLE t_reservation (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "employeeId" text not null references t_employee(id) on delete cascade,
  "vehicleId" text not null references t_vehicle(id) on delete cascade,
  "spotId" text not null references t_element(id) on delete cascade,
  "startDate" timestamptz not null,
  "endDate" timestamptz not null,
  "status" text not null default 'active', -- 'active', 'completed', 'cancelled'
  "amount" numeric not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_reservation IS 'Reservas de spots de estacionamiento';
COMMENT ON COLUMN t_reservation."status" IS 'Estado de la reserva: active (activa), completed (completada), cancelled (cancelada)';

-- =====================================================
-- TABLAS DE ACCESOS Y OPERACIONES
-- =====================================================

-- Tabla de accesos (entradas y salidas)
DROP TABLE IF EXISTS t_access CASCADE;
CREATE TABLE t_access (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "subscriptionId" text references t_subscription(id) on delete set null,
  "reservationId" text references t_reservation(id) on delete set null,
  "entryEmployeeId" text not null references t_employee(id) on delete cascade,
  "exitEmployeeId" text references t_employee(id) on delete set null,
  "vehicleId" text not null references t_vehicle(id) on delete cascade,
  "spotId" text not null references t_element(id) on delete cascade,
  "entryTime" timestamptz not null,
  "exitTime" timestamptz,
  "amount" numeric default 0,
  "status" text not null default 'active', -- 'active', 'completed', 'cancelled'
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_access IS 'Registro de entradas y salidas de vehículos del estacionamiento';
COMMENT ON COLUMN t_access."entryEmployeeId" IS 'ID del empleado que registra la entrada del vehículo';
COMMENT ON COLUMN t_access."exitEmployeeId" IS 'ID del empleado que registra la salida del vehículo (NULL si aún está activo)';
COMMENT ON COLUMN t_access."entryTime" IS 'Fecha y hora de entrada del vehículo';
COMMENT ON COLUMN t_access."exitTime" IS 'Fecha y hora de salida del vehículo (NULL si aún está activo)';
COMMENT ON COLUMN t_access."amount" IS 'Monto cobrado por el estacionamiento (0 si aún está activo)';
COMMENT ON COLUMN t_access."status" IS 'Estado del acceso: active (activo), completed (completado), cancelled (cancelado)';

-- Tabla de cajas registradoras
DROP TABLE IF EXISTS t_cash_register CASCADE;
CREATE TABLE t_cash_register (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null references t_parking(id) on delete cascade,
  "employeeId" text not null references t_employee(id) on delete cascade,
  "startDate" timestamptz not null,
  "endDate" timestamptz,
  "status" text not null default 'open', -- 'open', 'closed'
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
  "deletedAt" timestamptz
);

COMMENT ON TABLE t_cash_register IS 'Cajas registradoras de los estacionamientos';
COMMENT ON COLUMN t_cash_register."status" IS 'Estado de la caja: open (abierta), closed (cerrada)';

-- Tabla de movimientos de caja
DROP TABLE IF EXISTS t_movement CASCADE;
CREATE TABLE t_movement (
  "id" text primary key not null,
  "cashRegisterId" text not null references t_cash_register(id) on delete cascade,
  "type" text not null, -- 'income', 'expense', 'refund'
  "amount" numeric not null,
  "description" text not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
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
  "id" text primary key not null,
  "type" text not null, -- 'email', 'sms', 'push', 'system'
  "title" text not null,
  "message" text not null,
  "recipientId" text not null,
  "recipientType" text not null, -- 'user', 'employee', 'parking'
  "channel" text not null, -- 'email', 'sms', 'push', 'system'
  "parkingId" text not null references t_parking(id) on delete cascade,
  "relatedEntityId" text,
  "relatedEntityType" text, -- 'access', 'reservation', 'subscription'
  "status" text not null default 'pending', -- 'pending', 'sent', 'failed'
  "metadata" jsonb default '{}',
  "scheduledFor" timestamptz,
  "sentAt" timestamptz,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now(),
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

-- Índices para t_subscription
CREATE INDEX idx_subscription_parking_id ON t_subscription ("parkingId");
CREATE INDEX idx_subscription_employee_id ON t_subscription ("employeeId");
CREATE INDEX idx_subscription_vehicle_id ON t_subscription ("vehicleId");
CREATE INDEX idx_subscription_dates ON t_subscription ("startDate", "endDate");

-- Índices para t_reservation
CREATE INDEX idx_reservation_parking_id ON t_reservation ("parkingId");
CREATE INDEX idx_reservation_employee_id ON t_reservation ("employeeId");
CREATE INDEX idx_reservation_vehicle_id ON t_reservation ("vehicleId");
CREATE INDEX idx_reservation_spot_id ON t_reservation ("spotId");
CREATE INDEX idx_reservation_status ON t_reservation ("status");
CREATE INDEX idx_reservation_dates ON t_reservation ("startDate", "endDate");

-- Índices para t_access
CREATE INDEX idx_access_parking_id ON t_access ("parkingId");
CREATE INDEX idx_access_subscription_id ON t_access ("subscriptionId");
CREATE INDEX idx_access_reservation_id ON t_access ("reservationId");
CREATE INDEX idx_access_entry_employee_id ON t_access ("entryEmployeeId");
CREATE INDEX idx_access_exit_employee_id ON t_access ("exitEmployeeId");
CREATE INDEX idx_access_vehicle_id ON t_access ("vehicleId");
CREATE INDEX idx_access_spot_id ON t_access ("spotId");
CREATE INDEX idx_access_status ON t_access ("status");
CREATE INDEX idx_access_entry_time ON t_access ("entryTime");
CREATE INDEX idx_access_exit_time ON t_access ("exitTime");

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
WITH access_cte AS (
  SELECT DISTINCT ON (a."spotId")
    a."spotId",
    jsonb_build_object(
      'id', a.id,
      'startDate', a."entryTime",
      'endDate', a."exitTime",
      'vehicle', jsonb_build_object(
        'id', v.id,
        'plate', v.plate,
        'color', v.color,
        'type', v.type,
        'ownerName', v."ownerName",
        'ownerDocument', v."ownerDocument",
        'ownerPhone', v."ownerPhone"
      ),
      'employee', jsonb_build_object(
        'id', ee.id,
        'role', ee.role,
        'name', eu.name,
        'email', eu.email,
        'phone', eu.phone
      ),
      'amount', COALESCE(a.amount, 0)
    ) AS access
  FROM t_access a
  LEFT JOIN t_vehicle v ON v.id = a."vehicleId"
  LEFT JOIN t_employee ee ON ee.id = a."entryEmployeeId"
  LEFT JOIN t_user eu ON eu.id = ee."userId"
  WHERE a.status = 'active' AND a."exitTime" IS NULL
  ORDER BY a."spotId", a."entryTime" DESC
),

reservation_cte AS (
  SELECT DISTINCT ON (r."spotId")
    r."spotId",
    jsonb_build_object(
      'id', r.id,
      'startDate', r."startDate",
      'endDate', r."endDate",
      'vehicle', jsonb_build_object(
        'id', v.id,
        'plate', v.plate,
        'color', v.color,
        'type', v.type,
        'ownerName', v."ownerName",
        'ownerDocument', v."ownerDocument",
        'ownerPhone', v."ownerPhone"
      ),
      'employee', jsonb_build_object(
        'id', e.id,
        'role', e.role,
        'name', u.name,
        'email', u.email,
        'phone', u.phone
      ),
      'amount', r.amount
    ) AS reservation
  FROM t_reservation r
  LEFT JOIN t_vehicle v ON v.id = r."vehicleId"
  LEFT JOIN t_employee e ON e.id = r."employeeId"
  LEFT JOIN t_user u ON u.id = e."userId"
  WHERE r.status = 'active'
    AND NOW() BETWEEN r."startDate" AND r."endDate"
  ORDER BY r."spotId", r."startDate" DESC
),

subscription_cte AS (
  SELECT DISTINCT ON (s."spotId")
    s."spotId",
    jsonb_build_object(
      'id', s.id,
      'startDate', s."startDate",
      'endDate', s."endDate",
      'vehicle', jsonb_build_object(
        'id', v.id,
        'plate', v.plate,
        'color', v.color,
        'type', v.type,
        'ownerName', v."ownerName",
        'ownerDocument', v."ownerDocument",
        'ownerPhone', v."ownerPhone"
      ),
      'employee', jsonb_build_object(
        'id', e.id,
        'role', e.role,
        'name', u.name,
        'email', u.email,
        'phone', u.phone
      ),
      'amount', 0
    ) AS subscription
  FROM t_subscription s
  JOIN t_vehicle v ON v.id = s."vehicleId"
  LEFT JOIN t_employee e ON e.id = s."employeeId"
  LEFT JOIN t_user u ON u.id = e."userId"
  WHERE s."status" = 'active'
    AND NOW() BETWEEN s."startDate" AND s."endDate"
  ORDER BY s."spotId", s."startDate" DESC
)

SELECT 
  e.id AS "elementId",
  e.name AS "elementName",
  e.type AS "elementType",
  e."subType" AS "elementSubType",
  e."isActive" AS "elementActive",
  ac.access,
  rc.reservation,
  sc.subscription,

  CASE 
    WHEN e."isActive" = false THEN 'maintenance'
    WHEN ac.access IS NOT NULL THEN 'occupied'
    WHEN rc.reservation IS NOT NULL THEN 'reserved'
    WHEN sc.subscription IS NOT NULL THEN 'subscribed'
    ELSE 'available'
  END AS status

FROM t_element e
LEFT JOIN access_cte ac ON ac."spotId" = e.id
LEFT JOIN reservation_cte rc ON rc."spotId" = e.id
LEFT JOIN subscription_cte sc ON sc."spotId" = e.id
WHERE e."deletedAt" IS NULL;


COMMENT ON VIEW v_element_occupancy IS 'Vista que muestra el estado actual de ocupación de todos los elementos del estacionamiento';

-- =====================================================
-- FIN DEL ESQUEMA
-- =====================================================
