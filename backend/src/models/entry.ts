
import { t } from 'elysia';
import { ParkingSchema } from './parking';
import { EmployeeSchema } from './employee';
import { VehicleSchema } from './vehicle';
import { SpotSchema } from './level';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const EntrySchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único de la entrada",
      required: true
    }
  ),
  number: t.Integer(
    {
      description: "Número de la entrada",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  parking: ParkingSchema,
  employeeId: t.String(
    {
      description: "ID del empleado asociado",
      required: true
    }
  ),
  employee: EmployeeSchema,
  vehicleId: t.String(
    {
      description: "ID del vehículo que ingresó",
      required: true
    }
  ),
  vehicle: VehicleSchema,
  spotId: t.String(
    {
      description: "ID del lugar de estacionamiento asignado",
      required: true
    }
  ),
  spot: SpotSchema,
  dateTime: t.Union([
    t.String(
      {
        description: 'Fecha y hora de la entrada',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha y hora de la entrada',
        required: true
      })
  ]),
  createdAt: t.Union([
    t.String(
      {
        description: 'Fecha de creación del registro',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de creación del registro',
        required: true
      })
  ]),
  updatedAt: t.Union([
    t.String(
      {
        description: 'Fecha de última actualización del registro',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de última actualización del registro',
        required: true
      })
  ]),
  },
  {
    description: 'Esquema principal para la entidad Entry'
  }
);

export type Entry = typeof EntrySchema.static;

// Modelo de Creación
export const EntryCreateSchema = t.Object(
  {
    number: t.Integer(
    {
      description: "Número de la entrada",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  employeeId: t.String(
    {
      description: "ID del empleado asociado",
      required: true
    }
  ),
  vehicleId: t.String(
    {
      description: "ID del vehículo que ingresó",
      required: true
    }
  ),
  spotId: t.String(
    {
      description: "ID del lugar de estacionamiento asignado",
      required: true
    }
  ),
  dateTime: t.Union([
    t.String(
      {
        description: 'Fecha y hora de la entrada',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha y hora de la entrada',
        required: true
      })
  ]),
  },
  {
  description: 'Esquema para la creación de un Entry'
  }
);

export type EntryCreate = typeof EntryCreateSchema.static;

// Modelo de Actualización
export const EntryUpdateSchema = t.Object(
  {
  number: t.Integer(
    {
      description: "Número de la entrada",
      required: true
    }
  ),
  employeeId: t.String(
    {
      description: "ID del empleado asociado",
      required: true
    }
  ),
  vehicleId: t.String(
    {
      description: "ID del vehículo que ingresó",
      required: true
    }
  ),
  spotId: t.String(
    {
      description: "ID del lugar de estacionamiento asignado",
      required: true
    }
  ),
  dateTime: t.Union([
    t.String(
      {
        description: 'Fecha y hora de la entrada',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha y hora de la entrada',
        required: true
      })
  ]),
  },
  {
  description: 'Esquema para la actualización de un Entry'
  }
);

export type EntryUpdate = typeof EntryUpdateSchema.static;
