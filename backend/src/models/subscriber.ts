
import { t } from 'elysia';
import { ParkingSchema } from './parking';
import { EmployeeSchema } from './employee';
import { VehicleSchema } from './vehicle';
import { SubscriptionPlanSchema } from './subscription-plan';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const SubscriberSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del abonado",
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
      description: "ID del vehículo asociado",
      required: true
    }
  ),
  vehicle: VehicleSchema,
  planId: t.String(
    {
      description: "ID del plan de suscripción",
      required: true
    }
  ),
  plan: SubscriptionPlanSchema,
  startDate: t.Union([
    t.String(
      {
        description: 'Fecha de inicio del abono',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de inicio del abono',
        required: true
      })
  ]),
  endDate: t.Union([
    t.String(
      {
        description: 'Fecha de fin del abono',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de fin del abono',
        required: true
      })
  ]),
  isActive: t.Boolean(
    {
      description: "Indica si el abono está activo",
      required: true
    }
  ),
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
    description: 'Esquema principal para la entidad Subscriber'
  }
);

export type Subscriber = typeof SubscriberSchema.static;

// Modelo de Creación
export const SubscriberCreateSchema = t.Object(
  {
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
      description: "ID del vehículo asociado",
      required: true
    }
  ),
  planId: t.String(
    {
      description: "ID del plan de suscripción",
      required: true
    }
  ),
  startDate: t.Union([
    t.String(
      {
        description: 'Fecha de inicio del abono',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de inicio del abono',
        required: true
      })
  ]),
  endDate: t.Union([
    t.String(
      {
        description: 'Fecha de fin del abono',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de fin del abono',
        required: true
      })
  ]),
  isActive: t.Boolean(
    {
      description: "Indica si el abono está activo",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Subscriber'
  }
);

export type SubscriberCreate = typeof SubscriberCreateSchema.static;

// Modelo de Actualización
export const SubscriberUpdateSchema = t.Object(
  {
  planId: t.String(
    {
      description: "ID del plan de suscripción",
      required: true
    }
  ),
  startDate: t.Union([
    t.String(
      {
        description: 'Fecha de inicio del abono',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de inicio del abono',
        required: true
      })
  ]),
  endDate: t.Union([
    t.String(
      {
        description: 'Fecha de fin del abono',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de fin del abono',
        required: true
      })
  ]),
  isActive: t.Boolean(
    {
      description: "Indica si el abono está activo",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Subscriber'
  }
);

export type SubscriberUpdate = typeof SubscriberUpdateSchema.static;
