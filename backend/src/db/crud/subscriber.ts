
import { BaseCrud } from './base-crud';
import { Subscriber, SubscriberCreate, SubscriberUpdate } from '../../models/subscriber';

class SubscriberCrud extends BaseCrud<Subscriber, SubscriberCreate, SubscriberUpdate> {
  constructor() {
    super('t_subscriber');
  }

  baseQuery() {
    return `
select t_subscriber.* , to_jsonb(t_parking.*) as "parking", to_jsonb(t_employee.*) as "employee", to_jsonb(t_vehicle.*) as "vehicle", to_jsonb(t_plan.*) as "plan"
from t_subscriber
inner join t_parking on t_parking.id = t_subscriber."parkingId"
inner join t_employee on t_employee.id = t_subscriber."employeeId"
inner join t_vehicle on t_vehicle.id = t_subscriber."vehicleId"
inner join t_plan on t_plan.id = t_subscriber."planId"
`;
  }
}

export const subscriberCrud = new SubscriberCrud()
