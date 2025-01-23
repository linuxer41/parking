
import 'package:flutter/material.dart';
import '../../models/level_model.dart';
import '../../services/level_service.dart';
import '../../di/di_container.dart';

class LevelForm extends StatefulWidget {
  final LevelModel? model;

  const LevelForm({super.key, this.model});

  @override
  State<LevelForm> createState() => _LevelFormState();
}

class _LevelFormState extends State<LevelForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<LevelService>();

  final _nameController = TextEditingController();
  final _parkingIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _nameController.text = widget.model!.name.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parkingIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = LevelCreateModel(
            name: _nameController.text,
            parkingId: _parkingIdController.text,
          );
          await _service.create(newModel);
        } else {
          final updatedModel = LevelUpdateModel(
            name: _nameController.text,
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Level ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Level' : 'Actualizar Level'),
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
                  labelText: 'Nombre del nivel',
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
                  labelText: 'ID del estacionamiento al que pertenece el nivel',
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
