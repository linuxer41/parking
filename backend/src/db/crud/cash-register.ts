
import { BaseCrud } from './base-crud';
import { CashRegister, CashRegisterCreate, CashRegisterUpdate } from '../../models/cash-register';

class CashRegisterCrud extends BaseCrud<CashRegister, CashRegisterCreate, CashRegisterUpdate> {
  constructor() {
    super('t_cash_register');
  }

  baseQuery() {
    return `
select t_cash_register.* , to_jsonb(t_parking.*) as "parking", to_jsonb(t_employee.*) as "employee"
from t_cash_register
inner join t_parking on t_parking.id = t_cash_register."parkingId"
inner join t_employee on t_employee.id = t_cash_register."employeeId"
`;
  }
}

export const cashRegisterCrud = new CashRegisterCrud()
