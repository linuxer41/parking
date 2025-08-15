import { BaseCrud } from "./base-crud";
import { Access, AccessCreate, AccessPreview, AccessUpdate } from "../../models/access";
import { getConnection } from "../connection";
import { PoolClient } from "pg";

class AccessCrud extends BaseCrud<Access, AccessCreate, AccessUpdate> {
  constructor() {
    super("t_access", "a");
  }

  baseQuery() {
    return `
select 
  a.*,
  ar.id as "areaId",
  jsonb_build_object(
    'id', p.id,
    'name', p.name,
    'address', p.address,
    'logoUrl', p."logoUrl",
    'params', p.params
  ) as "parking", 
  jsonb_build_object(
    'id', ee.id,
    'role', ee.role,
    'name', eu.name,
    'email', eu.email,
    'phone', eu.phone
  ) as "entryEmployee",
  (
    case when a."exitEmployeeId" is not null then 
    jsonb_build_object(
      'id', xe.id,
      'role', xe.role,
      'name', xu.name,
      'email', xu.email,
      'phone', xu.phone
    )
    else null
    end
  ) as "exitEmployee",
  jsonb_build_object(
    'id', v.id,
    'plate', v.plate,
    'color', v.color,
    'type', v.type,
    'ownerName', v."ownerName",
    'ownerDocument', v."ownerDocument",
    'ownerPhone', v."ownerPhone"
  ) as "vehicle", 
  jsonb_build_object(
    'id', el.id,
    'name', el.name,
    'type', el.type,
    'subType', el."subType"
  ) as "spot",
  (
    case when a."subscriptionId" is not null then 
    jsonb_build_object(
      'id', s.id,
      'parking', jsonb_build_object('id', ps.id, 'name', ps.name, 'address', ps.address, 'logoUrl', ps."logoUrl", 'params', ps.params),
      'employee', jsonb_build_object('id', se.id, 'role', se.role, 'name', su.name, 'email', su.email, 'phone', su.phone),
      'vehicle', jsonb_build_object('id', sv.id, 'plate', sv.plate, 'color', sv.color, 'type', sv.type, 'ownerName', sv."ownerName", 'ownerDocument', sv."ownerDocument", 'ownerPhone', sv."ownerPhone"),
      'startDate', s."startDate",
      'endDate', s."endDate",
      'amount', s.amount
    )
    else null
    end
  ) as "subscription",
  (
    case when a."reservationId" is not null then 
    jsonb_build_object(
      'id', r.id,
      'number', r.number,
      'parkingId', r."parkingId",
      'employeeId', r."employeeId",
      'vehicleId', r."vehicleId",
      'spotId', r."spotId",
      'startDate', r."startDate",
      'endDate', r."endDate",
      'status', r.status,
      'amount', r.amount
    )
    else null
    end
  ) as "reservation"
from t_access a
inner join t_parking p on p.id = a."parkingId"
inner join t_employee ee on ee.id = a."entryEmployeeId"
inner join t_user eu on eu.id = ee."userId"
left join t_employee xe on xe.id = a."exitEmployeeId"
left join t_user xu on xu.id = xe."userId"
inner join t_vehicle v on v.id = a."vehicleId"
inner join t_area ar on ar."parkingId" = a."parkingId"
inner join t_element el on el."parkingId" = a."parkingId" and el."id" = a."spotId"
left join t_subscription s on s.id = a."subscriptionId"
left join t_parking ps on ps.id = s."parkingId"
left join t_employee se on se.id = s."employeeId"
left join t_user su on su.id = se."userId"
left join t_vehicle sv on sv.id = s."vehicleId"
left join t_reservation r on r.id = a."reservationId"
`;
  }

  async getLastNumber(parkingId: string): Promise<number> {
    const accesses = await this.query<{ lastNumber: number }>({
      sql: `select max(number) as "lastNumber" from t_access where "parkingId" = $1`,
      params: [parkingId]
    });
    return accesses[0].lastNumber || 0;
  }

  async create({ data }: { data: AccessCreate }): Promise<Access> {
    data = {
      ...data,
      amount: 0,
      number: await this.getLastNumber(data.parkingId) + 1,
      entryTime: new Date().toISOString(),
      status: 'active'
    } as AccessCreate;
    return super.create({ data });
  }
}

export const accessCrud = new AccessCrud(); 