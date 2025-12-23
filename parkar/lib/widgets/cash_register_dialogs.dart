import 'package:flutter/material.dart';
import 'package:parkar/constants/constants.dart';
import 'package:parkar/models/cash_register_model.dart';
import 'package:parkar/models/movement_model.dart';
import 'package:parkar/services/cash_register_service.dart';
import 'package:parkar/services/movement_service.dart';
import 'package:parkar/state/app_state_container.dart';
import 'package:intl/intl.dart';

class CashRegisterDialogs {
  static Future<CashRegisterModel?> showOpenCashRegisterDialog(BuildContext context) async {
    final TextEditingController amountController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final openingTime = DateTime.now();

    return showDialog<CashRegisterModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          title: Center(
            child: Text(
              'Apertura de Caja',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Apertura: ${DateTimeConstants.formatDateTimeWithParkingParams(context, openingTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto Inicial',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingrese un monto válido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final cashRegister = await AppStateContainer.di(context).resolve<CashRegisterService>().openCashRegister(
                    CashRegisterCreateModel(
                      startDate: DateTime.now(),
                      initialAmount: amount,
                    ),
                  );
                  AppStateContainer.of(context).setCurrentCashRegister(cashRegister);
                  print('Nueva caja abierta: ${cashRegister.id}');
                  Navigator.of(context).pop(cashRegister);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al abrir caja: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Abrir Caja'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showCloseCashRegisterDialog(BuildContext context, CashRegisterModel currentCashRegister, double totalCash) async {
    final TextEditingController commentController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final closingTime = DateTime.now();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          title: Center(
            child: Text(
              'Cierre de Caja',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total: ${CurrencyConstants.formatAmountWithParkingParams(context, totalCash)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cierre: ${DateTimeConstants.formatDateTimeWithParkingParams(context, closingTime)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comentario (Opcional)',
                    hintText: 'Ej: Cierre por fin de turno...',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final cashRegisterService = CashRegisterService();
                  await cashRegisterService.closeCashRegister(
                    currentCashRegister.id,
                    CashRegisterCloseModel(
                      endDate: DateTime.now(),
                      comment: commentController.text.trim().isNotEmpty ? commentController.text.trim() : null,
                    ),
                  );
                  AppStateContainer.of(context).setCurrentCashRegister(null);
                  Navigator.of(context).pop(true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar caja: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Cerrar Caja'),
            ),
          ],
        );
      },
    );
  }
}