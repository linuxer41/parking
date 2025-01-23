
import 'package:flutter/material.dart';
import '../../models/movement_model.dart';
import '../../services/movement_service.dart';
import '../../di/di_container.dart';

class MovementForm extends StatefulWidget {
  final MovementModel? model;

  const MovementForm({super.key, this.model});

  @override
  State<MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends State<MovementForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<MovementService>();

  final _cashRegisterIdController = TextEditingController();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _typeController.text = widget.model!.type.toString();
      _amountController.text = widget.model!.amount.toString();
      _descriptionController.text = widget.model!.description.toString();
    }
  }

  @override
  void dispose() {
    _cashRegisterIdController.dispose();
    _typeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = MovementCreateModel(
            cashRegisterId: _cashRegisterIdController.text,
            type: _typeController.text,
            amount: double.parse(_amountController.text),
            description: _descriptionController.text,
          );
          await _service.create(newModel);
        } else {
          final updatedModel = MovementUpdateModel(
            type: _typeController.text,
            amount: double.parse(_amountController.text),
            description: _descriptionController.text,
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Movement ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Movement' : 'Actualizar Movement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              TextFormField(
                controller: _cashRegisterIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de la caja registradora asociada',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de movimiento (ingreso, egreso)',
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
                  labelText: 'Monto del movimiento',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del movimiento',
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
