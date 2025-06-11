import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/theme.dart';
import '../models/composite_models.dart';
import '../models/level_model.dart';
import '../models/company_model.dart';
import '../models/employee_model.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  UserModel? _user;
  CompanyModel? _company;
  EmployeeModel? _employee;
  ParkingCompositeModel? _currentParking;
  LevelModel? _currentLevel;
  String? _authToken;
  String? _refreshToken;
  AppTheme _theme = AppTheme();

  UserModel? get user => _user;
  CompanyModel? get company => _company;
  EmployeeModel? get employee => _employee;
  ParkingCompositeModel? get currentParking => _currentParking;
  LevelModel? get currentLevel => _currentLevel;
  String? get authToken => _authToken;
  String? get refreshToken => _refreshToken;
  AppTheme? get theme => _theme;

  String? get branchId => currentParking?.id;

  // Cargar el estado desde SharedPreferences
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar tokens
    _authToken = prefs.getString('authToken');
    _refreshToken = prefs.getString('refreshToken');

    // Cargar datos del usuario (puedes serializar/deserializar modelos)
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        // pass
      }
    }

    // Cargar datos de la empresa
    final companyJson = prefs.getString('company');
    if (companyJson != null) {
      try {
        _company = CompanyModel.fromJson(jsonDecode(companyJson));
      } catch (e) {
        // pass
      }
    }

    // Cargar datos del empleado
    final employeeJson = prefs.getString('employee');
    if (employeeJson != null) {
      try {
        _employee = EmployeeModel.fromJson(jsonDecode(employeeJson));
      } catch (e) {
        // pass
      }
    }

    // Cargar datos del parking
    final parkingJson = prefs.getString('parking');
    if (parkingJson != null) {
      try {
        _currentParking =
            ParkingCompositeModel.fromJson(jsonDecode(parkingJson));
      } catch (e) {
        // pass
      }
    }

    // Cargar datos del nivel
    final levelJson = prefs.getString('level');
    if (levelJson != null) {
      try {
        _currentLevel = LevelModel.fromJson(jsonDecode(levelJson));
      } catch (e) {
        // pass
      }
    }

    // Cargar tema (si es necesario)
    // final themeMode = prefs.getString('themeMode');
    // if (themeMode != null) {
    //   _theme = AppTheme.fromString(themeMode);
    // }

    notifyListeners();
  }

  // Guardar el estado en SharedPreferences
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar tokens
    await prefs.setString('authToken', _authToken ?? '');
    await prefs.setString('refreshToken', _refreshToken ?? '');

    // Guardar datos del usuario (serializar modelos)
    if (_user != null) {
      try {
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      } catch (e) {
        // pass
      }
    }

    // Guardar datos de la empresa
    if (_company != null) {
      try {
        await prefs.setString('company', jsonEncode(_company!.toJson()));
      } catch (e) {
        // pass
      }
    }

    // Guardar datos del empleado
    if (_employee != null) {
      try {
        await prefs.setString('employee', jsonEncode(_employee!.toJson()));
      } catch (e) {
        // pass
      }
    }

    // Guardar datos del parking
    if (_currentParking != null) {
      try {
        await prefs.setString('parking', jsonEncode(_currentParking!.toJson()));
      } catch (e) {
        // pass
      }
    }

    // Guardar datos del nivel
    if (_currentLevel != null) {
      try {
        await prefs.setString('level', jsonEncode(_currentLevel!.toJson()));
      } catch (e) {
        // pass
      }
    }

    // Guardar tema (si es necesario)
    await prefs.setString('themeMode', _theme.toString());
  }

  void setUser(UserModel? user) {
    _user = user;
    saveState(); // Guardar el estado después de cambiar el usuario
    notifyListeners();
  }

  void setCompany(CompanyModel? company) {
    _company = company;
    saveState(); // Guardar el estado después de cambiar la empresa
    notifyListeners();
  }

  void setEmployee(EmployeeModel? employee) {
    _employee = employee;
    saveState(); // Guardar el estado después de cambiar el empleado
    notifyListeners();
  }

  void setParking(ParkingCompositeModel? parking) {
    _currentParking = parking;
    saveState(); // Guardar el estado después de cambiar el parking
    notifyListeners();
  }

  void setLevel(LevelModel? level) {
    _currentLevel = level;
    saveState(); // Guardar el estado después de cambiar el parking
    notifyListeners();
  }

  void setAccessToken(String? authToken) {
    _authToken = authToken;
    saveState(); // Guardar el estado después de cambiar el token
    notifyListeners();
  }

  void setRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
    saveState(); // Guardar el estado después de cambiar el token
    notifyListeners();
  }

  void setTheme(AppTheme theme) {
    // Actualizar el tema directamente sin preocuparse por mantener la misma instancia
    // ya que simplificamos el objeto AppTheme
    _theme.mode = theme.mode;
    _theme.color = theme.color;
    if (theme.locale != _theme.locale) {
      _theme.locale = theme.locale;
    }

    // Guardar las preferencias y notificar inmediatamente
    _theme.savePreferencesNow();
    notifyListeners();
  }

  void logout() {
    _user = null;
    _company = null;
    _employee = null;
    _currentParking = null;
    _currentLevel = null;
    _authToken = null;
    _refreshToken = null;
    _theme = AppTheme();
    saveState(); // Guardar el estado después de cerrar sesión
    notifyListeners();
  }
}
