import 'package:flutter/material.dart';
import '../models/index.dart';

/// Diálogo para editar propiedades de un espacio de estacionamiento
class SpotPropertiesDialog extends StatefulWidget {
  final ParkingSpot spot;
  final Function(ParkingSpot) onSave;
  final bool isEditMode;

  const SpotPropertiesDialog({
    Key? key,
    required this.spot,
    required this.onSave,
    this.isEditMode = true,
  }) : super(key: key);

  @override
  State<SpotPropertiesDialog> createState() => _SpotPropertiesDialogState();
}

class _SpotPropertiesDialogState extends State<SpotPropertiesDialog> {
  late TextEditingController _labelController;
  late TextEditingController _plateController;
  late SpotCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.spot.label);
    _plateController = TextEditingController(text: widget.spot.vehiclePlate ?? '');
    _selectedCategory = widget.spot.category;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      title: Row(
        children: [
          Icon(
            ElementProperties.spotVisuals[widget.spot.type]!.icon,
            color: ElementProperties.spotVisuals[widget.spot.type]!.color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Espacio ${widget.spot.label}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo para ingresar etiqueta
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Etiqueta',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Selector de categoría
          const Text('Categoría:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 4),
          
          // Filas de botones para categorías
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primera fila
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryGridItem(
                      SpotCategory.normal,
                      ElementProperties.spotCategoryVisuals[SpotCategory.normal]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCategoryGridItem(
                      SpotCategory.disabled,
                      ElementProperties.spotCategoryVisuals[SpotCategory.disabled]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Segunda fila
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryGridItem(
                      SpotCategory.reserved,
                      ElementProperties.spotCategoryVisuals[SpotCategory.reserved]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCategoryGridItem(
                      SpotCategory.vip,
                      ElementProperties.spotCategoryVisuals[SpotCategory.vip]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Información de estado de ocupación (solo en modo visualización)
          if (!widget.isEditMode) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Estado:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(width: 8),
                Switch(
                  value: widget.spot.isOccupied,
                  onChanged: (value) {
                    setState(() {
                      widget.spot.isOccupied = value;
                    });
                  },
                  activeColor: ElementProperties.occupiedColor,
                ),
                Text(
                  widget.spot.isOccupied ? 'Ocupado' : 'Libre',
                  style: TextStyle(
                    color: widget.spot.isOccupied ? ElementProperties.occupiedColor : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            // Mostrar campo de matrícula solo si está ocupado y en modo visualización
            if (widget.spot.isOccupied)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _plateController,
                  decoration: const InputDecoration(
                    labelText: 'Matrícula',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () {
            // Actualizar propiedades del spot
            widget.spot.label = _labelController.text;
            widget.spot.setCategory(_selectedCategory);
            
            // Solo actualizar matrícula en modo visualización
            if (!widget.isEditMode && widget.spot.isOccupied) {
              widget.spot.vehiclePlate = _plateController.text;
            }
            
            // Llamar al callback de guardado
            widget.onSave(widget.spot);
            Navigator.of(context).pop();
          },
          child: const Text('GUARDAR'),
        ),
      ],
    );
  }

  // Construir elemento de categoría para el grid
  Widget _buildCategoryGridItem(
    SpotCategory category,
    ElementVisuals visuals,
  ) {
    final bool isSelected = _selectedCategory == category;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
              ? visuals.color 
              : visuals.color.withOpacity(0.5), 
            width: isSelected ? 2 : 1
          ),
          borderRadius: BorderRadius.circular(4),
          color: isSelected ? visuals.color.withOpacity(0.1) : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(visuals.icon, color: visuals.color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                visuals.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: visuals.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 