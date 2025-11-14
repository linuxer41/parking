import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/page_layout.dart';

class FavorCardScreen extends StatefulWidget {
  const FavorCardScreen({super.key});

  @override
  State<FavorCardScreen> createState() => _FavorCardScreenState();
}

class _FavorCardScreenState extends State<FavorCardScreen> {
  final List<Map<String, dynamic>> _cards = [
    {
      'id': '1',
      'type': 'Visa',
      'number': '**** **** **** 1234',
      'fullNumber': '4111111111111234',
      'holder': 'Juan Pérez',
      'expiry': '12/25',
      'cvv': '123',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'Mastercard',
      'number': '**** **** **** 5678',
      'fullNumber': '5555555555555678',
      'holder': 'Juan Pérez',
      'expiry': '08/26',
      'cvv': '456',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Tarjeta por Favor',
      body: _buildFavorCardContent(),
    );
  }

  Widget _buildFavorCardContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información principal
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Métodos de Pago',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gestiona tus tarjetas de crédito y débito para pagos rápidos y seguros.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Lista de tarjetas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarjetas Guardadas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewCard,
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tarjetas existentes
          ..._cards.map((card) => _buildCardItem(card)).toList(),

          const SizedBox(height: 32),

          // Sección de configuración de pagos
          Text(
            'Configuración de Pagos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          _buildPaymentSettings(),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: card['isDefault']
              ? colorScheme.primary.withOpacity(0.5)
              : colorScheme.outlineVariant.withOpacity(0.3),
          width: card['isDefault'] ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icono de la tarjeta
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCardColor(card['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCardIcon(card['type']),
                    color: _getCardColor(card['type']),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Información de la tarjeta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            card['type'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (card['isDefault']) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Predeterminada',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card['number'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vence: ${card['expiry']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menú de opciones
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) => _handleCardAction(value, card),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    if (!card['isDefault'])
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(width: 8),
                            Text('Establecer como predeterminada'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Botones de acción rápida
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyCardNumber(card),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar Número'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCardDetails(card),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Ver Detalles'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSettings() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.security, color: colorScheme.primary, size: 20),
            ),
            title: const Text('Pago Automático'),
            subtitle: const Text(
              'Cargar automáticamente al final del servicio',
            ),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Pago automático activado'
                          : 'Pago automático desactivado',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            title: const Text('Notificaciones de Pago'),
            subtitle: const Text('Recibir confirmaciones de transacciones'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notificaciones activadas'
                          : 'Notificaciones desactivadas',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.receipt, color: colorScheme.primary, size: 20),
            ),
            title: const Text('Recibos Digitales'),
            subtitle: const Text('Enviar recibos por email automáticamente'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Recibos digitales activados'
                          : 'Recibos digitales desactivados',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Colors.blue;
      case 'mastercard':
        return Colors.orange;
      case 'amex':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  void _addNewCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nueva Tarjeta'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Número de Tarjeta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Titular',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarjeta agregada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _handleCardAction(String action, Map<String, dynamic> card) {
    switch (action) {
      case 'edit':
        _editCard(card);
        break;
      case 'default':
        _setAsDefault(card);
        break;
      case 'delete':
        _deleteCard(card);
        break;
    }
  }

  void _editCard(Map<String, dynamic> card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando tarjeta ${card['type']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _setAsDefault(Map<String, dynamic> card) {
    setState(() {
      for (var c in _cards) {
        c['isDefault'] = c['id'] == card['id'];
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${card['type']} establecida como predeterminada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteCard(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarjeta'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la tarjeta ${card['type']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cards.removeWhere((c) => c['id'] == card['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tarjeta ${card['type']} eliminada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _copyCardNumber(Map<String, dynamic> card) {
    Clipboard.setData(ClipboardData(text: card['fullNumber']));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Número de tarjeta copiado al portapapeles'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCardDetails(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${card['type']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Número: ${card['fullNumber']}'),
            const SizedBox(height: 8),
            Text('Titular: ${card['holder']}'),
            const SizedBox(height: 8),
            Text('Vence: ${card['expiry']}'),
            const SizedBox(height: 8),
            Text('CVV: ${card['cvv']}'),
            const SizedBox(height: 8),
            Text('Predeterminada: ${card['isDefault'] ? 'Sí' : 'No'}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
