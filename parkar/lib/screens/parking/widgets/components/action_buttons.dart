import 'package:flutter/material.dart';

/// Componentes reutilizables para los botones de acción en los modales

/// Botón de acción primaria
class PrimaryActionButton extends StatelessWidget {
  /// Texto a mostrar en el botón
  final String label;
  
  /// Icono opcional
  final IconData? icon;
  
  /// Función a ejecutar al presionar el botón
  final VoidCallback onPressed;
  
  /// Indicador de carga
  final bool isLoading;
  
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: isLoading
            ? SizedBox(
                height: 16, width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: const TextStyle(fontSize: 13)),
                ],
              ),
      ),
    );
  }
}

/// Botón de acción secundaria
class SecondaryActionButton extends StatelessWidget {
  /// Texto a mostrar en el botón
  final String label;
  
  /// Icono opcional
  final IconData? icon;
  
  /// Función a ejecutar al presionar el botón
  final VoidCallback onPressed;
  
  /// Indicador de carga
  final bool isLoading;
  
  const SecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: isLoading
            ? SizedBox(
                height: 16, width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: const TextStyle(fontSize: 13)),
                ],
              ),
      ),
    );
  }
}

/// Botón de cancelación (para cancelar reservas o suscripciones)
class CancelButton extends StatelessWidget {
  /// Texto a mostrar en el botón (normalmente en dos líneas)
  final String label;
  
  /// Icono para el botón
  final IconData icon;
  
  /// Función a ejecutar al presionar el botón
  final VoidCallback onPressed;
  
  /// Indicador de carga
  final bool isLoading;
  
  const CancelButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(
        icon,
        size: 16,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.error,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(40, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 