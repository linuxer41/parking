import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { reportService } from "../services/report";
import { 
  OccupancyReportSchema, 
  RevenueReportSchema, 
  VehicleReportSchema 
} from "../models/report";

export const reportController = new Elysia({ prefix: '/report', tags: ['report'], detail: { summary: 'Reportes del sistema', description: 'Endpoints para generar reportes del sistema.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(reportService)
  .post('/occupancy', async ({ body }) => {
    try {
      const report = await db.report.getOccupancyReport(body);
      return report;
    } catch (error) {
      console.error('Error generating occupancy report:', error);
      throw new Error('Error al generar el reporte de ocupación');
    }
  }, {
    body: 'ReportFilterSchema',
    detail: {
      summary: 'Reporte de ocupación',
      description: 'Genera un reporte de ocupación de espacios por fecha y hora.',
    },
    response: {
      200: OccupancyReportSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  .post('/revenue', async ({ body }) => {
    try {
      const report = await db.report.getRevenueReport(body);
      return report;
    } catch (error) {
      console.error('Error generating revenue report:', error);
      throw new Error('Error al generar el reporte de ingresos');
    }
  }, {
    body: 'ReportFilterSchema',
    detail: {
      summary: 'Reporte de ingresos',
      description: 'Genera un reporte de ingresos por tipo y fecha.',
    },
    response: {
      200: RevenueReportSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  .post('/vehicles', async ({ body }) => {
    try {
      const report = await db.report.getVehicleReport(body);
      return report;
    } catch (error) {
      console.error('Error generating vehicle report:', error);
      throw new Error('Error al generar el reporte de vehículos');
    }
  }, {
    body: 'ReportFilterSchema',
    detail: {
      summary: 'Reporte de vehículos',
      description: 'Genera un reporte de vehículos por tipo.',
    },
    response: {
      200: VehicleReportSchema,
      400: t.String(),
      500: t.String(),
    },
  }); 