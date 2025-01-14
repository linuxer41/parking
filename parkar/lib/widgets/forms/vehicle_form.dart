
import 'package:flutter/material.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../di/di_container.dart';

class VehicleForm extends StatefulWidget {
  final VehicleModel? model;

  const VehicleForm({super.key, this.model});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<VehicleService>();

  final _parkingIdController = TextEditingController();
  final _typeIdController = TextEditingController();
  final _plateController = TextEditingController();
  final _isSubscriberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _typeIdController.text = widget.model!.typeId.toString();
      _plateController.text = widget.model!.plate.toString();
      _isSubscriberController.text = widget.model!.isSubscriber.toString();
    }
  }

  @override
  void dispose() {
    _parkingIdController.dispose();
    _typeIdController.dispose();
    _plateController.dispose();
    _isSubscriberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = VehicleCreateModel(
            parkingId: _parkingIdController.text,
            typeId: _typeIdController.text,
            plate: _plateController.text,
            isSubscriber: _isSubscriberController.text.toLowerCase() == 'true',
          );
          await _service.create(newModel);
        } else {
          final updatedModel = VehicleUpdateModel(
            typeId: _typeIdController.text,
            plate: _plateController.text,
            isSubscriber: _isSubscriberController.text.toLowerCase() == 'true',
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Vehicle' : 'Actualizar Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              TextFormField(
                controller: _parkingIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del estacionamiento asociado',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _typeIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del tipo de vehículo',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa del vehículo',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _isSubscriberController,
                decoration: const InputDecoration(
                  labelText: 'Indica si el vehículo es abonado',
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
