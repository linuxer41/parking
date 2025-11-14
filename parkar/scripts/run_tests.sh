#!/bin/bash

# 🚀 Parkar API Tests Runner
# Este script ejecuta todas las pruebas unitarias e integración

echo "🚀 Iniciando Parkar API Tests Suite..."
echo "======================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado o no está en el PATH"
    exit 1
fi

print_status "Flutter encontrado: $(flutter --version | head -n 1)"

# Verificar si estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

print_status "Directorio del proyecto verificado"

# Obtener dependencias
print_status "Obteniendo dependencias..."
flutter pub get

if [ $? -ne 0 ]; then
    print_error "Error al obtener dependencias"
    exit 1
fi

print_success "Dependencias obtenidas correctamente"

# Ejecutar pruebas unitarias
echo ""
print_status "🔧 Ejecutando pruebas unitarias..."

# Booking Service Tests
print_status "  - Booking Service Tests..."
flutter test test/services/booking_service_test.dart

# Entry/Exit Service Tests
print_status "  - Entry/Exit Service Tests..."
flutter test test/services/entry_exit_service_test.dart

# Subscription Service Tests
print_status "  - Subscription Service Tests..."
flutter test test/services/subscription_service_test.dart

# Ejecutar pruebas de integración
echo ""
print_status "🔗 Ejecutando pruebas de integración..."

# API Integration Tests
print_status "  - API Integration Tests..."
flutter test test/integration/api_integration_test.dart

# Ejecutar todas las pruebas juntas
echo ""
print_status "🎯 Ejecutando todas las pruebas juntas..."
flutter test

# Verificar resultados
if [ $? -eq 0 ]; then
    echo ""
    print_success "✅ Todas las pruebas pasaron exitosamente!"
    print_success "🎉 El código está listo para producción"
else
    echo ""
    print_error "❌ Algunas pruebas fallaron"
    print_warning "Revisa los resultados arriba para más detalles"
    exit 1
fi

echo ""
echo "======================================"
print_success "🏁 Parkar API Tests Suite completado!"
echo ""
print_status "📊 Resumen de pruebas ejecutadas:"
echo "  - ✅ Pruebas unitarias de servicios"
echo "  - ✅ Pruebas de integración de API"
echo "  - ✅ Validación de modelos de datos"
echo "  - ✅ Verificación de endpoints"
echo ""
print_status "🚀 El sistema está listo para usar la nueva API!"
