
import { BaseCrud } from './base-crud';
import { Movement, MovementCreate, MovementUpdate } from '../../models/movement';

class MovementCrud extends BaseCrud<Movement, MovementCreate, MovementUpdate> {
  constructor() {
    super('t_movement');
  }

  baseQuery() {
    return `
select t_movement.* , to_jsonb(t_cash_register.*) as "cashRegister"
from t_movement
inner join t_cash_register on t_cash_register.id = t_movement."cashRegisterId"
`;
  }
}

export const movementCrud = new MovementCrud()
