
import 'package:flutter/material.dart';
import '../../models/exit_model.dart';
import '../../services/exit_service.dart';
import '../../di/di_container.dart';

class ExitForm extends StatefulWidget {
  final ExitModel? model;

  const ExitForm({super.key, this.model});

  @override
  State<ExitForm> createState() => _ExitFormState();
}

class _ExitFormState extends State<ExitForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<ExitService>();

  final _numberController = TextEditingController();
  final _parkingIdController = TextEditingController();
  final _entryIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _numberController.text = widget.model!.number.toString();
      _employeeIdController.text = widget.model!.employeeId.toString();
      _dateTimeController.text = widget.model!.dateTime.toString();
      _amountController.text = widget.model!.amount.toString();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _parkingIdController.dispose();
    _entryIdController.dispose();
    _employeeIdController.dispose();
    _dateTimeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = ExitCreateModel(
            number: int.parse(_numberController.text),
            parkingId: _parkingIdController.text,
            entryId: _entryIdController.text,
            employeeId: _employeeIdController.text,
            dateTime: DateTime.parse(_dateTimeController.text),
            amount: double.parse(_amountController.text),
          );
          await _service.create(newModel);
        } else {
          final updatedModel = ExitUpdateModel(
            number: int.parse(_numberController.text),
            employeeId: _employeeIdController.text,
            dateTime: DateTime.parse(_dateTimeController.text),
            amount: double.parse(_amountController.text),
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exit ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Exit' : 'Actualizar Exit'),
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
                  labelText: 'Número de la salida',
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
                controller: _entryIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de la entrada asociada',
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
                controller: _dateTimeController,
                decoration: const InputDecoration(
                  labelText: 'Fecha y hora de la salida',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto cobrado',
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
