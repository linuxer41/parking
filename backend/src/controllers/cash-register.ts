import Elysia, { t } from "elysia";
import { db } from "../db";
import { authPlugin } from "../plugins/access";
import { CashRegisterSchema, CashRegister, CashRegisterCreateSchema, CashRegisterUpdateSchema, CashRegisterResponseSchema, CashRegisterResponse, CashRegisterCreateRequestSchema } from "../models/cash-register";
import { ApiError, BadRequestError, NotFoundError } from "../utils/error";

export const cashRegisterController = new Elysia({
  prefix: "/cash-registers",
  tags: ["cash-register"],
  detail: {
    summary: "Cash Register Management",
    description: "Endpoints for managing cash register sessions.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(authPlugin)
  .get(
    "/",
    async ({ query, employee, parking }) => {
      const res = await db.cashRegister.find({
        parkingId: parking.id,
        closed: true,

      });
      console.log(res);
      return res;
    },
    {
      detail: {
        summary: "Obtener todas las cash-registers",
        description: "Retorna una lista de todas las cash-registers registradas.",
      },
      query: t.Object({
        
        status: t.Optional(t.Union([
          t.Literal("active", { description: "Caja activa (abierta)" }),
          t.Literal("verified", { description: "Caja verificada (dueño recogió el dinero)" }),
        ], {
          description: "Estado de la caja registradora",
          required: false,
        })),
      }),
      response: {
        200: t.Array(CashRegisterResponseSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/current",
    async ({ employee }) => {
      const res = await db.cashRegister.find({ employeeId: employee.id, status: "active" });
      
      if (!res.length) {
        throw new NotFoundError("No se a aperturado ninguna caja registradora");
      }
      if (res.length > 1) {
        throw new BadRequestError("Hay más de una caja registradora abierta");
      }

      return res[0];
    },
    {
      detail: {
        summary: "Get current active cash register for employee",
        description: "Returns the active cash register session for the authenticated employee.",
      },
      response: {
        200: CashRegisterResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/open",
    async ({ body, employee, parking }) => {
      const employeeId = employee.id;
      const parkingId = parking.id;

      // Check for active cash registers for the same employee and parking
      const activeCashRegisters = await db.cashRegister.find({ parkingId, employeeId, status: "active" });
      if (activeCashRegisters.length >= 2) {
        throw new BadRequestError("No se puede abrir más de 2 cajas registradoras activas para el mismo empleado y parque");
      }

      // Get the next number for the parking
      const existing = await db.cashRegister.find({ parkingId, employeeId });
      const maxNumber = existing.length > 0 ? Math.max(...existing.map(cr => cr.number)) : 0;
      const number = maxNumber + 1;

      const res = await db.cashRegister.create({
        number,
        employeeId,
        parkingId,
        status: "active",
        initialAmount: body.initialAmount,
        startDate: new Date().toISOString(),
      });
      return res as CashRegisterResponse;
    },
    {
      body: CashRegisterCreateRequestSchema,
      detail: {
        summary: "Open a new cash register session",
        description: "Creates a new active cash register session for the authenticated employee.",
      },
      response: {
        200: CashRegisterResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/:id/close",
    async ({ params }) => {
      const res = await db.cashRegister.update(params.id, {
        status: "verified",
        endDate: new Date().toISOString(),
      });
      return res;
    },
    {
      detail: {
        summary: "Close a cash register session",
        description: "Closes the specified cash register session.",
      },
      response: {
        200: CashRegisterResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
 
  .get(
    "/:id",
    async ({ params }) => {
      const res = await db.cashRegister.getById(params.id);
      if (!res) {
        throw new NotFoundError("Caja registradora no encontrada");
      }
      return res;
    },
    {
      detail: {
        summary: "Obtener una cash-register por ID",
        description: "Retorna una cash-register específica basada en su ID.",
      },
      response: {
        200: CashRegisterResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
