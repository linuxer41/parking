import { userCrud } from './crud/user';
import { companyCrud } from './crud/company';
import { employeeCrud } from './crud/employee';
import { parkingCrud } from './crud/parking';
import { levelCrud } from './crud/level';
import { areaCrud } from './crud/area';
import { spotCrud } from './crud/spot';
import { vehicleCrud } from './crud/vehicle';
import { priceCrud } from './crud/price';
import { subscriberCrud } from './crud/subscriber';
import { subscriptionPlanCrud } from './crud/subscription-plan';
import { entryCrud } from './crud/entry';
import { exitCrud } from './crud/exit';
import { cashRegisterCrud } from './crud/cash-register';
import { movementCrud } from './crud/movement';
import { reservationCrud } from './crud/reservation';

  export const db = {
    user: userCrud,
    company: companyCrud,
    employee: employeeCrud,
    parking: parkingCrud,
    level: levelCrud,
    area: areaCrud,
    spot: spotCrud,
    vehicle: vehicleCrud,
    price: priceCrud,
    subscriber: subscriberCrud,
    subscriptionPlan: subscriptionPlanCrud,
    entry: entryCrud,
    exit: exitCrud,
    cashRegister: cashRegisterCrud,
    movement: movementCrud,
    reservation: reservationCrud
  };
  