
import { BaseCrud } from './base-crud';
import { Spot, SpotCreate, SpotUpdate } from '../../models/spot';

class SpotCrud extends BaseCrud<Spot, SpotCreate, SpotUpdate> {
  constructor() {
    super('t_spot');
  }

  baseQuery() {
    return `
select t_spot.* , to_jsonb(t_parking.*) as "parking"
from t_spot
inner join t_parking on t_parking.id = t_spot."parkingId"
`;
  }
}

export const spotCrud = new SpotCrud()
