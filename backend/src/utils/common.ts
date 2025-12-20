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
 * @param vehicleCategory - Vehicle category (default 3 for car)
 * @returns Calculated fee amount
 */
function calculateParkingFee(
  entryTime: string,
  rates: Rate[],
  vehicleCategory: number = 3
): number {
  const entry = new Date(entryTime);
  const now = new Date();

  // Calculate total minutes parked
  const totalMinutes = Math.floor((now.getTime() - entry.getTime()) / (1000 * 60));

  // Find applicable rate for the vehicle category
  const applicableRate = rates.find(rate =>
    rate.vehicleCategory === vehicleCategory && rate.isActive
  );

  if (!applicableRate) {
    // Fallback to first active rate if no specific rate found
    const fallbackRate = rates.find(rate => rate.isActive);
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
  const totalHours = totalMinutes / 60;

  // Apply tolerance (free minutes)
  const billableMinutes = Math.max(0, totalMinutes - rate.tolerance);
  const billableHours = billableMinutes / 60;

  // For simplicity, use hourly rate for all calculations
  // In a real system, you might want more complex logic for daily/weekly rates
  const fee = billableHours * rate.hourly;

  // Round to 2 decimal places
  return Math.round(fee * 100) / 100;
}

export { getExpTimestamp, calculateParkingFee };
