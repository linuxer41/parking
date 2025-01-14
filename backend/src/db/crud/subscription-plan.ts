
import { BaseCrud } from './base-crud';
import { SubscriptionPlan, SubscriptionPlanCreate, SubscriptionPlanUpdate } from '../../models/subscription-plan';

class SubscriptionPlanCrud extends BaseCrud<SubscriptionPlan, SubscriptionPlanCreate, SubscriptionPlanUpdate> {
  constructor() {
    super('t_subscription_plan');
  }

  baseQuery() {
    return `
select t_subscription_plan.* , to_jsonb(t_parking.*) as "parking"
from t_subscription_plan
inner join t_parking on t_parking.id = t_subscription_plan."parkingId"
`;
  }
}

export const subscriptionPlanCrud = new SubscriptionPlanCrud()
