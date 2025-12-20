import 'package:flutter/material.dart';
import '../services/print_service.dart';

class PrintMethodDialog extends StatelessWidget {
  final Function(PrintMethod) onMethodSelected;

  const PrintMethodDialog({
    super.key,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Seleccionar método de impresión'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '¿Cómo deseas imprimir el documento?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMethodButton(
                  context,
                  icon: Icons.print,
                  label: 'Impresión\nNativa',
                  description: 'Usa el diálogo de impresión del sistema',
                  method: PrintMethod.native,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodButton(
                  context,
                  icon: Icons.bluetooth,
                  label: 'Impresora\nBluetooth',
                  description: 'Envía directamente a impresora Zebra',
                  method: PrintMethod.bluetooth,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildMethodButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required PrintMethod method,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onMethodSelected(method);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<PrintMethod?> show(BuildContext context) async {
    PrintMethod? selectedMethod;

    await showDialog(
      context: context,
      builder: (context) => PrintMethodDialog(
        onMethodSelected: (method) {
          selectedMethod = method;
        },
      ),
    );

    return selectedMethod;
  }
}