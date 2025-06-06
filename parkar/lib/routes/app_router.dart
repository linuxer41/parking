import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/screens/auth/init_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../state/app_state_container.dart';

/// Middleware para verificar la autenticación
String? _checkAuth(BuildContext context, {bool requireBranchId = false}) {
  final appState = AppStateContainer.of(context);
  print(
      'Middleware: Verificando autenticación authtoke: ${appState.authToken} accesstoken: ${appState.branchId}');

  // Verifica si el authToken está presente
  if (appState.authToken == null) {
    return '/login'; // Redirige a login si no hay authToken
  }

  // Verifica si el authToken es requerido y está presente
  if (requireBranchId && appState.branchId == null) {
    return '/init'; // Redirige a /init si no hay authToken
  }

  return null; // Permite el acceso si todo está en orden
}

/// Rutas públicas (no requieren autenticación)
final _publicRoutes = [
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/register',
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
    path: '/init',
    builder: (context, state) => const InitScreen(),
    redirect: (context, state) => _checkAuth(context),
  ),
  GoRoute(
    path: '/home',
    builder: (context, state) => const HomeScreen(),
    redirect: (context, state) => _checkAuth(context, requireBranchId: true),
  ),
];

/// Enrutador principal
final router = GoRouter(
  routes: [
    // Ruta de redirección inicial
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final appState = AppStateContainer.of(context);
        if (appState.authToken != null && appState.branchId != null) {
          return '/home'; // Redirige a /home si ya está autenticado
        } else if (appState.branchId != null) {
          return '/init'; // Redirige a /init si solo tiene authToken
        }
        return '/login'; // Redirige a /login si no está autenticado
      },
    ),

    // Rutas públicas
    ..._publicRoutes,

    // Rutas protegidas
    ..._protectedRoutes,
  ],
);
