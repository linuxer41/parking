// Script de debug para identificar el problema de validación
const API_BASE_URL = 'http://localhost:3002';

async function debugRegistration() {
  // Test 1: Solo usuario básico
  console.log('🔍 Test 1: Validando esquema de usuario...');
  try {
    const userData = {
      name: "Test User",
      email: "test@test.com",
      password: "password123",
      phone: "+1234567890"
    };
    
    const response = await fetch(`${API_BASE_URL}/auth/sign-up`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData),
    });
    
    const result = await response.json();
    console.log('Usuario básico:', response.status, result);
  } catch (error) {
    console.error('Error usuario básico:', error.message);
  }

  // Test 2: Datos mínimos del registro completo
  console.log('\n🔍 Test 2: Validando registro completo mínimo...');
  try {
    const minimalData = {
      user: {
        name: "Test User",
        email: "test2@test.com",
        password: "password123",
        phone: "+1234567890"
      },
      parking: {
        name: "Test Parking",
        email: "parking@test.com",
        capacity: 10,
        params: {
          currency: "USD",
          timeZone: "America/New_York",
          decimalPlaces: 2,
          countryCode: "US",
          theme: "default"
        },
        rates: [
          {
            id: "rate-001",
            name: "Standard",
            vehicleCategory: 3,
            tolerance: 15,
            hourly: 2.5,
            daily: 25,
            weekly: 150,
            monthly: 500,
            yearly: 5000,
            isActive: true
          }
        ]
      }
    };
    
    const response = await fetch(`${API_BASE_URL}/auth/register-complete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(minimalData),
    });
    
    const result = await response.json();
    console.log('Registro completo mínimo:', response.status, result);
  } catch (error) {
    console.error('Error registro completo:', error.message);
  }

  // Test 3: Con datos completos como en el test original
  console.log('\n🔍 Test 3: Validando registro completo con todos los datos...');
  try {
    const fullData = {
      user: {
        name: "Juan Pérez",
        email: "juan@estacionamiento.com",
        password: "password123",
        phone: "+1234567890"
      },
      parking: {
        name: "Estacionamiento Central",
        email: "info@estacionamiento.com",
        phone: "+1234567890",
        address: "Calle Principal 123",
        capacity: 50,
        params: {
          currency: "USD",
          timeZone: "America/New_York",
          decimalPlaces: 2,
          countryCode: "US",
          theme: "default",
          slogan: "Tu estacionamiento de confianza"
        },
        rates: [
          {
            id: "rate-001",
            name: "Tarifa Estándar",
            vehicleCategory: 3,
            tolerance: 15,
            hourly: 2.50,
            daily: 25.00,
            weekly: 150.00,
            monthly: 500.00,
            yearly: 5000.00,
            isActive: true
          }
        ]
      }
    };
    
    const response = await fetch(`${API_BASE_URL}/auth/register-complete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(fullData),
    });
    
    const result = await response.json();
    console.log('Registro completo completo:', response.status, result);
  } catch (error) {
    console.error('Error registro completo completo:', error.message);
  }
}

// Ejecutar debug
debugRegistration();
