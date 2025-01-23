import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/services/user_service.dart';
import 'package:parkar/state/app_state_container.dart';

import '../../widgets/auth/auth_layout.dart';

// class InitScreen extends StatefulWidget {
//   const InitScreen({super.key});

//   @override
//   State<InitScreen> createState() => _InitScreenState();
// }

// class _InitScreenState extends State<InitScreen> {
//   late Future<List<CompanyParkingModel>> companiesFuture;

//   // Cargar datos al inicio
//   @override
//   void initState() {
//     super.initState();
//   }
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     companiesFuture = _loadData();
//   }

//   // Simular carga de datos
//   Future<List<CompanyParkingModel>> _loadData() async {
//     final UserService userService =
//         AppStateContainer.di(context).resolve<UserService>();
//     final AppState appState = AppStateContainer.of(context);
//     final companies = await userService.getCompanies(appState.user!.id);
//     return companies;
//     // return [];
//   }

//   // Función para registrar una nueva compañía
//   void _registerNewCompany() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const material.AlertDialog(
//           title: Text('Registrar nueva compañía'),
//           content: CompanyForm(),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return material.Scaffold(
//       body: Center(
//           child: FutureBuilder<List<CompanyParkingModel>>(
//               future: companiesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final companies = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: companies.length,
//                     itemBuilder: (context, index) {
//                       final company = companies[index];
//                       return Expander(
//                         header: Text(company.name),
//                         content: Column(
//                           children: company.parkings.map((parking) {
//                             return ListTile(
//                               title: Text(parking.name),
//                               onPressed: () {
//                                 // Seleccionar el parqueo
//                                 print('Parqueo seleccionado: ${parking.name}');
//                               },
//                             );
//                           }).toList(),
//                         ),
//                       );
//                     },
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text(snapshot.error.toString());
//                 }
//                 return const Center(
//                     child: material.CircularProgressIndicator());
//               }),
//         ),
//     );
//   }
// }

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = AppStateContainer.di(context).resolve<UserService>();
    final parkingService = AppStateContainer.di(context).resolve<ParkingService>();
    final state = AppStateContainer.of(context);
    return AuthLayout(
      title: "Seleccionar compania",
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200), // Altura máxima
          child: FutureBuilder(
            future: userService.getCompanies(state.user!.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final companies = snapshot.data!;
                return ListView.builder(
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    final company = companies[index];
                    return Expander(
                      header: Text(company.name),
                      content: Column(
                        children: company.parkings.map((parking) {
                          return ListTile(
                            title: Text(parking.name),
                            onPressed: () async {
                              // Seleccionar el parqueo
                              final detailedParkig = await parkingService.getDetailed(parking.id);
                              state.setCompany(company);
                              state.setParking(detailedParkig);
                              context.go('/home');
                              print('Parqueo seleccionado: ${parking.name}');
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              return const Center(
                child: material.CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}