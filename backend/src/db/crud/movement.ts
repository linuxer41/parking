import { BaseCrud } from "./base-crud";
import {
  Movement,
  MovementCreate,
  MovementUpdate,
} from "../../models/movement";

class MovementCrud extends BaseCrud<Movement, MovementCreate, MovementUpdate> {
  constructor() {
    super("t_movement", "m");
  }

  baseQuery() {
    return `
select m.* , to_jsonb(cr.*) as "cashRegister"
from t_movement m
inner join t_cash_register cr on cr.id = m."cashRegisterId"
`;
  }
}

export const movementCrud = new MovementCrud();
