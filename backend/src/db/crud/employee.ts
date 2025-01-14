
import { BaseCrud } from './base-crud';
import { Employee, EmployeeCreate, EmployeeUpdate } from '../../models/employee';

class EmployeeCrud extends BaseCrud<Employee, EmployeeCreate, EmployeeUpdate> {
  constructor() {
    super('t_employee');
  }

  baseQuery() {
    return `
select t_employee.* , to_jsonb(t_user.*) as "user", to_jsonb(t_company.*) as "company"
from t_employee
inner join t_user on t_user.id = t_employee."userId"
inner join t_company on t_company.id = t_employee."companyId"
`;
  }
}

export const employeeCrud = new EmployeeCrud()
