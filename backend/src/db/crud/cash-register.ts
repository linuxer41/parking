import { BaseCrud } from "./base-crud";
import {
  CashRegister,
  CashRegisterCreate,
  CashRegisterUpdate,
} from "../../models/cash-register";

class CashRegisterCrud extends BaseCrud<
  CashRegister,
  CashRegisterCreate,
  CashRegisterUpdate
> {
  constructor() {
    super("t_cash_register", "cr");
  }

  baseQuery() {
    return `
select cr.* , to_jsonb(p.*) as "parking", to_jsonb(e.*) as "employee"
from t_cash_register cr
inner join t_parking p on p.id = cr."parkingId"
inner join t_employee e on e.id = cr."employeeId"
`;
  }
}

export const cashRegisterCrud = new CashRegisterCrud();
