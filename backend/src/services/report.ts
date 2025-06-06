import { Elysia, t } from 'elysia';
import { 
  ReportFilterSchema, 
  OccupancyReportSchema, 
  RevenueReportSchema, 
  VehicleReportSchema 
} from "../models/report";

export const reportService = new Elysia({ name: 'report/service' })
  .model({
    ReportFilterSchema,
    OccupancyReportSchema,
    RevenueReportSchema,
    VehicleReportSchema
  }); 