import { BaseCrud } from "./base-crud";
import {
  Subscription,
  SubscriptionCreate,
  SubscriptionUpdate,
} from "../../models/subscription";

class SubscriptionCrud extends BaseCrud<
  Subscription,
  SubscriptionCreate,
  SubscriptionUpdate
> {
  constructor() {
    super("t_subscription", "s");
  }

  baseQuery() {
    return `
select 
  s.id,
  s."createdAt",
  s."updatedAt",
  s."deletedAt",
  s."parkingId",
  s."employeeId",
  s."vehicleId",
  s."spotId",
  s."startDate",
  s."endDate",
  s.amount,
  --s."isActive",
  s.status,
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
from t_subscription s
inner join t_parking p on p.id = s."parkingId"
inner join t_employee e on e.id = s."employeeId"
inner join t_user u on u.id = e."userId"
inner join t_vehicle v on v.id = s."vehicleId"
inner join t_element el on el.id = s."spotId"
`;
  }
}

export const subscriptionCrud = new SubscriptionCrud();
