
import 'package:flutter/material.dart';
import '../../models/reservation_model.dart';
import '../../services/reservation_service.dart';
import '../../di/di_container.dart';

class ReservationForm extends StatefulWidget {
  final ReservationModel? model;

  const ReservationForm({super.key, this.model});

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<ReservationService>();

  final _numberController = TextEditingController();
  final _parkingIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _vehicleIdController = TextEditingController();
  final _spotIdController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _statusController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _numberController.text = widget.model!.number.toString();
      _employeeIdController.text = widget.model!.employeeId.toString();
      _vehicleIdController.text = widget.model!.vehicleId.toString();
      _spotIdController.text = widget.model!.spotId.toString();
      _startDateController.text = widget.model!.startDate.toString();
      _endDateController.text = widget.model!.endDate.toString();
      _statusController.text = widget.model!.status.toString();
      _amountController.text = widget.model!.amount.toString();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _parkingIdController.dispose();
    _employeeIdController.dispose();
    _vehicleIdController.dispose();
    _spotIdController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _statusController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = ReservationCreateModel(
            number: int.parse(_numberController.text),
            parkingId: _parkingIdController.text,
            employeeId: _employeeIdController.text,
            vehicleId: _vehicleIdController.text,
            spotId: _spotIdController.text,
            startDate: DateTime.parse(_startDateController.text),
            endDate: DateTime.parse(_endDateController.text),
            status: _statusController.text,
            amount: double.parse(_amountController.text),
          );
          await _service.create(newModel);
        } else {
          final updatedModel = ReservationUpdateModel(
            number: int.parse(_numberController.text),
            employeeId: _employeeIdController.text,
            vehicleId: _vehicleIdController.text,
            spotId: _spotIdController.text,
            startDate: DateTime.parse(_startDateController.text),
            endDate: DateTime.parse(_endDateController.text),
            status: _statusController.text,
            amount: double.parse(_amountController.text),
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Reservation' : 'Actualizar Reservation'),
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
                  labelText: 'Número de la reserva',
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
                  labelText: 'ID del vehículo que realiza la reserva',
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
                  labelText: 'ID del puesto reservado',
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
                  labelText: 'Fecha y hora de inicio de la reserva',
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
                  labelText: 'Fecha y hora de fin de la reserva',
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
                  labelText: 'Estado de la reserva (activa, cancelada, etc.)',
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
                  labelText: 'Monto de la reserva',
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
