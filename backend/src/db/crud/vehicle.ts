
import { BaseCrud } from './base-crud';
import { Vehicle, VehicleCreate, VehicleUpdate } from '../../models/vehicle';

class VehicleCrud extends BaseCrud<Vehicle, VehicleCreate, VehicleUpdate> {
  constructor() {
    super('t_vehicle');
  }

  baseQuery() {
    return `
select t_vehicle.* , to_jsonb(t_parking.*) as "parking"
from t_vehicle
inner join t_parking on t_parking.id = t_vehicle."parkingId"
`;
  }
}

export const vehicleCrud = new VehicleCrud()
