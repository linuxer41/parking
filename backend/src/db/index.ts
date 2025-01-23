import { userCrud } from './crud/user';
import { companyCrud } from './crud/company';
import { employeeCrud } from './crud/employee';
import { parkingCrud } from './crud/parking';
import { levelCrud } from './crud/level';
import { vehicleCrud } from './crud/vehicle';
import { subscriberCrud } from './crud/subscriber';
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
    vehicle: vehicleCrud,
    subscriber: subscriberCrud,
    entry: entryCrud,
    exit: exitCrud,
    cashRegister: cashRegisterCrud,
    movement: movementCrud,
    reservation: reservationCrud
  };
  