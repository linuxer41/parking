// Script de prueba para el endpoint de registro completo
// Ejecutar con: node test-registration.js

const API_BASE_URL = 'http://localhost:3002';

async function testCompleteRegistration() {
  const registrationData = {
    user: {
      name: "Juan Pérez",
      email: "juan@estacionamiento.com",
      password: "password123",
      phone: "+1234567890"
    },
    parking: {
      name: "Estacionamiento Central",
      capacity: 50,
      operationMode: "visual",
      location: [-12.0464, -77.0428] // Lima, Perú
    }
  };

  try {
    console.log('🚀 Iniciando prueba de registro completo...');
    console.log('📤 Enviando datos:', JSON.stringify(registrationData, null, 2));
    
    const response = await fetch(`${API_BASE_URL}/auth/register-complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(registrationData),
    });

    console.log('📥 Status:', response.status);
    let result;
    try {
      result = await response.json();
      console.log('📥 Response:', result);
    } catch (error) {
      console.log('📥 Error parsing JSON:', error.message);
      const text = await response.text();
      console.log('📥 Raw response:', text);
      return;
    }

         if (response.ok) {
       console.log('✅ Registro exitoso!');
       console.log('📋 Resumen del registro:');
       console.log(`👤 Usuario: ${result.user.name} (${result.user.email})`);
       console.log(`🏢 Parkings: ${result.parkings.length}`);
       console.log(`🔑 Token: ${result.token.substring(0, 20)}...`);
       
       console.log('\n📊 Detalles completos:');
       console.log(JSON.stringify(result, null, 2));
     } else {
      console.log('❌ Error en el registro:');
      console.log(`Status: ${response.status}`);
      console.log('Response:', result);
    }
  } catch (error) {
    console.error('💥 Error de conexión:', error.message);
  }
}

// Función para probar el login después del registro
async function testLogin(email, password) {
  try {
    console.log('\n🔐 Probando login...');
    
    const response = await fetch(`${API_BASE_URL}/auth/sign-in`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email,
        password,
      }),
    });

    const result = await response.json();

    if (response.ok) {
      console.log('✅ Login exitoso!');
      console.log(`👤 Usuario: ${result.user.name}`);
      console.log(`🏢 Parkings disponibles: ${result.parkings.length}`);
    } else {
      console.log('❌ Error en el login:');
      console.log(result);
    }
  } catch (error) {
    console.error('💥 Error de conexión:', error.message);
  }
}

// Ejecutar las pruebas
async function runTests() {
  await testCompleteRegistration();
  
  // Probar login después del registro
  await testLogin("juan@estacionamiento.com", "password123");
}

// Ejecutar si es el archivo principal
if (require.main === module) {
  runTests();
}

module.exports = { testCompleteRegistration, testLogin };
