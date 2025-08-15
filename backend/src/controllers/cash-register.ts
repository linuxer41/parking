import Elysia from "elysia";
import { t } from "elysia";
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { CashRegisterSchema, CashRegister, CashRegisterCreateSchema, CashRegisterUpdateSchema } from "../models/cash-register";

export const cashRegisterController = new Elysia({
  prefix: "/cash-registers",
  tags: ["cash-register"],
  detail: {
    summary: "Obtener todos los cash-registers",
    description: "Retorna una lista de todos los cash-registers registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(accessPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.cashRegister.findMany({});
      return res as CashRegister[];
    },
    {
      detail: {
        summary: "Obtener todos los cash-registers",
        description:
          "Retorna una lista de todos los cash-registers registrados.",
      },
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
      const res = await db.cashRegister.create({
        data: body,
      });
      return res as CashRegister;
    },
    {
      body: CashRegisterCreateSchema,
      detail: {
        summary: "Crear un nuevo cash-register",
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
      const res = await db.cashRegister.findUnique({
        where: {
          id: params.id,
        },
      });
      return res as CashRegister;
    },
    {
      detail: {
        summary: "Obtener un cash-register por ID",
        description: "Retorna un cash-register específico basado en su ID.",
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
      const res = await db.cashRegister.update({
        where: {
          id: params.id,
        },
        data: body,
      });
      return res as CashRegister;
    },
    {
      body: CashRegisterUpdateSchema,
      detail: {
        summary: "Actualizar un cash-register",
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
      const res = await db.cashRegister.delete({
        where: {
          id: params.id,
        },
      });
      return res as CashRegister;
    },
    {
      detail: {
        summary: "Eliminar un cash-register",
        description: "Elimina un registro de cash-register basado en su ID.",
      },
      response: {
        200: CashRegisterSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
