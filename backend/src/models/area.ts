import { t } from "elysia";
import { ParkingSchema } from "./parking";
import { BaseSchema } from "./base-model";
import { ElementSchema } from "./element";

// Modelo Principal
export const AreaSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    name: t.String({
      description: "Nombre del nivel",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento al que pertenece el nivel",
      required: true,
    }),
    totalSpots: t.Integer({
      description: "Cantidad total de spots en el área",
      required: true,
    }),
    occupiedSpots: t.Integer({
      description: "Cantidad de spots ocupados en el área",
      required: true,
    }),
    availableSpots: t.Integer({
      description: "Cantidad de spots disponibles en el área",
      required: true,
    }),
    elements: t.Optional(t.Array(ElementSchema)),
  },
  {
    description: "Esquema principal para la entidad Area",
  },
);

export type Area = typeof AreaSchema.static;

export const AreaCreateSchema = t.Pick(AreaSchema, ["name", "parkingId"], {
  description: "Esquema para la creación de un Area",
});

export type AreaCreate = typeof AreaCreateSchema.static;

// Modelo de Actualización
export const AreaUpdateSchema = t.Pick(AreaSchema, ["name"], {
  description: "Esquema para la actualización de un Area",
});

export type AreaUpdate = typeof AreaUpdateSchema.static;
