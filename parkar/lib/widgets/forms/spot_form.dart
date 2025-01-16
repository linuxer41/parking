
// import 'package:flutter/material.dart';
// import '../../models/spot_model.dart';
// import '../../services/spot_service.dart';
// import '../../di/di_container.dart';

// class SpotForm extends StatefulWidget {
//   final SpotModel? model;

//   const SpotForm({super.key, this.model});

//   @override
//   State<SpotForm> createState() => _SpotFormState();
// }

// class _SpotFormState extends State<SpotForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _service = DIContainer().resolve<SpotService>();

//   final _nameController = TextEditingController();
//   final _coordinatesController = TextEditingController();
//   final _statusController = TextEditingController();
//   final _parkingIdController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.model != null) {
//       _nameController.text = widget.model!.name.toString();
//       _coordinatesController.text = widget.model!.coordinates.toString();
//       _statusController.text = widget.model!.status.toString();
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _coordinatesController.dispose();
//     _statusController.dispose();
//     _parkingIdController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         if (widget.model == null) {
//           final newModel = SpotCreateModel(
//             name: _nameController.text,
//             coordinates: _coordinatesController.text,
//             status: _statusController.text,
//             parkingId: _parkingIdController.text,
//           );
//           await _service.create(newModel);
//         } else {
//           final updatedModel = SpotUpdateModel(
//             name: _nameController.text,
//             coordinates: _coordinatesController.text,
//             status: _statusController.text,
//           );
//           await _service.update(widget.model!.id, updatedModel);
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Spot ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
//         );
//         Navigator.of(context).pop();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.model == null ? 'Crear Spot' : 'Actualizar Spot'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
              
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Nombre del lugar',
//                 ),
//                 validator: (value) {
//                   if (true && (value == null || value.isEmpty)) {
//                     return 'Este campo es obligatorio';
//                   }
                  
                  
                  
//                   return null;
//                 },
//               ),
              
              
//               TextFormField(
//                 controller: _coordinatesController,
//                 decoration: const InputDecoration(
//                   labelText: 'Coordenadas del lugar',
//                 ),
//                 validator: (value) {
//                   if (true && (value == null || value.isEmpty)) {
//                     return 'Este campo es obligatorio';
//                   }
                  
                  
                  
//                   return null;
//                 },
//               ),
              
              
//               TextFormField(
//                 controller: _statusController,
//                 decoration: const InputDecoration(
//                   labelText: 'Estado del lugar (libre, ocupado, etc.)',
//                 ),
//                 validator: (value) {
//                   if (true && (value == null || value.isEmpty)) {
//                     return 'Este campo es obligatorio';
//                   }
                  
                  
                  
//                   return null;
//                 },
//               ),
              
              
//               TextFormField(
//                 controller: _parkingIdController,
//                 decoration: const InputDecoration(
//                   labelText: 'ID del estacionamiento asociado',
//                 ),
//                 validator: (value) {
//                   if (true && (value == null || value.isEmpty)) {
//                     return 'Este campo es obligatorio';
//                   }
                  
                  
                  
//                   return null;
//                 },
//               ),
              
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text(widget.model == null ? 'Crear' : 'Actualizar'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
