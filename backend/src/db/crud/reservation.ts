
import { BaseCrud } from './base-crud';
import { Reservation, ReservationCreate, ReservationUpdate } from '../../models/reservation';

class ReservationCrud extends BaseCrud<Reservation, ReservationCreate, ReservationUpdate> {
  constructor() {
    super('t_reservation');
  }

  baseQuery() {
    return `
select t_reservation.* , to_jsonb(t_parking.*) as "parking", to_jsonb(t_employee.*) as "employee", to_jsonb(t_vehicle.*) as "vehicle", to_jsonb(t_spot.*) as "spot"
from t_reservation
inner join t_parking on t_parking.id = t_reservation."parkingId"
inner join t_employee on t_employee.id = t_reservation."employeeId"
inner join t_vehicle on t_vehicle.id = t_reservation."vehicleId"
inner join t_spot on t_spot.id = t_reservation."spotId"
`;
  }
}

export const reservationCrud = new ReservationCrud()
