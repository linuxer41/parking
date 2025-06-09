/// Enumeración para los tipos de espacios de estacionamiento
enum SpotType { vehicle, motorcycle, truck }

/// Enumeración para las categorías de espacios
enum SpotCategory { normal, disabled, reserved, vip }

/// Enumeración para los tipos de señalización
enum SignageType { entrance, exit, path, info, noParking, oneWay, twoWay }

/// Enumeración para los tipos de instalaciones
enum FacilityType { elevator, stairs, bathroom, paymentStation, chargingStation, securityPost }

/// Modos de edición para el sistema de parkeo
enum EditorMode { 
  free, 
  select, 
} 