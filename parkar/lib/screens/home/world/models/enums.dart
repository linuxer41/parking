/// Enumeraciones para los elementos del mundo de estacionamiento
/// Este archivo contiene todas las enumeraciones utilizadas en el módulo world

/// Tipos de espacios de estacionamiento
enum SpotType { vehicle, motorcycle, truck }

/// Categorías de espacios de estacionamiento
enum SpotCategory { normal, disabled, reserved, vip }

/// Tipos de señalización
enum SignageType { entrance, exit, path, info, noParking, oneWay, twoWay }

/// Tipos de instalaciones
enum FacilityType {
  elevator,
  stairs,
  bathroom,
  office,
  payStation,
  securityOffice
}
