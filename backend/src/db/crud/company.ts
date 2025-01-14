
import { BaseCrud } from './base-crud';
import { Company, CompanyCreate, CompanyUpdate } from '../../models/company';
import { Parking } from '../../models/parking';

class CompanyCrud extends BaseCrud<Company, CompanyCreate, CompanyUpdate> {
  constructor() {
    super('t_company');
  }

  baseQuery() {
    return `
select t_company.* , to_jsonb(t_user.*) as "user"
from t_company
inner join t_user on t_user.id = t_company."userId"
`;
  }
  async getUserCompaniesDetailed(id: string) {
    const sql = `
        SELECT c.*,
        (
            SELECT json_agg(
                to_jsonb(p.*)
            ) FROM "t_parking" p, jsonb_array_elements(e."assignedParkings") pa
            WHERE p."companyId" = c.id
            AND p.id = pa->>0
        ) AS parkings
        FROM "t_company" c
        INNER JOIN "t_employee" e ON e."companyId" = c.id
        INNER JOIN "t_user" u ON u.id = e."userId"
        WHERE u.id = $1
        `;
    const res = await this.query<Company & { parkings: Parking[] }>({ sql, params: [id] });
    console.log(res);
    return res
  }

}

export const companyCrud = new CompanyCrud()
