import 'package:flutter/material.dart';

class ProfileSettings extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final VoidCallback onEditProfile;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const ProfileSettings({
    Key? key,
    this.userName,
    this.userEmail,
    required this.onEditProfile,
    required this.onToggleTheme,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final appState = 
    return Scaffold(
      body: Column(
        children: [
          // Encabezado con información del usuario
          UserAccountsDrawerHeader(
            accountName: Text(userName ?? "No autenticado"),
            accountEmail: Text(userEmail ?? ""),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Opción para editar perfil
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar cuenta'),
            onTap: onEditProfile,
          ),
          const Divider(),
          // Opción para cambiar tema
          // ListTile(
          //   leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          //   title: Text(isDarkMode ? 'Modo Claro' : 'Modo Oscuro'),
          //   onTap: onToggleTheme,
          // ),
          const Divider(),
          // Opción para cerrar sesión
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}