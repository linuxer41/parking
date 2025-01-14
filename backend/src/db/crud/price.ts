
import { BaseCrud } from './base-crud';
import { Price, PriceCreate, PriceUpdate } from '../../models/price';

class PriceCrud extends BaseCrud<Price, PriceCreate, PriceUpdate> {
  constructor() {
    super('t_price');
  }

  baseQuery() {
    return `
select t_price.* , to_jsonb(t_parking.*) as "parking"
from t_price
inner join t_parking on t_parking.id = t_price."parkingId"
`;
  }
}

export const priceCrud = new PriceCrud()
