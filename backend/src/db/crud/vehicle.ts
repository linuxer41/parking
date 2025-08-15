import { BaseCrud } from "./base-crud";
import { Vehicle, VehicleCreate, VehicleUpdate } from "../../models/vehicle";

class VehicleCrud extends BaseCrud<Vehicle, VehicleCreate, VehicleUpdate> {
  constructor() {
    super("t_vehicle", "v");
  }

  baseQuery() {
    return `
select 
    v.*,

    -- Subscription data como subquery
    (
        select json_build_object(
            'id', s.id,
            'spotId', s."spotId",
            'spotName', sp.name,
            'startDate', s."startDate",
            'endDate', s."endDate",
            'amount', s.amount
        )
        from t_subscription s
        join t_element sp on sp.id = s."spotId"
        where s."vehicleId" = v.id
          and s.status = 'active'
          and now() between s."startDate" and s."endDate"
          and s."parkingId" = v."parkingId"
        limit 1
    ) as "subscription",

    -- Reservation data como subquery
    (
        select json_build_object(
            'id', r.id,
            'spotId', r."spotId",
            'spotName', sp.name,
            'startDate', r."startDate",
            'endDate', r."endDate",
            'amount', r.amount
        )
        from t_reservation r
        join t_element sp on sp.id = r."spotId"
        where r."vehicleId" = v.id
          and r.status = 'active'
          and now() between r."startDate" and r."endDate"
          and r."parkingId" = v."parkingId"
        limit 1
    ) as "reservation",

    -- Access data como subquery
    (
        select json_build_object(
            'id', a.id,
            'spotId', a."spotId",
            'spotName', sp.name,
            'entryTime', a."entryTime",
            'exitTime', a."exitTime",
            'amount', a.amount
        )
        from t_access a
        join t_element sp on sp.id = a."spotId"
        where a."vehicleId" = v.id
          and a.status = 'active'
          and a."exitTime" is null
          and a."parkingId" = v."parkingId"
        limit 1
    ) as "access"
from t_vehicle v
`;
  }
}

export const vehicleCrud = new VehicleCrud();
