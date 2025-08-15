import { BaseCrud } from "./base-crud";
import { Element, ElementCreate, ElementUpdate } from "../../models/element";

class ElementCrud extends BaseCrud<Element, ElementCreate, ElementUpdate> {
  constructor() {
    super("t_element", "e");
  }

  baseQuery() {
    return `
select 
  e.*,
  jsonb_build_object(
    'id', a.id,
    'name', a.name
  ) as "area",
  to_jsonb(occ) as "occupancy"
from t_element e
inner join t_area a on a.id = e."areaId"
inner join v_element_occupancy occ on occ."elementId" = e.id
`;
  }
}

export const elementCrud = new ElementCrud(); 