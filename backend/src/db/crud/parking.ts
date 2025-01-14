
import { BaseCrud } from './base-crud';
import { Parking, ParkingCreate, ParkingUpdate } from '../../models/parking';
import { ParkingComplete } from '../../models/composite-models';

class ParkingCrud extends BaseCrud<Parking, ParkingCreate, ParkingUpdate> {
  constructor() {
    super('t_parking');
  }

  baseQuery() {
    return `
select t_parking.* , to_jsonb(t_company.*) as "company"
from t_parking
inner join t_company on t_company.id = t_parking."companyId"
`;
  }

  async getDetailed(id: string) {
    const sql =  `select t_parking.* , to_jsonb(t_company.*) as "company",
  (
      SELECT
          json_agg(
              to_jsonb(t_level.*) || jsonb_build_object(
                  'areas', (
                      SELECT
                          json_agg(
                              to_jsonb(t_area.*) || jsonb_build_object(
                                  'spots', (
                                      SELECT
                                          json_agg(to_jsonb(t_spot.*))
                                      FROM t_spot
                                      WHERE t_spot."areaId" = t_area.id
                                  )
                              )
                          )
                      FROM t_area
                      WHERE t_area."levelId" = t_level.id
                  )
              )
          )
      FROM t_level
      WHERE t_level."parkingId" = t_parking.id
  ) AS levels
from t_parking
inner join t_company on t_company.id = t_parking."companyId"
and t_parking.id = $1`;
    const res = await this.query<ParkingComplete>({ sql, params: [id] });
    return res[0];
  }
}

export const parkingCrud = new ParkingCrud()
