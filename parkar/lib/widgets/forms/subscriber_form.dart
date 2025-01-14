
import 'package:flutter/material.dart';
import '../../models/subscriber_model.dart';
import '../../services/subscriber_service.dart';
import '../../di/di_container.dart';

class SubscriberForm extends StatefulWidget {
  final SubscriberModel? model;

  const SubscriberForm({super.key, this.model});

  @override
  State<SubscriberForm> createState() => _SubscriberFormState();
}

class _SubscriberFormState extends State<SubscriberForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<SubscriberService>();

  final _parkingIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _vehicleIdController = TextEditingController();
  final _planIdController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _isActiveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _planIdController.text = widget.model!.planId.toString();
      _startDateController.text = widget.model!.startDate.toString();
      _endDateController.text = widget.model!.endDate.toString();
      _isActiveController.text = widget.model!.isActive.toString();
    }
  }

  @override
  void dispose() {
    _parkingIdController.dispose();
    _employeeIdController.dispose();
    _vehicleIdController.dispose();
    _planIdController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _isActiveController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = SubscriberCreateModel(
            parkingId: _parkingIdController.text,
            employeeId: _employeeIdController.text,
            vehicleId: _vehicleIdController.text,
            planId: _planIdController.text,
            startDate: DateTime.parse(_startDateController.text),
            endDate: DateTime.parse(_endDateController.text),
            isActive: _isActiveController.text.toLowerCase() == 'true',
          );
          await _service.create(newModel);
        } else {
          final updatedModel = SubscriberUpdateModel(
            planId: _planIdController.text,
            startDate: DateTime.parse(_startDateController.text),
            endDate: DateTime.parse(_endDateController.text),
            isActive: _isActiveController.text.toLowerCase() == 'true',
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscriber ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Subscriber' : 'Actualizar Subscriber'),
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
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del empleado asociado',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _vehicleIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del vehículo asociado',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _planIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del plan de suscripción',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de inicio del abono',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de fin del abono',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _isActiveController,
                decoration: const InputDecoration(
                  labelText: 'Indica si el abono está activo',
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
