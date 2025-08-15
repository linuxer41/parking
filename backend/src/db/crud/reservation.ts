import { BaseCrud } from "./base-crud";
import {
  Reservation,
  ReservationCreate,
  ReservationUpdate,
} from "../../models/reservation";

class ReservationCrud extends BaseCrud<
  Reservation,
  ReservationCreate,
  ReservationUpdate
> {
  constructor() {
    super("t_reservation", "r");
  }

  baseQuery() {
    return `
select 
  r.id,
  r."createdAt",
  r."updatedAt",
  r."deletedAt",
  r.number,
  r."parkingId",
  r."employeeId",
  r."vehicleId",
  r."spotId",
  r."startDate",
  r."endDate",
  r.status,
  r.amount,
  jsonb_build_object(
    'id', p.id,
    'name', p.name,
    'address', p.address,
    'logoUrl', p."logoUrl",
    'params', p.params
  ) as "parking",
  jsonb_build_object(
    'id', e.id,
    'role', e.role,
    'name', u.name,
    'email', u.email,
    'phone', u.phone
  ) as "employee",
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
  ) as "spot"
from t_reservation r
inner join t_parking p on p.id = r."parkingId"
inner join t_employee e on e.id = r."employeeId"
inner join t_user u on u.id = e."userId"
inner join t_vehicle v on v.id = r."vehicleId"
inner join t_element el on el.id = r."spotId"
`;
  }
}

export const reservationCrud = new ReservationCrud();
