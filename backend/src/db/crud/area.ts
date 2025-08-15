import { BaseCrud } from "./base-crud";
import { Area, AreaCreate, AreaUpdate } from "../../models/area";
import { elementCrud } from "./element";

class AreaCrud extends BaseCrud<Area, AreaCreate, AreaUpdate> {
  constructor() {
    super("t_area", "a");
  }

  baseQuery() {
    return `
select 
  a.*,
  jsonb_build_object(
    'id', t_parking.id,
    'name', t_parking.name,
    'email', t_parking.email,
    'phone', t_parking.phone,
    'address', t_parking.address,
    'logoUrl', t_parking."logoUrl",
    'status', t_parking.status,
    'ownerId', t_parking."ownerId",
    'params', t_parking.params,
    'rates', t_parking.rates,
    'createdAt', t_parking."createdAt",
    'updatedAt', t_parking."updatedAt",
    'deletedAt', t_parking."deletedAt"
  ) as "parking"
from t_area a
inner join t_parking on t_parking.id = a."parkingId"
`;
  }
}

export const areaCrud = new AreaCrud();
