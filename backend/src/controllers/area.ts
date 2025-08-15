import { Elysia, t } from "elysia";
import { areaCrud } from "../db/crud/area";

export const areaController = new Elysia({ name: "area/controller" })
  .get("/areas/:id", async ({ params: { id } }) => {
    try {
      const area = await areaCrud.findFirst({ where: { id } });
      if (!area) {
        return {
          success: false,
          message: "Área no encontrada",
        };
      }
      return {
        success: true,
        data: area,
        message: "Área obtenida exitosamente",
      };
    } catch (error) {
      console.error("Error al obtener área:", error);
      return {
        success: false,
        message: "Error al obtener área",
        error: error instanceof Error ? error.message : "Error desconocido",
      };
    }
  })
  .get("/areas/:id/with-elements", async ({ params: { id } }) => {
    try {
      const area = await areaCrud.getAreaWithElements(id);
      if (!area) {
        return {
          success: false,
          message: "Área no encontrada",
        };
      }
      return {
        success: true,
        data: area,
        message: "Área con elementos obtenida exitosamente",
      };
    } catch (error) {
      console.error("Error al obtener área con elementos:", error);
      return {
        success: false,
        message: "Error al obtener área con elementos",
        error: error instanceof Error ? error.message : "Error desconocido",
      };
    }
  })
  .get("/areas/parking/:parkingId", async ({ params: { parkingId } }) => {
    try {
      const areas = await areaCrud.getAreasByParking(parkingId);
      return {
        success: true,
        data: areas,
        message: "Áreas del estacionamiento obtenidas exitosamente",
      };
    } catch (error) {
      console.error("Error al obtener áreas del estacionamiento:", error);
      return {
        success: false,
        message: "Error al obtener áreas del estacionamiento",
        error: error instanceof Error ? error.message : "Error desconocido",
      };
    }
  });