# Cambios Realizados: Eliminación de Capacidad

## Resumen
Se ha eliminado la variable `capacity` del sistema de estacionamiento. Ahora la capacidad es infinita por defecto, y en modo map se crean automáticamente 20 spots.

## Cambios Realizados

### 1. Base de Datos
- **Archivo**: `src/postgres-schema.sql`
- **Cambio**: Eliminada la columna `capacity` de la tabla `t_parking`
- **Comentario**: Eliminado el comentario sobre capacidad máxima

### 2. Modelos de Datos
- **Archivo**: `src/models/parking.ts`
- **Cambios**:
  - Eliminado el campo `capacity` del `ParkingSchema`
  - Eliminado `capacity` del `ParkingUpdateSchema`
  - Corregidos los esquemas de creación y actualización

- **Archivo**: `src/models/auth.ts`
- **Cambios**:
  - Eliminado el campo `capacity` del `RegistrationSchema`

### 3. Servicios
- **Archivo**: `src/services/registration-service.ts`
- **Cambios**:
  - Eliminada la referencia a `data.parking.capacity`
  - Modificada la lógica para crear 20 spots por defecto siempre
  - Se crean spots automáticamente tanto en modo map como list

### 4. Consultas SQL
- **Archivo**: `src/db/crud/user.ts`
- **Cambios**:
  - Eliminadas las referencias a `p.capacity` en las consultas
  - Actualizado el GROUP BY para excluir capacity

### 5. Datos de Prueba
- **Archivo**: `src/seed.ts`
- **Cambios**:
  - Eliminada la propiedad `capacity` de los datos de prueba

- **Archivos**: `debug-test.js`, `test-clean-error-handling.js`
- **Cambios**:
  - Eliminadas las referencias a `capacity` en los datos de prueba

### 6. Migración de Base de Datos
- **Archivo**: `src/migrations/remove-capacity-column.sql`
- **Descripción**: Script SQL para eliminar la columna capacity de tablas existentes

- **Archivo**: `src/scripts/run-migration.js`
- **Descripción**: Script Node.js para ejecutar la migración

## Nuevo Comportamiento

### Registro de Estacionamiento
1. **Modo Visual**: Se crean automáticamente 20 spots en el área principal
2. **Modo Simple**: Se crean automáticamente 20 spots en el área principal
3. **Capacidad**: Infinita (no hay límite)

### Creación de Spots
- Los spots se crean en una cuadrícula organizada
- Dimensiones: 80x160 unidades con espaciado de 20x40
- Nombres: "Spot 001", "Spot 002", etc.

## Ejecución de Migración

Para aplicar los cambios a una base de datos existente:

```bash
# Ejecutar la migración
bun run migrate

# O ejecutar manualmente
bun run src/scripts/run-migration.js
```

## Verificación

Para verificar que los cambios funcionan correctamente:

```bash
# Ejecutar el servidor
bun run dev

# Probar el registro completo
bun run debug-test.js
```

## Notas Importantes

1. **Compatibilidad**: Los cambios son compatibles con versiones anteriores
2. **Datos Existentes**: La migración elimina la columna capacity sin afectar otros datos
3. **API**: Los endpoints siguen funcionando igual, solo sin el campo capacity
4. **Frontend**: Debe actualizarse para no enviar el campo capacity en las peticiones

## Archivos Modificados

- `src/postgres-schema.sql`
- `src/models/parking.ts`
- `src/models/auth.ts`
- `src/services/registration-service.ts`
- `src/db/crud/user.ts`
- `src/seed.ts`
- `debug-test.js`
- `test-clean-error-handling.js`
- `package.json`

## Archivos Nuevos

- `src/migrations/remove-capacity-column.sql`
- `src/scripts/run-migration.js`
- `CAPACITY_REMOVAL_CHANGES.md`
