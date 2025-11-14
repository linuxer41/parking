# Parkar API Tests Suite - PowerShell Script
# Ejecuta todas las pruebas unitarias e integración para la nueva API

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Verificar si Flutter está instalado
try {
    $flutterVersion = flutter --version 2>$null | Select-Object -First 1
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter no está instalado"
    }
    Write-Status "Flutter encontrado: $flutterVersion"
} catch {
    Write-Error "Flutter no está instalado o no está en el PATH"
    exit 1
}

# Verificar si estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
}

Write-Status "Directorio del proyecto verificado"

# Obtener dependencias
Write-Status "Obteniendo dependencias..."
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error al obtener dependencias"
    exit 1
}

Write-Success "Dependencias obtenidas correctamente"

# Ejecutar pruebas unitarias
Write-Host ""
Write-Status "Ejecutando pruebas unitarias..."

# Booking Service Tests
Write-Status "  - Booking Service Tests..."
flutter test test/services/booking_service_test.dart

# Entry/Exit Service Tests
Write-Status "  - Entry/Exit Service Tests..."
flutter test test/services/access_service_test.dart

# Subscription Service Tests
Write-Status "  - Subscription Service Tests..."
flutter test test/services/subscription_service_test.dart

# Ejecutar pruebas de integración
Write-Host ""
Write-Status "Ejecutando pruebas de integración..."

# API Integration Tests
Write-Status "  - API Integration Tests..."
flutter test test/integration/api_integration_test.dart

# Ejecutar todas las pruebas juntas
Write-Host ""
Write-Status "Ejecutando todas las pruebas juntas..."
flutter test

# Verificar resultados
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Success "Todas las pruebas pasaron exitosamente!"
    Write-Success "El código está listo para producción"
} else {
    Write-Host ""
    Write-Error "Algunas pruebas fallaron"
    Write-Warning "Revisa los resultados arriba para más detalles"
    exit 1
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Success "Parkar API Tests Suite completado!"
Write-Host ""
Write-Status "Resumen de pruebas ejecutadas:"
Write-Host "  - Pruebas unitarias de servicios" -ForegroundColor Green
Write-Host "  - Pruebas de integración de API" -ForegroundColor Green
Write-Host "  - Validación de modelos de datos" -ForegroundColor Green
Write-Host "  - Verificación de endpoints" -ForegroundColor Green
Write-Host ""
Write-Status "El sistema está listo para usar la nueva API!"
