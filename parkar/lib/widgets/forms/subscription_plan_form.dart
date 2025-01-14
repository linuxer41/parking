
import 'package:flutter/material.dart';
import '../../models/subscription_plan_model.dart';
import '../../services/subscription_plan_service.dart';
import '../../di/di_container.dart';

class SubscriptionPlanForm extends StatefulWidget {
  final SubscriptionPlanModel? model;

  const SubscriptionPlanForm({super.key, this.model});

  @override
  State<SubscriptionPlanForm> createState() => _SubscriptionPlanFormState();
}

class _SubscriptionPlanFormState extends State<SubscriptionPlanForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<SubscriptionPlanService>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _parkingIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _nameController.text = widget.model!.name.toString();
      _descriptionController.text = widget.model!.description.toString();
      _priceController.text = widget.model!.price.toString();
      _durationController.text = widget.model!.duration.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _parkingIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = SubscriptionPlanCreateModel(
            name: _nameController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            duration: int.parse(_durationController.text),
            parkingId: _parkingIdController.text,
          );
          await _service.create(newModel);
        } else {
          final updatedModel = SubscriptionPlanUpdateModel(
            name: _nameController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            duration: int.parse(_durationController.text),
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SubscriptionPlan ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear SubscriptionPlan' : 'Actualizar SubscriptionPlan'),
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
                  labelText: 'Nombre del plan',
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
                  labelText: 'Descripción opcional del plan',
                ),
                validator: (value) {
                  if (false && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio del plan',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duración del plan en días',
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
