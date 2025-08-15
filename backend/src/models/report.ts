import { t } from "elysia";

// Esquema para datos de ocupación
export const OccupancyDataSchema = t.Object({
  date: t.String({
    description: "Fecha del registro de ocupación",
    required: true,
  }),
  hour: t.Integer({
    description: "Hora del día (0-23)",
    required: true,
  }),
  totalSpots: t.Integer({
    description: "Total de espacios disponibles",
    required: true,
  }),
  occupiedSpots: t.Integer({
    description: "Espacios ocupados",
    required: true,
  }),
  occupancyRate: t.Numeric({
    description: "Tasa de ocupación (porcentaje)",
    required: true,
  }),
});

export type OccupancyData = typeof OccupancyDataSchema.static;

// Esquema para datos de ingresos
export const RevenueDataSchema = t.Object({
  date: t.String({
    description: "Fecha del registro de ingresos",
    required: true,
  }),
  regularAmount: t.Numeric({
    description: "Ingresos por estacionamiento regular",
    required: true,
  }),
  subscriptionAmount: t.Numeric({
    description: "Ingresos por suscripciones",
    required: true,
  }),
  reservationAmount: t.Numeric({
    description: "Ingresos por reservaciones",
    required: true,
  }),
  totalAmount: t.Numeric({
    description: "Ingresos totales",
    required: true,
  }),
});

export type RevenueData = typeof RevenueDataSchema.static;

// Esquema para datos de vehículos
export const VehicleDataSchema = t.Object({
  vehicleTypeId: t.String({
    description: "ID del tipo de vehículo",
    required: true,
  }),
  vehicleTypeName: t.String({
    description: "Nombre del tipo de vehículo",
    required: true,
  }),
  count: t.Integer({
    description: "Cantidad de vehículos",
    required: true,
  }),
  percentage: t.Numeric({
    description: "Porcentaje del total",
    required: true,
  }),
});

export type VehicleData = typeof VehicleDataSchema.static;

// Esquema de filtros para reportes
export const ReportFilterSchema = t.Object({
  parkingId: t.String({
    description: "ID del estacionamiento",
    required: true,
  }),
  startDate: t.String({
    description: "Fecha de inicio (formato YYYY-MM-DD)",
    required: true,
  }),
  endDate: t.String({
    description: "Fecha de fin (formato YYYY-MM-DD)",
    required: true,
  }),
  groupBy: t.Optional(
    t.Enum(["day", "week", "month"], {
      description: "Agrupación de datos",
    }),
  ),
});

export type ReportFilter = typeof ReportFilterSchema.static;

// Respuestas de reportes
export const OccupancyReportSchema = t.Object({
  parkingName: t.String({
    description: "Nombre del estacionamiento",
    required: true,
  }),
  startDate: t.String({
    description: "Fecha de inicio del reporte",
    required: true,
  }),
  endDate: t.String({
    description: "Fecha de fin del reporte",
    required: true,
  }),
  data: t.Array(OccupancyDataSchema),
});

export type OccupancyReport = typeof OccupancyReportSchema.static;

export const RevenueReportSchema = t.Object({
  parkingName: t.String({
    description: "Nombre del estacionamiento",
    required: true,
  }),
  startDate: t.String({
    description: "Fecha de inicio del reporte",
    required: true,
  }),
  endDate: t.String({
    description: "Fecha de fin del reporte",
    required: true,
  }),
  totalRevenue: t.Numeric({
    description: "Ingresos totales en el período",
    required: true,
  }),
  data: t.Array(RevenueDataSchema),
});

export type RevenueReport = typeof RevenueReportSchema.static;

export const VehicleReportSchema = t.Object({
  parkingName: t.String({
    description: "Nombre del estacionamiento",
    required: true,
  }),
  startDate: t.String({
    description: "Fecha de inicio del reporte",
    required: true,
  }),
  endDate: t.String({
    description: "Fecha de fin del reporte",
    required: true,
  }),
  totalVehicles: t.Integer({
    description: "Total de vehículos en el período",
    required: true,
  }),
  data: t.Array(VehicleDataSchema),
});

export type VehicleReport = typeof VehicleReportSchema.static;
