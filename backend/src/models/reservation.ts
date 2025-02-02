
import { t } from 'elysia';
import { ParkingSchema } from './parking';
import { EmployeeSchema } from './employee';
import { VehicleSchema } from './vehicle';
import { LevelSchema, SpotSchema } from './level';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const ReservationSchema = t.Object(
  {
    id: t.String({
          description: "Identificador único de la reserva",
          required: true
        }),
  number: t.Integer({
          description: "Número de la reserva",
          required: true
        }),
  parkingId: t.String({
          description: "ID del estacionamiento asociado",
          required: true
        }),
  parking: ParkingSchema,
  employeeId: t.String({
          description: "ID del empleado asociado",
          required: true
        }),
  employee: EmployeeSchema,
  vehicleId: t.String({
          description: "ID del vehículo que realiza la reserva",
          required: true
        }),
  vehicle: VehicleSchema,
  spotId: t.String({
          description: "ID del puesto reservado",
          required: true
        }),
  spot: SpotSchema,
  startDate: t.Union([
      t.String({
        description: 'Fecha y hora de inicio de la reserva',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de inicio de la reserva',
        required: true
      })
    ]),
  endDate: t.Union([
      t.String({
        description: 'Fecha y hora de fin de la reserva',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de fin de la reserva',
        required: true
      })
    ]),
  status: t.String({
          description: "Estado de la reserva (activa, cancelada, etc.)",
          required: true
        }),
  amount: t.Numeric({
          description: "Monto de la reserva",
          required: true
        }),
  createdAt: t.Union([
      t.String({
        description: 'Fecha de creación del registro',
        required: true
      }),
      t.Date({
        description: 'Fecha de creación del registro',
        required: true
      })
    ]),
  updatedAt: t.Union([
      t.String({
        description: 'Fecha de última actualización del registro',
        required: true
      }),
      t.Date({
        description: 'Fecha de última actualización del registro',
        required: true
      })
    ]),
  },
  {
    description: 'Esquema principal para la entidad Reservation'
  }
);

export type Reservation = typeof ReservationSchema.static;

// Modelo de Creación
export const ReservationCreateSchema = t.Object(
  {
    number: t.Integer({
          description: "Número de la reserva",
          required: true
        }),
  parkingId: t.String({
          description: "ID del estacionamiento asociado",
          required: true
        }),
  employeeId: t.String({
          description: "ID del empleado asociado",
          required: true
        }),
  vehicleId: t.String({
          description: "ID del vehículo que realiza la reserva",
          required: true
        }),
  spotId: t.String({
          description: "ID del puesto reservado",
          required: true
        }),
  startDate: t.Union([
      t.String({
        description: 'Fecha y hora de inicio de la reserva',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de inicio de la reserva',
        required: true
      })
    ]),
  endDate: t.Union([
      t.String({
        description: 'Fecha y hora de fin de la reserva',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de fin de la reserva',
        required: true
      })
    ]),
  status: t.String({
          description: "Estado de la reserva (activa, cancelada, etc.)",
          required: true
        }),
  amount: t.Numeric({
          description: "Monto de la reserva",
          required: true
        }),
  },
  {
  description: 'Esquema para la creación de un Reservation'
  }
);

export type ReservationCreate = typeof ReservationCreateSchema.static;

// Modelo de Actualización
export const ReservationUpdateSchema = t.Object(
  {
  number: t.Optional(t.Integer({
          description: "Número de la reserva",
          required: true
        })),
  employeeId: t.Optional(t.String({
          description: "ID del empleado asociado",
          required: true
        })),
  vehicleId: t.Optional(t.String({
          description: "ID del vehículo que realiza la reserva",
          required: true
        })),
  spotId: t.Optional(t.String({
          description: "ID del puesto reservado",
          required: true
        })),
  startDate: t.Optional(t.Union([
      t.String({
        description: 'Fecha y hora de inicio de la reserva',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de inicio de la reserva',
        required: true
      })
    ])),
  endDate: t.Optional(t.Union([
      t.String({
        description: 'Fecha y hora de fin de la reserva',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de fin de la reserva',
        required: true
      })
    ])),
  status: t.Optional(t.String({
          description: "Estado de la reserva (activa, cancelada, etc.)",
          required: true
        })),
  amount: t.Optional(t.Numeric({
          description: "Monto de la reserva",
          required: true
        })),
  },
  {
  description: 'Esquema para la actualización de un Reservation'
  }
);

export type ReservationUpdate = typeof ReservationUpdateSchema.static;
