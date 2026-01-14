import { Rate } from "../models/parking";

function getExpTimestamp(seconds: number) {
  const currentTimeMillis = Date.now();
  const secondsIntoMillis = seconds * 1000;
  const expirationTimeMillis = currentTimeMillis + secondsIntoMillis;

  return Math.floor(expirationTimeMillis / 1000);
}

/**
 * Calculate the parking fee based on entry time and current time
 * @param entryTime - ISO string of entry time
 * @param rates - Array of parking rates
 * @param vehicleType - Vehicle type string ('bicycle', 'motorcycle', 'car', 'truck')
 * @returns Calculated fee amount
 */
function calculateParkingFee(
  entryTime: string,
  rates: Rate[],
  vehicleType: string
): number {
  // Map vehicle type string to numeric category
  let vehicleCategory: number;
  switch (vehicleType.toLowerCase()) {
    case 'bicycle':
      vehicleCategory = 1;
      break;
    case 'motorcycle':
      vehicleCategory = 2;
      break;
    case 'car':
      vehicleCategory = 3;
      break;
    case 'truck':
      vehicleCategory = 4;
      break;
    default:
      vehicleCategory = 1; // Default to bicycle
  }

  const entry = new Date(entryTime);
  const now = new Date();

  // Calculate total minutes parked
  const totalMinutes = Math.floor((now.getTime() - entry.getTime()) / (1000 * 60));

  // Find applicable rate for the vehicle category
  const applicableRate = rates.find(
    (rate) => rate.vehicleCategory === vehicleCategory && rate.isActive
  );

  if (!applicableRate) {
    // Fallback to first active rate if no specific rate found
    const fallbackRate = rates.find((rate) => rate.isActive);
    if (!fallbackRate) {
      return 0;
    }
    return calculateFeeFromRate(totalMinutes, fallbackRate);
  }

  return calculateFeeFromRate(totalMinutes, applicableRate);
}

/**
 * Calculate fee from a specific rate
 * @param totalMinutes - Total minutes parked
 * @param rate - Rate object
 * @returns Calculated fee
 */
function calculateFeeFromRate(totalMinutes: number, rate: Rate): number {
  // Apply tolerance (free minutes)
  const billableMinutes = totalMinutes > rate.tolerance ? totalMinutes - rate.tolerance : 0;

  if (billableMinutes == 0) return 0.0;

  // Charge in half-hour increments, minimum 1 half-hour
  const halfHours = Math.ceil(billableMinutes / 30);
  const fee = halfHours * (rate.hourly / 2);

  // Round to 2 decimal places
  return Math.round(fee * 100) / 100;
}

export { getExpTimestamp, calculateParkingFee };
