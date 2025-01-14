
import { BaseCrud } from './base-crud';
import { Area, AreaCreate, AreaUpdate } from '../../models/area';

class AreaCrud extends BaseCrud<Area, AreaCreate, AreaUpdate> {
  constructor() {
    super('t_area');
  }

  baseQuery() {
    return `
select t_area.* , to_jsonb(t_parking.*) as "parking", to_jsonb(t_level.*) as "level"
from t_area
inner join t_parking on t_parking.id = t_area."parkingId"
inner join t_level on t_level.id = t_area."levelId"
`;
  }
}

export const areaCrud = new AreaCrud()
