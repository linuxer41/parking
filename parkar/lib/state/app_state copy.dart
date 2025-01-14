// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:parkar/state/theme.dart';
// import '../models/company_model.dart';
// import '../models/employee_model.dart';
// import '../models/user_model.dart';
// import '../models/parking_model.dart';

// class AppState extends ChangeNotifier {
//   UserModel? _user;
//   CompanyModel? _company;
//   EmployeeModel? _employee;
//   ParkingModel? _parking;
//   String? _authToken;
//   String? _refreshToken;
//   AppTheme _theme = AppTheme();

//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   UserModel? get user => _user;
//   CompanyModel? get company => _company;
//   EmployeeModel? get employee => _employee;
//   ParkingModel? get parking => _parking;
//   String? get authToken => _authToken;
//   String? get refreshToken => _refreshToken;
//   AppTheme? get theme => _theme;

//   String get userName => '${_employee?.id ?? ''}:${parking?.id ?? ''}';

//   // Cargar el estado desde el almacenamiento seguro
//   Future<void> loadState() async {
//     // Cargar tokens
//     _authToken = await _secureStorage.read(key: 'authToken');
//     _refreshToken = await _secureStorage.read(key: 'refreshToken');

//     // Cargar datos del usuario (serializados)
//     final userJson = await _secureStorage.read(key: 'user');
//     if (userJson != null) {
//       _user = UserModel.fromJson(jsonDecode(userJson));
//     }

//     // Cargar datos de la empresa
//     final companyJson = await _secureStorage.read(key: 'company');
//     if (companyJson != null) {
//       _company = CompanyModel.fromJson(jsonDecode(companyJson));
//     }

//     // Cargar datos del empleado
//     final employeeJson = await _secureStorage.read(key: 'employee');
//     if (employeeJson != null) {
//       _employee = EmployeeModel.fromJson(jsonDecode(employeeJson));
//     }

//     // Cargar datos del parking
//     final parkingJson = await _secureStorage.read(key: 'parking');
//     if (parkingJson != null) {
//       _parking = ParkingModel.fromJson(jsonDecode(parkingJson));
//     }

//     // Cargar tema (si es necesario)
//     // final themeMode = await _secureStorage.read(key: 'themeMode');
//     // if (themeMode != null) {
//     //   _theme = AppTheme.fromString(themeMode);
//     // }

//     notifyListeners();
//   }

//   // Guardar el estado en el almacenamiento seguro
//   Future<void> saveState() async {
//     // Guardar tokens
//     await _secureStorage.write(key: 'authToken', value: _authToken ?? '');
//     await _secureStorage.write(key: 'refreshToken', value: _refreshToken ?? '');

//     // Guardar datos del usuario (serializados)
//     if (_user != null) {
//       await _secureStorage.write(key: 'user', value: jsonEncode(_user!.toJson()));
//     }

//     // Guardar datos de la empresa
//     if (_company != null) {
//       await _secureStorage.write(key: 'company', value: jsonEncode(_company!.toJson()));
//     }

//     // Guardar datos del empleado
//     if (_employee != null) {
//       await _secureStorage.write(key: 'employee', value: jsonEncode(_employee!.toJson()));
//     }

//     // Guardar datos del parking
//     if (_parking != null) {
//       await _secureStorage.write(key: 'parking', value: jsonEncode(_parking!.toJson()));
//     }

//     // Guardar tema (si es necesario)
//     // await _secureStorage.write(key: 'themeMode', value: _theme.toString());
//   }

//   void setUser(UserModel? user) {
//     _user = user;
//     saveState(); // Guardar el estado después de cambiar el usuario
//     notifyListeners();
//   }

//   void setCompany(CompanyModel? company) {
//     _company = company;
//     saveState(); // Guardar el estado después de cambiar la empresa
//     notifyListeners();
//   }

//   void setEmployee(EmployeeModel? employee) {
//     _employee = employee;
//     saveState(); // Guardar el estado después de cambiar el empleado
//     notifyListeners();
//   }

//   void setParking(ParkingModel? parking) {
//     _parking = parking;
//     saveState(); // Guardar el estado después de cambiar el parking
//     notifyListeners();
//   }

//   void setAccessToken(String? authToken) {
//     _authToken = authToken;
//     saveState(); // Guardar el estado después de cambiar el token
//     notifyListeners();
//   }

//   void setRefreshToken(String? refreshToken) {
//     _refreshToken = refreshToken;
//     saveState(); // Guardar el estado después de cambiar el token
//     notifyListeners();
//   }

//   void setTheme(AppTheme theme) {
//     _theme = theme;
//     saveState(); // Guardar el estado después de cambiar el tema
//     notifyListeners();
//   }

//   void logout() async {
//     _user = null;
//     _company = null;
//     _employee = null;
//     _parking = null;
//     _authToken = null;
//     _refreshToken = null;
//     _theme = AppTheme();

//     // Eliminar todos los datos del almacenamiento seguro
//     await _secureStorage.deleteAll();

//     notifyListeners();
//   }
// }