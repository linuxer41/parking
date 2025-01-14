
import { BaseCrud } from './base-crud';
import { Level, LevelCreate, LevelUpdate } from '../../models/level';

class LevelCrud extends BaseCrud<Level, LevelCreate, LevelUpdate> {
  constructor() {
    super('t_level');
  }

  baseQuery() {
    return `
select t_level.* , to_jsonb(t_parking.*) as "parking"
from t_level
inner join t_parking on t_parking.id = t_level."parkingId"
`;
  }
}

export const levelCrud = new LevelCrud()
