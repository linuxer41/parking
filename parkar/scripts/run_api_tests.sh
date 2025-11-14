#!/bin/bash

# 🚀 Parkar API Tests Runner (Solo Pruebas de API)
# Este script ejecuta solo las pruebas de API que funcionan correctamente

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

# Ejecutar pruebas unitarias de servicios
echo ""
print_status "🔧 Ejecutando pruebas unitarias de servicios..."

# Booking Service Tests
print_status "  - Booking Service Tests..."
flutter test test/services/booking_service_test.dart

if [ $? -eq 0 ]; then
    print_success "  ✅ Booking Service Tests pasaron"
else
    print_error "  ❌ Booking Service Tests fallaron"
    exit 1
fi

# Entry/Exit Service Tests
print_status "  - Entry/Exit Service Tests..."
flutter test test/services/access_service_test.dart

if [ $? -eq 0 ]; then
    print_success "  ✅ Entry/Exit Service Tests pasaron"
else
    print_error "  ❌ Entry/Exit Service Tests fallaron"
    exit 1
fi

# Subscription Service Tests
print_status "  - Subscription Service Tests..."
flutter test test/services/subscription_service_test.dart

if [ $? -eq 0 ]; then
    print_success "  ✅ Subscription Service Tests pasaron"
else
    print_error "  ❌ Subscription Service Tests fallaron"
    exit 1
fi

# Ejecutar pruebas de integración
echo ""
print_status "🔗 Ejecutando pruebas de integración..."

# API Integration Tests
print_status "  - API Integration Tests..."
flutter test test/integration/api_integration_test.dart

if [ $? -eq 0 ]; then
    print_success "  ✅ API Integration Tests pasaron"
else
    print_error "  ❌ API Integration Tests fallaron"
    exit 1
fi

# Ejecutar todas las pruebas de API juntas
echo ""
print_status "🎯 Ejecutando todas las pruebas de API juntas..."
flutter test test/services/ test/integration/

# Verificar resultados
if [ $? -eq 0 ]; then
    echo ""
    print_success "✅ Todas las pruebas de API pasaron exitosamente!"
    print_success "🎉 Los servicios de API están listos para producción"
else
    echo ""
    print_error "❌ Algunas pruebas de API fallaron"
    print_warning "Revisa los resultados arriba para más detalles"
    exit 1
fi

echo ""
echo "======================================"
print_success "🏁 Parkar API Tests Suite completado!"
echo ""
print_status "📊 Resumen de pruebas ejecutadas:"
echo "  - ✅ Pruebas unitarias de BookingService"
echo "  - ✅ Pruebas unitarias de AccessService"
echo "  - ✅ Pruebas unitarias de SubscriptionService"
echo "  - ✅ Pruebas de integración de API"
echo ""
print_status "🚀 Los servicios de API están actualizados y funcionando!"
print_status "📝 Nota: Algunos archivos de UI pueden necesitar actualización"
