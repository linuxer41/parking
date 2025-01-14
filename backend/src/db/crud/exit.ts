
import { BaseCrud } from './base-crud';
import { Exit, ExitCreate, ExitUpdate } from '../../models/exit';

class ExitCrud extends BaseCrud<Exit, ExitCreate, ExitUpdate> {
  constructor() {
    super('t_exit');
  }

  baseQuery() {
    return `
select t_exit.* , to_jsonb(t_parking.*) as "parking", to_jsonb(t_entry.*) as "entry", to_jsonb(t_employee.*) as "employee"
from t_exit
inner join t_parking on t_parking.id = t_exit."parkingId"
inner join t_entry on t_entry.id = t_exit."entryId"
inner join t_employee on t_employee.id = t_exit."employeeId"
`;
  }
}

export const exitCrud = new ExitCrud()
