
import 'package:flutter/material.dart';
import '../../models/entry_model.dart';
import '../../services/entry_service.dart';
import '../../di/di_container.dart';

class EntryForm extends StatefulWidget {
  final EntryModel? model;

  const EntryForm({super.key, this.model});

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<EntryService>();

  final _numberController = TextEditingController();
  final _parkingIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _vehicleIdController = TextEditingController();
  final _spotIdController = TextEditingController();
  final _dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _numberController.text = widget.model!.number.toString();
      _employeeIdController.text = widget.model!.employeeId.toString();
      _vehicleIdController.text = widget.model!.vehicleId.toString();
      _spotIdController.text = widget.model!.spotId.toString();
      _dateTimeController.text = widget.model!.dateTime.toString();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _parkingIdController.dispose();
    _employeeIdController.dispose();
    _vehicleIdController.dispose();
    _spotIdController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = EntryCreateModel(
            number: int.parse(_numberController.text),
            parkingId: _parkingIdController.text,
            employeeId: _employeeIdController.text,
            vehicleId: _vehicleIdController.text,
            spotId: _spotIdController.text,
            dateTime: DateTime.parse(_dateTimeController.text),
          );
          await _service.create(newModel);
        } else {
          final updatedModel = EntryUpdateModel(
            number: int.parse(_numberController.text),
            employeeId: _employeeIdController.text,
            vehicleId: _vehicleIdController.text,
            spotId: _spotIdController.text,
            dateTime: DateTime.parse(_dateTimeController.text),
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Entry' : 'Actualizar Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Número de la entrada',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
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
                  labelText: 'ID del vehículo que ingresó',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _spotIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del lugar de estacionamiento asignado',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _dateTimeController,
                decoration: const InputDecoration(
                  labelText: 'Fecha y hora de la entrada',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
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
