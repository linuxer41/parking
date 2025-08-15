import { t } from "elysia";

/**
 * Esquema base con campos comunes para todos los modelos
 */
export const BaseSchema = t.Object(
  {
    id: t.String({
      description: "Identificador único del registro",
      required: true,
    }),
    createdAt: t.Union([
      t.String({
        description: "Fecha de creación del registro",
        required: true,
      }),
      t.Date({
        description: "Fecha de creación del registro",
        required: true,
      }),
    ]),
    updatedAt: t.Union([
      t.String({
        description: "Fecha de última actualización del registro",
        required: true,
      }),
      t.Date({
        description: "Fecha de última actualización del registro",
        required: true,
      }),
    ]),
    deletedAt: t.Optional(
      t.Union([
        t.String({
          description: "Fecha de eliminación del registro",
          required: false,
        }),
        t.Date({
          description: "Fecha de eliminación del registro",
          required: false,
        }),
        t.Null({
          description: "Valor nulo para registros no eliminados",
        }),
      ]),
    ),
  },
  {
    description: "Esquema base con campos comunes para todos los modelos",
  },
);

export type BaseModel = typeof BaseSchema.static;
