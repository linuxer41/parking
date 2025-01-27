
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  "id" text primary key not null,
  "name" text not null,
  "email" text not null,
  "password" text not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);





DROP TABLE IF EXISTS t_company;
CREATE TABLE t_company (
  "id" text primary key not null,
  "name" text not null,
  "email" text not null,
  "phone" text ,
  "logoUrl" text ,
  "userId" text not null,
  "params" jsonb ,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_company_user_id on t_company ("userId");



DROP TABLE IF EXISTS t_employee;
CREATE TABLE t_employee (
  "id" text primary key not null,
  "userId" text not null,
  "companyId" text not null,
  "role" text not null,
  "assignedParkings" jsonb not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_employee_user_id on t_employee ("userId");
create index t_employee_company_id on t_employee ("companyId");



DROP TABLE IF EXISTS t_parking;
CREATE TABLE t_parking (
  "id" text primary key not null,
  "name" text not null,
  "companyId" text not null,
  "vehicleTypes" jsonb not null,
  "params" jsonb not null,
  "prices" jsonb not null,
  "subscriptionPlans" jsonb not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_parking_company_id on t_parking ("companyId");



DROP TABLE IF EXISTS t_level;
CREATE TABLE t_level (
  "id" text primary key not null,
  "name" text not null,
  "parkingId" text not null,
  "spots" jsonb not null,
  "signages" jsonb not null,
  "facilities" jsonb not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_level_parking_id on t_level ("parkingId");



DROP TABLE IF EXISTS t_vehicle;
CREATE TABLE t_vehicle (
  "id" text primary key not null,
  "parkingId" text not null,
  "typeId" text not null,
  "plate" text not null,
  "isSubscriber" boolean not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_vehicle_parking_id on t_vehicle ("parkingId");
create index t_vehicle_type_id on t_vehicle ("typeId");



DROP TABLE IF EXISTS t_subscriber;
CREATE TABLE t_subscriber (
  "id" text primary key not null,
  "parkingId" text not null,
  "employeeId" text not null,
  "vehicleId" text not null,
  "planId" text not null,
  "startDate" timestamptz not null,
  "endDate" timestamptz not null,
  "isActive" boolean not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_subscriber_parking_id on t_subscriber ("parkingId");
create index t_subscriber_employee_id on t_subscriber ("employeeId");
create index t_subscriber_vehicle_id on t_subscriber ("vehicleId");
create index t_subscriber_plan_id on t_subscriber ("planId");



DROP TABLE IF EXISTS t_entry;
CREATE TABLE t_entry (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null,
  "employeeId" text not null,
  "vehicleId" text not null,
  "spotId" text not null,
  "dateTime" timestamptz not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_entry_parking_id on t_entry ("parkingId");
create index t_entry_employee_id on t_entry ("employeeId");
create index t_entry_vehicle_id on t_entry ("vehicleId");
create index t_entry_spot_id on t_entry ("spotId");



DROP TABLE IF EXISTS t_exit;
CREATE TABLE t_exit (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null,
  "entryId" text not null,
  "employeeId" text not null,
  "dateTime" timestamptz not null,
  "amount" numeric not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_exit_parking_id on t_exit ("parkingId");
create index t_exit_entry_id on t_exit ("entryId");
create index t_exit_employee_id on t_exit ("employeeId");



DROP TABLE IF EXISTS t_cash_register;
CREATE TABLE t_cash_register (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null,
  "employeeId" text not null,
  "startDate" timestamptz not null,
  "endDate" timestamptz not null,
  "status" text not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_cash_register_parking_id on t_cash_register ("parkingId");
create index t_cash_register_employee_id on t_cash_register ("employeeId");



DROP TABLE IF EXISTS t_movement;
CREATE TABLE t_movement (
  "id" text primary key not null,
  "cashRegisterId" text not null,
  "type" text not null,
  "amount" numeric not null,
  "description" text not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_movement_cash_register_id on t_movement ("cashRegisterId");



DROP TABLE IF EXISTS t_reservation;
CREATE TABLE t_reservation (
  "id" text primary key not null,
  "number" integer not null,
  "parkingId" text not null,
  "employeeId" text not null,
  "vehicleId" text not null,
  "spotId" text not null,
  "startDate" timestamptz not null,
  "endDate" timestamptz not null,
  "status" text not null,
  "amount" numeric not null,
  "createdAt" timestamptz default now() not null,
  "updatedAt" timestamptz default now()
);

create index t_reservation_parking_id on t_reservation ("parkingId");
create index t_reservation_employee_id on t_reservation ("employeeId");
create index t_reservation_vehicle_id on t_reservation ("vehicleId");
create index t_reservation_spot_id on t_reservation ("spotId");
