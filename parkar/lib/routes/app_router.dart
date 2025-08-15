import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/screens/auth/select_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/register_stepper_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../state/app_state_container.dart';

/// Middleware para verificar la autenticación
String? _checkAuth(BuildContext context, {bool requireParking = false}) {
  final appState = AppStateContainer.of(context);
  print(
    'Middleware: Verificando autenticación authtoke: ${appState.authToken} accesstoken: ${appState.refreshToken}',
  );

  // Verifica si el authToken está presente
  if (appState.authToken == null) {
    return '/login'; // Redirige a login si no hay authToken
  }

  // Verifica si el authToken es requerido y está presente
  if (requireParking && appState.currentParking == null) {
    return '/select'; // Redirige a /select si no hay estacionamiento seleccionado
  }

  return null; // Permite el acceso si todo está en orden
}

/// Rutas públicas (no requieren autenticación)
final _publicRoutes = [
  GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(
    path: '/register',
    builder: (context, state) => const RegisterStepperScreen(),
  ),
  GoRoute(
    path: '/register-old',
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: '/forgot-password',
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
];

/// Rutas protegidas (requieren autenticación)
final _protectedRoutes = [
  GoRoute(
    path: '/select',
    builder: (context, state) => const SelectScreen(),
    redirect: (context, state) => _checkAuth(context),
  ),
  GoRoute(
    path: '/home',
    builder: (context, state) => const HomeScreen(),
    redirect: (context, state) => _checkAuth(context, requireParking: true),
  ),
];

/// Enrutador principal
final router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // Ruta de redirección inicial
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final appState = AppStateContainer.of(context);
        print('Router: authToken = ${appState.authToken}, currentParking = ${appState.currentParking}');
        
        // Si no hay token, siempre ir a welcome
        if (appState.authToken == null || appState.authToken!.isEmpty) {
          return '/welcome';
        }
        
        // Si hay token pero no estacionamiento seleccionado, ir a select
        if (appState.currentParking == null) {
          return '/select';
        }
        
        // Si hay token y estacionamiento, ir a home
        return '/home';
      },
    ),

    // Rutas públicas
    ..._publicRoutes,

    // Rutas protegidas
    ..._protectedRoutes,
  ],
);
