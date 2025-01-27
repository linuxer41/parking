
import 'package:flutter/material.dart';
import '../../models/parking_model.dart';
import '../../services/parking_service.dart';
import '../../di/di_container.dart';

class ParkingForm extends StatefulWidget {
  final ParkingModel? model;

  const ParkingForm({super.key, this.model});

  @override
  State<ParkingForm> createState() => _ParkingFormState();
}

class _ParkingFormState extends State<ParkingForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<ParkingService>();

  final _nameController = TextEditingController();
  final _companyIdController = TextEditingController();
  final _vehicleTypesController = TextEditingController();
  final _paramsController = TextEditingController();
  final _pricesController = TextEditingController();
  final _subscriptionPlansController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _nameController.text = widget.model!.name.toString();
      _paramsController.text = widget.model!.params.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyIdController.dispose();
    _paramsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = ParkingCreateModel(
            name: _nameController.text,
            companyId: _companyIdController.text,
          );
          await _service.create(newModel);
        } else {
          final updatedModel = ParkingUpdateModel(
            name: _nameController.text,
            vehicleTypes: [],
            // params: _paramsController.text,
            prices: [],
            subscriptionPlans: [],
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Parking ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model == null ? 'Crear Parking' : 'Actualizar Parking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del estacionamiento',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _companyIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de la empresa a la que pertenece el estacionamiento',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _vehicleTypesController,
                decoration: const InputDecoration(
                  labelText: 'Tipos de vehículos permitidos en el estacionamiento',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _paramsController,
                decoration: const InputDecoration(
                  labelText: 'Parámetros adicionales del estacionamiento',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _pricesController,
                decoration: const InputDecoration(
                  labelText: 'Precios del estacionamiento',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _subscriptionPlansController,
                decoration: const InputDecoration(
                  labelText: 'Planes de suscripción del estacionamiento',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.model == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
