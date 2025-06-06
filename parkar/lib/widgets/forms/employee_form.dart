
import 'package:flutter/material.dart';
import '../../models/employee_model.dart';
import '../../services/employee_service.dart';
import '../../di/di_container.dart';

class EmployeeForm extends StatefulWidget {
  final EmployeeModel? model;

  const EmployeeForm({super.key, this.model});

  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<EmployeeService>();

  final _userIdController = TextEditingController();
  final _companyIdController = TextEditingController();
  final _roleController = TextEditingController();
  final _assignedParkingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _roleController.text = widget.model!.role.toString();
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _companyIdController.dispose();
    _roleController.dispose();
    _assignedParkingsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = EmployeeCreateModel(
            userId: _userIdController.text,
            companyId: _companyIdController.text,
            role: _roleController.text,
            assignedParkings: [],
          );
          await _service.create(newModel);
        } else {
          final updatedModel = EmployeeUpdateModel(
            role: _roleController.text,
            assignedParkings: [],
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Employee' : 'Actualizar Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del usuario asociado al empleado',
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
                  labelText: 'ID de la empresa a la que pertenece el empleado',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Rol del empleado',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _assignedParkingsController,
                decoration: const InputDecoration(
                  labelText: 'Estacionamientos asignados al empleado',
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
