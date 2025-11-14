# Diseño de Dos Columnas para Panel de Control

## Descripción

Esta implementación proporciona un diseño responsivo para el panel de control que se adapta automáticamente según el tamaño de la pantalla:

- **Pantallas grandes (PC)**: Diseño de dos columnas donde el panel principal está a la izquierda y las páginas dinámicas aparecen a la derecha
- **Pantallas pequeñas (móvil)**: Diseño tradicional de una sola columna con navegación de página completa

## Características Principales

### 1. Diseño Responsivo
- **Breakpoint**: 900px de ancho
- **Pantallas > 900px**: Diseño de dos columnas
- **Pantallas ≤ 900px**: Diseño de una columna con navegación tradicional

### 2. Navegación Inteligente
- En pantallas grandes, las páginas se muestran en la columna derecha sin cambiar de pantalla
- La columna derecha siempre está visible, mostrando un mensaje de selección cuando no hay contenido
- En pantallas pequeñas, se usa la navegación tradicional con `Navigator.push`
- Transiciones suaves entre estados

### 3. Estado Centralizado
- Enum `PanelScreen` para manejar las pantallas disponibles
- Estado `_currentScreen` para controlar qué pantalla se muestra en la columna derecha
- Información del parking guardada para uso en las pantallas

## Componentes Implementados

### Enum PanelScreen
```dart
enum PanelScreen {
  dashboard,      // Panel principal
  statistics,     // Estadísticas
  parkingDetail,  // Detalles del parking
  parkingRates,   // Tarifas del parking
}
```

### Métodos Principales

#### `_navigateToScreen(PanelScreen screen)`
- Cambia el estado para mostrar la pantalla especificada en la columna derecha
- Solo funciona en pantallas grandes

#### `_backToDashboard()`
- Vuelve al estado del dashboard (muestra el mensaje de selección en la columna derecha)

#### `_buildRightPanelContent()`
- Construye el contenido de la columna derecha según la pantalla seleccionada
- Pasa el parámetro `isModal: true` a las pantallas para que no muestren su propio `Scaffold`

#### `_buildRightPanelHeader()`
- Construye el header de la columna derecha con título y botón de regreso

## Estructura del Layout

### Pantallas Grandes (> 900px)
```
┌─────────────────────────────────────────────────────────┐
│                    AppBar                               │
├─────────────────────┬───────────────────────────────────┤
│                     │                                   │
│   Panel Principal   │    Área de Contenido              │
│   (Columna Izq.)    │    (Columna Der.)                 │
│                     │                                   │
│   - Acciones        │    - Header con título            │
│   - Resumen         │    - Mensaje de selección         │
│   - Gráficos        │    - Contenido dinámico           │
│                     │    - Botón de regreso             │
│                     │                                   │
└─────────────────────┴───────────────────────────────────┘
```

### Pantallas Pequeñas (≤ 900px)
```
┌─────────────────────────────────────────────────────────┐
│                    AppBar                               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│              Panel Principal                            │
│                                                         │
│   - Acciones                                           │
│   - Resumen                                            │
│   - Gráficos                                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Pantallas Soportadas

### 1. Estadísticas (`StatisticsPanel`)
- **Acceso**: Botón "Estadísticas" en acciones rápidas
- **Contenido**: Resumen financiero, ocupación, actividad reciente

### 2. Gestión de Parking (`ParkingDetailScreen`)
- **Acceso**: Botón "Gestionar Parqueo" en acciones rápidas
- **Contenido**: Información detallada del parking seleccionado

### 3. Tarifas (`ParkingRatesScreen`)
- **Acceso**: Botón "Tarifas" en acciones rápidas
- **Contenido**: Gestión de tarifas del parking

## Implementación Técnica

### Modificaciones en DashboardScreen

1. **Estado Agregado**:
   ```dart
   PanelScreen _currentScreen = PanelScreen.dashboard;
   String? _parkingId;
   String? _parkingName;
   ```

2. **Lógica de Navegación**:
   ```dart
   // En pantallas grandes
   if (size.width > 900) {
     _navigateToScreen(PanelScreen.statistics);
   } else {
     // Navegación tradicional
     PanelNavigationHelper.navigateToStatistics(context);
   }
   ```

3. **Layout Condicional**:
   ```dart
   if (isLargeScreen) {
     return Scaffold(
       body: Row(
         children: [
           // Columna izquierda
           Expanded(flex: 1, child: _buildLeftPanel()),
                       // Columna derecha (siempre visible)
            Expanded(flex: 1, child: _buildRightPanel()),
          ],
        ),
      );
    }
   ```

### Modificaciones en Pantallas de Panel

Todas las pantallas de panel (`StatisticsPanel`, `ParkingDetailScreen`, `ParkingRatesScreen`) han sido modificadas para aceptar un parámetro `isModal`:

```dart
class StatisticsPanel extends StatelessWidget {
  final bool isModal;
  const StatisticsPanel({super.key, this.isModal = false});
  
  @override
  Widget build(BuildContext context) {
    final content = SafeArea(child: /* contenido principal */);
    
    if (isModal) {
      return content; // Sin Scaffold/AppBar
    }
    
    return Scaffold(
      appBar: AppBar(/* ... */),
      body: content,
    );
  }
}
```

## Ventajas de esta Implementación

1. **Experiencia de Usuario Mejorada**: En PC, los usuarios pueden ver el panel principal y la información detallada simultáneamente
2. **Navegación Eficiente**: No se pierde el contexto del panel principal al ver detalles
3. **Responsividad**: Se adapta automáticamente al tamaño de pantalla
4. **Consistencia**: Mantiene el mismo diseño en móvil que funcionaba bien
5. **Escalabilidad**: Fácil agregar nuevas pantallas al enum `PanelScreen`

## Consideraciones

1. **Ancho Mínimo**: El breakpoint de 900px asegura que haya suficiente espacio para ambas columnas
2. **Scroll Independiente**: Cada columna tiene su propio scroll
3. **Estado Persistente**: El estado del panel principal se mantiene al cambiar pantallas
4. **Compatibilidad**: Funciona con el sistema de navegación existente
5. **Columna Derecha Siempre Visible**: En pantallas grandes, la columna derecha siempre está presente, mostrando un mensaje de selección cuando no hay contenido activo

## Uso

Para agregar una nueva pantalla al sistema de dos columnas:

1. Agregar el nuevo tipo al enum `PanelScreen`
2. Implementar la lógica en `_buildRightPanelContent()`
3. Agregar el título en `_buildRightPanelHeader()`
4. Crear el botón de acción correspondiente
5. Modificar la pantalla para aceptar el parámetro `isModal`
