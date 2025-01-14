
import { BaseCrud } from './base-crud';
import { Entry, EntryCreate, EntryUpdate } from '../../models/entry';

class EntryCrud extends BaseCrud<Entry, EntryCreate, EntryUpdate> {
  constructor() {
    super('t_entry');
  }

  baseQuery() {
    return `
select t_entry.* , to_jsonb(t_parking.*) as "parking", to_jsonb(t_employee.*) as "employee", to_jsonb(t_vehicle.*) as "vehicle", to_jsonb(t_spot.*) as "spot"
from t_entry
inner join t_parking on t_parking.id = t_entry."parkingId"
inner join t_employee on t_employee.id = t_entry."employeeId"
inner join t_vehicle on t_vehicle.id = t_entry."vehicleId"
inner join t_spot on t_spot.id = t_entry."spotId"
`;
  }
}

export const entryCrud = new EntryCrud()
