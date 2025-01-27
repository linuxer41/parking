import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/services/user_service.dart';
import 'package:parkar/state/app_state_container.dart';
import '../../widgets/auth/auth_layout.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = AppStateContainer.di(context).resolve<UserService>();
    final parkingService = AppStateContainer.di(context).resolve<ParkingService>();
    final state = AppStateContainer.of(context);

    return AuthLayout(
      title: "Seleccionar compañía",
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200), // Altura máxima
          child: FutureBuilder(
            future: userService.getCompanies(state.user!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay compañías disponibles.'));
              }

              final companies = snapshot.data!;
              return ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  final company = companies[index];
                  return ExpansionTile(
                    title: Text(
                      company.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: company.parkings.map((parking) {
                      return ListTile(
                        title: Text(parking.name),
                        onTap: () async {
                          // Seleccionar el parqueo
                          final detailedParking = await parkingService.getDetailed(parking.id);
                          state.setCompany(company);
                          state.setParking(detailedParking);
                          state.setLevel(detailedParking.levels.first);
                          context.go('/home');
                          print('Parqueo seleccionado: ${parking.name}');
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}