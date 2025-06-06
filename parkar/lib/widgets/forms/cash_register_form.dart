
import 'package:flutter/material.dart';
import '../../models/cash_register_model.dart';
import '../../services/cash_register_service.dart';
import '../../di/di_container.dart';

class CashRegisterForm extends StatefulWidget {
  final CashRegisterModel? model;

  const CashRegisterForm({super.key, this.model});

  @override
  State<CashRegisterForm> createState() => _CashRegisterFormState();
}

class _CashRegisterFormState extends State<CashRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<CashRegisterService>();

  final _numberController = TextEditingController();
  final _parkingIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _numberController.text = widget.model!.number.toString();
      _employeeIdController.text = widget.model!.employeeId.toString();
      _startDateController.text = widget.model!.startDate.toString();
      _endDateController.text = widget.model!.endDate.toString();
      _statusController.text = widget.model!.status.toString();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _parkingIdController.dispose();
    _employeeIdController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = CashRegisterCreateModel(
            number: int.parse(_numberController.text),
            parkingId: _parkingIdController.text,
            employeeId: _employeeIdController.text,
            startDate: DateTime.parse(_startDateController.text),
            endDate: DateTime.parse(_endDateController.text),
            status: _statusController.text,
          );
          await _service.create(newModel);
        } else {
          final updatedModel = CashRegisterUpdateModel(
            number: int.parse(_numberController.text),
            employeeId: _employeeIdController.text,
            startDate: DateTime.parse(_startDateController.text),
            endDate: DateTime.parse(_endDateController.text),
            status: _statusController.text,
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CashRegister ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear CashRegister' : 'Actualizar CashRegister'),
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
                  labelText: 'Número de la caja',
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
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de inicio de la caja',
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
                  labelText: 'Fecha de fin de la caja',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(
                  labelText: 'Estado de la caja (activa, inactiva, etc.)',
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
