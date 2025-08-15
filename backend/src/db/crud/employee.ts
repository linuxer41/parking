import { BaseCrud } from "./base-crud";
import {
  Employee,
  EmployeeCreate,
  EmployeeUpdate,
} from "../../models/employee";

class EmployeeCrud extends BaseCrud<Employee, EmployeeCreate, EmployeeUpdate> {
  constructor() {
    super("t_employee", "e");
  }

  baseQuery() {
    return `
select e.* , to_jsonb(u.*) as "user", to_jsonb(p.*) as "parking"
from t_employee e
inner join t_user u on u.id = e."userId"
inner join t_parking p on p.id = e."parkingId"
`;
  }
}

export const employeeCrud = new EmployeeCrud();
