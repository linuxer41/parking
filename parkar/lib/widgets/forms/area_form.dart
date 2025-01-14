
import 'package:flutter/material.dart';
import '../../models/area_model.dart';
import '../../services/area_service.dart';
import '../../di/di_container.dart';

class AreaForm extends StatefulWidget {
  final AreaModel? model;

  const AreaForm({super.key, this.model});

  @override
  State<AreaForm> createState() => _AreaFormState();
}

class _AreaFormState extends State<AreaForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<AreaService>();

  final _nameController = TextEditingController();
  final _parkingIdController = TextEditingController();
  final _levelIdController = TextEditingController();

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
    _levelIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = AreaCreateModel(
            name: _nameController.text,
            parkingId: _parkingIdController.text,
            levelId: _levelIdController.text,
          );
          await _service.create(newModel);
        } else {
          final updatedModel = AreaUpdateModel(
            name: _nameController.text,
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Area ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Area' : 'Actualizar Area'),
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
                  labelText: 'Nombre del área',
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
                controller: _levelIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del nivel al que pertenece el área',
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
