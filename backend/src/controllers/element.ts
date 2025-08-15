import { Elysia } from "elysia";
import { db } from "../db";

export const elementController = new Elysia({ name: "element/controller" })
  // Endpoints generales para elementos
  .get("/elements", async () => {
    try {
      const elements = await db.element.findMany({});
      return {
        success: true,
        data: elements,
        message: "Elementos obtenidos exitosamente",
      };
    } catch (error) {
      console.error("Error al obtener elementos:", error);
      return {
        success: false,
        message: "Error al obtener elementos",
        error: error instanceof Error ? error.message : "Error desconocido",
      };
    }
  })
  .get("/elements/:id", async ({ params: { id } }) => {
    try {
      const element = await db.element.findUnique({ where: { id } });
      if (!element) {
        return {
          success: false,
          message: "Elemento no encontrado",
        };
      }
      return {
        success: true,
        data: element,
        message: "Elemento obtenido exitosamente",
      };
    } catch (error) {
      console.error("Error al obtener elemento:", error);
      return {
        success: false,
        message: "Error al obtener elemento",
        error: error instanceof Error ? error.message : "Error desconocido",
      };
    }
  })
  .get("/elements/area/:areaId", async ({ params: { areaId } }) => {
    try {
      const elements = await db.element.findMany({ where: { areaId } });
      return {
        success: true,
        data: elements,
        message: "Elementos del área obtenidos exitosamente",
      };
    } catch (error) {
      console.error("Error al obtener elementos del área:", error);
      return {
        success: false,
        message: "Error al obtener elementos del área",
        error: error instanceof Error ? error.message : "Error desconocido",
      };
    }
  });
  