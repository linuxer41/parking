import { BaseCrud } from './base-crud';
import { 
  OccupancyReport, 
  RevenueReport, 
  VehicleReport, 
  ReportFilter 
} from '../../models/report';

class ReportCrud extends BaseCrud<any, any, any> {
  constructor() {
    super('');
  }

  async getOccupancyReport(filter: ReportFilter): Promise<OccupancyReport> {
    const groupBy = filter.groupBy || 'day';
    let groupFormat = '';
    
    switch(groupBy) {
      case 'day':
        groupFormat = 'YYYY-MM-DD';
        break;
      case 'week':
        groupFormat = 'IYYY-IW';
        break;
      case 'month':
        groupFormat = 'YYYY-MM';
        break;
    }

    const sql = `
      WITH spot_counts AS (
        SELECT 
          l.id as level_id,
          l."parkingId",
          jsonb_array_length(l.spots) as total_spots
        FROM t_level l
        WHERE l."parkingId" = $1
      ),
      total_spots AS (
        SELECT 
          "parkingId",
          SUM(total_spots) as total_spots
        FROM spot_counts
        GROUP BY "parkingId"
      ),
      hourly_entries AS (
        SELECT 
          TO_CHAR(e."dateTime", '${groupFormat}') as date_group,
          EXTRACT(HOUR FROM e."dateTime") as hour,
          COUNT(*) as entries
        FROM t_entry e
        WHERE e."parkingId" = $1
          AND e."dateTime" >= $2
          AND e."dateTime" <= $3
        GROUP BY date_group, hour
      ),
      hourly_exits AS (
        SELECT 
          TO_CHAR(ex."dateTime", '${groupFormat}') as date_group,
          EXTRACT(HOUR FROM ex."dateTime") as hour,
          COUNT(*) as exits
        FROM t_exit ex
        JOIN t_entry e ON e.id = ex."entryId"
        WHERE e."parkingId" = $1
          AND ex."dateTime" >= $2
          AND ex."dateTime" <= $3
        GROUP BY date_group, hour
      ),
      occupancy AS (
        SELECT 
          he.date_group,
          he.hour,
          COALESCE(SUM(he.entries), 0) as entries,
          COALESCE(SUM(hex.exits), 0) as exits,
          SUM(COALESCE(he.entries, 0)) - SUM(COALESCE(hex.exits, 0)) as occupied_spots
        FROM hourly_entries he
        LEFT JOIN hourly_exits hex ON he.date_group = hex.date_group AND he.hour = hex.hour
        GROUP BY he.date_group, he.hour
      )
      SELECT 
        p.name as "parkingName",
        $2::text as "startDate",
        $3::text as "endDate",
        json_agg(
          json_build_object(
            'date', o.date_group,
            'hour', o.hour,
            'totalSpots', ts.total_spots,
            'occupiedSpots', LEAST(o.occupied_spots, ts.total_spots),
            'occupancyRate', ROUND((LEAST(o.occupied_spots, ts.total_spots) * 100.0 / ts.total_spots), 2)
          )
        ) as data
      FROM occupancy o
      JOIN total_spots ts ON ts."parkingId" = $1
      JOIN t_parking p ON p.id = $1
      GROUP BY p.name, ts.total_spots
    `;

    const res = await this.query<OccupancyReport>({ 
      sql, 
      params: [filter.parkingId, filter.startDate, filter.endDate] 
    });
    
    return res[0];
  }

  async getRevenueReport(filter: ReportFilter): Promise<RevenueReport> {
    const groupBy = filter.groupBy || 'day';
    let groupFormat = '';
    
    switch(groupBy) {
      case 'day':
        groupFormat = 'YYYY-MM-DD';
        break;
      case 'week':
        groupFormat = 'IYYY-IW';
        break;
      case 'month':
        groupFormat = 'YYYY-MM';
        break;
    }

    const sql = `
      WITH regular_revenue AS (
        SELECT 
          TO_CHAR(ex."dateTime", '${groupFormat}') as date_group,
          SUM(ex.amount) as amount
        FROM t_exit ex
        JOIN t_entry e ON e.id = ex."entryId"
        WHERE e."parkingId" = $1
          AND ex."dateTime" >= $2
          AND ex."dateTime" <= $3
        GROUP BY date_group
      ),
      subscription_revenue AS (
        SELECT 
          TO_CHAR(s."startDate", '${groupFormat}') as date_group,
          SUM((p."price" / p."duration")) as amount
        FROM t_subscriber s
        JOIN t_parking park ON park.id = s."parkingId"
        JOIN jsonb_to_recordset(park."subscriptionPlans") AS p(id text, price numeric, duration integer)
          ON p.id = s."planId"
        WHERE s."parkingId" = $1
          AND s."startDate" >= $2
          AND s."startDate" <= $3
        GROUP BY date_group
      ),
      reservation_revenue AS (
        SELECT 
          TO_CHAR(r."startDate", '${groupFormat}') as date_group,
          SUM(r.amount) as amount
        FROM t_reservation r
        WHERE r."parkingId" = $1
          AND r."startDate" >= $2
          AND r."startDate" <= $3
        GROUP BY date_group
      ),
      combined_revenue AS (
        SELECT 
          COALESCE(rr.date_group, sr.date_group, resv.date_group) as date_group,
          COALESCE(rr.amount, 0) as regular_amount,
          COALESCE(sr.amount, 0) as subscription_amount,
          COALESCE(resv.amount, 0) as reservation_amount,
          COALESCE(rr.amount, 0) + COALESCE(sr.amount, 0) + COALESCE(resv.amount, 0) as total_amount
        FROM regular_revenue rr
        FULL OUTER JOIN subscription_revenue sr ON rr.date_group = sr.date_group
        FULL OUTER JOIN reservation_revenue resv ON rr.date_group = resv.date_group
      )
      SELECT 
        p.name as "parkingName",
        $2::text as "startDate",
        $3::text as "endDate",
        SUM(cr.total_amount) as "totalRevenue",
        json_agg(
          json_build_object(
            'date', cr.date_group,
            'regularAmount', cr.regular_amount,
            'subscriptionAmount', cr.subscription_amount,
            'reservationAmount', cr.reservation_amount,
            'totalAmount', cr.total_amount
          )
        ) as data
      FROM combined_revenue cr
      JOIN t_parking p ON p.id = $1
      GROUP BY p.name
    `;

    const res = await this.query<RevenueReport>({ 
      sql, 
      params: [filter.parkingId, filter.startDate, filter.endDate] 
    });
    
    return res[0];
  }

  async getVehicleReport(filter: ReportFilter): Promise<VehicleReport> {
    const sql = `
      WITH vehicle_counts AS (
        SELECT 
          v."typeId",
          jsonb_array_elements(p."vehicleTypes") ->> 'name' as type_name,
          COUNT(*) as count
        FROM t_entry e
        JOIN t_vehicle v ON v.id = e."vehicleId"
        JOIN t_parking p ON p.id = e."parkingId"
        WHERE e."parkingId" = $1
          AND e."dateTime" >= $2
          AND e."dateTime" <= $3
        GROUP BY v."typeId", type_name
      ),
      total_count AS (
        SELECT SUM(count) as total FROM vehicle_counts
      )
      SELECT 
        p.name as "parkingName",
        $2::text as "startDate",
        $3::text as "endDate",
        (SELECT total FROM total_count) as "totalVehicles",
        json_agg(
          json_build_object(
            'vehicleTypeId', vc."typeId",
            'vehicleTypeName', vc.type_name,
            'count', vc.count,
            'percentage', ROUND((vc.count * 100.0 / tc.total), 2)
          )
        ) as data
      FROM vehicle_counts vc, total_count tc
      JOIN t_parking p ON p.id = $1
      GROUP BY p.name, tc.total
    `;

    const res = await this.query<VehicleReport>({ 
      sql, 
      params: [filter.parkingId, filter.startDate, filter.endDate] 
    });
    
    return res[0];
  }
}

export const reportCrud = new ReportCrud(); 