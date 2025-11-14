import Elysia, { t } from "elysia";
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { CashRegisterSchema, CashRegister, CashRegisterCreateSchema, CashRegisterUpdateSchema } from "../models/cash-register";
import { NotFoundError } from "../utils/error";

export const cashRegisterController = new Elysia({
  prefix: "/cash-registers",
  tags: ["cash-register"],
  detail: {
    summary: "Obtener todas las cash-registers",
    description: "Retorna una lista de todas las cash-registers registradas.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(accessPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.cashRegister.findCashRegisters({});
      return res as CashRegister[];
    },
    {
      detail: {
        summary: "Obtener todas las cash-registers",
        description: "Retorna una lista de todas las cash-registers registradas.",
      },
      query: t.Object({
        parkingId: t.String({
          description: "ID del parking",
          required: false,
        }),
        status: t.String({
          description: "Estado de la caja registradora",
          required: false,
        }),
      }),
      response: {
        200: t.Array(CashRegisterSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ body }) => {
      const res = await db.cashRegister.createCashRegister(body);
      return res as CashRegister;
    },
    {
      body: CashRegisterCreateSchema,
      detail: {
        summary: "Crear una nueva cash-register",
        description:
          "Crea un nuevo registro de cash-register con los datos proporcionados.",
      },
      response: {
        200: CashRegisterSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const res = await db.cashRegister.findCashRegisterById(params.id);
      if (!res) {
        throw new NotFoundError("Caja registradora no encontrada");
      }
      return res as CashRegister;
    },
    {
      detail: {
        summary: "Obtener una cash-register por ID",
        description: "Retorna una cash-register específica basada en su ID.",
      },
      response: {
        200: CashRegisterSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:id",
    async ({ params, body }) => {
      const res = await db.cashRegister.updateCashRegister(params.id, body);
      return res as CashRegister;
    },
    {
      body: CashRegisterUpdateSchema,
      detail: {
        summary: "Actualizar una cash-register",
        description:
          "Actualiza un registro de cash-register existente con los datos proporcionados.",
      },
      response: {
        200: CashRegisterSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:id",
    async ({ params }) => {
      const res = await db.cashRegister.deleteCashRegister(params.id);
      return res as CashRegister;
    },
    {
      detail: {
        summary: "Eliminar una cash-register",
        description:
          "Elimina un registro de cash-register existente basado en su ID.",
      },
      response: {
        200: CashRegisterSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
