
import 'package:flutter/material.dart';
import '../../models/price_model.dart';
import '../../services/price_service.dart';
import '../../di/di_container.dart';

class PriceForm extends StatefulWidget {
  final PriceModel? model;

  const PriceForm({super.key, this.model});

  @override
  State<PriceForm> createState() => _PriceFormState();
}

class _PriceFormState extends State<PriceForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<PriceService>();

  final _parkingIdController = TextEditingController();
  final _vehicleTypeIdController = TextEditingController();
  final _timeRangeIdController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _vehicleTypeIdController.text = widget.model!.vehicleTypeId.toString();
      _timeRangeIdController.text = widget.model!.timeRangeId.toString();
      _amountController.text = widget.model!.amount.toString();
    }
  }

  @override
  void dispose() {
    _parkingIdController.dispose();
    _vehicleTypeIdController.dispose();
    _timeRangeIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = PriceCreateModel(
            parkingId: _parkingIdController.text,
            vehicleTypeId: _vehicleTypeIdController.text,
            timeRangeId: _timeRangeIdController.text,
            amount: double.parse(_amountController.text),
          );
          await _service.create(newModel);
        } else {
          final updatedModel = PriceUpdateModel(
            vehicleTypeId: _vehicleTypeIdController.text,
            timeRangeId: _timeRangeIdController.text,
            amount: double.parse(_amountController.text),
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Price ${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
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
        title: Text(widget.model == null ? 'Crear Price' : 'Actualizar Price'),
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
                controller: _vehicleTypeIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del tipo de vehículo',
                ),
                validator: (value) {
                  if (true && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  
                  
                  
                  return null;
                },
              ),
              
              
              TextFormField(
                controller: _timeRangeIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del rango de tiempo',
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
                  labelText: 'Monto del precio',
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
