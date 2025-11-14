# Navegación Responsive para Pantallas del Panel

## Descripción

Esta solución implementa una navegación responsive para las pantallas del panel que se adapta automáticamente según el tamaño de la pantalla:

- **En móvil (< 600px)**: Pantallas completas con navegación normal
- **En PC (≥ 600px)**: Modales centrados con ancho máximo controlado

## Componentes

### 1. PanelScreenWrapper
Widget que envuelve las pantallas del panel y las presenta de manera responsive.

**Características:**
- Detecta automáticamente el tamaño de pantalla
- En móvil: muestra el contenido directamente
- En PC: envuelve el contenido en un modal centrado con header personalizado

**Parámetros:**
- `child`: Widget de la pantalla a mostrar
- `title`: Título que aparece en el header del modal
- `maxWidth`: Ancho máximo para pantallas de escritorio (por defecto 800px)
- `maxHeight`: Altura máxima como porcentaje de la pantalla (por defecto 90%)

### 2. PanelNavigationHelper
Clase helper que proporciona métodos para navegar a las pantallas del panel de manera responsive.

**Métodos disponibles:**
- `navigateToStatistics(context)`: Navega a estadísticas
- `navigateToParkingRates(context, parkingId, parkingName)`: Navega a tarifas
- `navigateToParkingDetail(context, parkingId, parkingName)`: Navega a detalles de parking
- `navigateToPanelScreen(context, screen, title, maxWidth, maxHeight)`: Método genérico

## Uso

### Navegación desde el Dashboard

```dart
// Antes (solo pantalla completa)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const StatisticsPanel(),
  ),
);

// Ahora (responsive)
PanelNavigationHelper.navigateToStatistics(context);
```

### Navegación desde Detalles de Parking

```dart
// Antes
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ParkingRatesScreen(
      parkingId: parkingId,
      parkingName: parkingName,
    ),
  ),
);

// Ahora
PanelNavigationHelper.navigateToParkingRates(
  context,
  parkingId: parkingId,
  parkingName: parkingName,
);
```

## Pantallas Modificadas

Las siguientes pantallas han sido modificadas para soportar el modo modal:

1. **StatisticsPanel**: Agregado parámetro `isModal`
2. **ParkingRatesScreen**: Agregado parámetro `isModal`
3. **ParkingDetailScreen**: Agregado parámetro `isModal`

### Estructura de las Pantallas Modificadas

```dart
class ExampleScreen extends StatelessWidget {
  final bool isModal;
  
  const ExampleScreen({this.isModal = false});
  
  @override
  Widget build(BuildContext context) {
    // Contenido principal
    final content = SafeArea(
      child: // ... contenido de la pantalla
    );
    
    // Si es modal, solo retornar el contenido
    if (isModal) {
      return content;
    }
    
    // Si no es modal, usar Scaffold completo
    return Scaffold(
      appBar: AppBar(...),
      body: content,
    );
  }
}
```

## Beneficios

1. **Experiencia de usuario mejorada**: En PC, las pantallas no ocupan toda la pantalla
2. **Diseño consistente**: Mantiene el mismo diseño en móvil y PC
3. **Fácil implementación**: Solo cambiar las llamadas de navegación
4. **Flexibilidad**: Permite personalizar el tamaño de los modales
5. **Mantenibilidad**: Código centralizado en helpers

## Consideraciones

- Los modales en PC tienen un ancho máximo de 800px por defecto
- La altura máxima es del 90% de la pantalla
- Los modales se pueden cerrar haciendo clic fuera de ellos
- El header del modal incluye un botón de cerrar
- Las pantallas mantienen toda su funcionalidad en ambos modos

## Ejemplo de Implementación Completa

```dart
// En cualquier pantalla
ElevatedButton(
  onPressed: () {
    PanelNavigationHelper.navigateToStatistics(context);
  },
  child: Text('Ver Estadísticas'),
),
```

Esto automáticamente mostrará:
- Una pantalla completa en móvil
- Un modal centrado en PC
