import 'package:parkar/models/parking_model.dart';

/// Calculate the parking fee based on entry time and current time
/// @param entryTime - ISO string of entry time
/// @param rates - List of parking rates
/// @param vehicleType - Vehicle type string ('bicycle', 'motorcycle', 'car', 'truck')
/// @returns Calculated fee amount
double calculateParkingFee(
  String entryTime,
  List<RateModel> rates,
  String vehicleType,
) {
  // Map vehicle type string to numeric category
  print('vehicleType: $vehicleType');
  int vehicleCategory;
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
  final entry = DateTime.parse(entryTime);
  final now = DateTime.now();

  // Calculate total minutes parked
  final totalMinutes = now.difference(entry).inMinutes;

  // Find applicable rate for the vehicle category
  final applicableRate = rates.firstWhere(
    (rate) => rate.vehicleCategory == vehicleCategory && rate.isActive,
    orElse: () {
      // Fallback to first active rate if no specific rate found
      return rates.firstWhere(
        (rate) => rate.isActive,
        orElse: () => throw Exception('No active rates found'),
      );
    },
  );

  print('applicableRate: ${applicableRate.toJson()}');

  return _calculateFeeFromRate(totalMinutes, applicableRate);
}

/// Calculate fee from a specific rate
/// @param totalMinutes - Total minutes parked
/// @param rate - Rate object
/// @returns Calculated fee
double _calculateFeeFromRate(int totalMinutes, RateModel rate) {
  // Apply tolerance (free minutes)
  final billableMinutes = totalMinutes > rate.tolerance ? totalMinutes - rate.tolerance : 0;

  if (billableMinutes == 0) return 0.0;

  // Charge in half-hour increments, minimum 1 half-hour
  final halfHours = (billableMinutes / 30).ceil();
  final fee = halfHours * (rate.hourly / 2);

  // Round to 2 decimal places
  return (fee * 100).round() / 100;
}

/// Check if the parking time is still within tolerance (free time)
/// @param entryTime - ISO string of entry time
/// @param toleranceMinutes - Tolerance minutes
/// @returns True if still in tolerance
bool isInTolerance(String entryTime, int toleranceMinutes) {
  final entry = DateTime.parse(entryTime);
  final now = DateTime.now();
  final totalMinutes = now.difference(entry).inMinutes;
  return totalMinutes <= toleranceMinutes;
}

/// Get remaining tolerance minutes
/// @param entryTime - ISO string of entry time
/// @param toleranceMinutes - Tolerance minutes
/// @returns Remaining minutes in tolerance, 0 if exceeded
int getRemainingToleranceMinutes(String entryTime, int toleranceMinutes) {
  final entry = DateTime.parse(entryTime);
  final now = DateTime.now();
  final totalMinutes = now.difference(entry).inMinutes;
  return totalMinutes < toleranceMinutes ? toleranceMinutes - totalMinutes : 0;
}