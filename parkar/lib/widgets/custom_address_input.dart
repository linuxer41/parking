import 'package:flutter/material.dart';
import 'map_selection_screen.dart';

class CustomAddressInput extends StatefulWidget {
  final TextEditingController addressController;
  final TextEditingController? latitudeController;
  final TextEditingController? longitudeController;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final bool enabled;

  const CustomAddressInput({
    super.key,
    required this.addressController,
    this.latitudeController,
    this.longitudeController,
    this.labelText,
    this.hintText,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<CustomAddressInput> createState() => _CustomAddressInputState();
}

class _CustomAddressInputState extends State<CustomAddressInput> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText ?? 'Dirección',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.addressController,
                enabled: widget.enabled,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Ingresa la dirección',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                validator: widget.validator ?? _defaultValidator,
                textInputAction: widget.textInputAction ?? TextInputAction.next,
                onFieldSubmitted: (_) => widget.onSubmitted?.call(),
                autocorrect: false,
                enableSuggestions: true,
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: widget.enabled ? _openMap : null,
              icon: Icon(
                Icons.location_on,
                size: 18,
                color: colorScheme.primary,
              ),
              label: Text(
                'Mapa',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        // Mostrar coordenadas si están disponibles
        if (widget.latitudeController != null &&
            widget.longitudeController != null &&
            (widget.latitudeController!.text.isNotEmpty ||
                widget.longitudeController!.text.isNotEmpty))
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: ${widget.latitudeController!.text}, Long: ${widget.longitudeController!.text}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la dirección';
    }
    return null;
  }

  void _openMap() async {
    // Navegar a la pantalla de selección de mapa
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapSelectionScreen()),
    );

    // Si se seleccionó una ubicación, actualizar los campos
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        widget.addressController.text = result['address'] ?? '';
        widget.latitudeController?.text = result['latitude']?.toString() ?? '';
        widget.longitudeController?.text =
            result['longitude']?.toString() ?? '';
      });
    }
  }
}
