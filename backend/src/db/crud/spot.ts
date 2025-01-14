
import { BaseCrud } from './base-crud';
import { Spot, SpotCreate, SpotUpdate } from '../../models/spot';

class SpotCrud extends BaseCrud<Spot, SpotCreate, SpotUpdate> {
  constructor() {
    super('t_spot');
  }

  baseQuery() {
    return `
select t_spot.* , to_jsonb(t_parking.*) as "parking", to_jsonb(t_area.*) as "area"
from t_spot
inner join t_parking on t_parking.id = t_spot."parkingId"
inner join t_area on t_area.id = t_spot."areaId"
`;
  }
}

export const spotCrud = new SpotCrud()
