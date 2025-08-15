// Test simple para el esquema simplificado
const API_BASE_URL = 'http://localhost:3002';

async function testSimple() {
  console.log('🔍 Test simple con esquema simplificado...');
  
  const data = {
    user: {
      name: "Test User",
      email: "test@test.com",
      password: "password123",
      phone: "+1234567890"
    },
    parking: {
      name: "Test Parking",
      capacity: 10,
      operationMode: "visual"
    }
  };
  
  console.log('📤 Enviando datos:', JSON.stringify(data, null, 2));
  
  try {
    const response = await fetch(`${API_BASE_URL}/auth/register-complete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    
    console.log('📥 Status:', response.status);
    
         if (response.ok) {
       const result = await response.json();
       console.log('✅ Éxito!');
       console.log('👤 Usuario:', result.user.name);
       console.log('🏢 Parkings:', result.parkings.length);
       console.log('🔑 Token:', result.token.substring(0, 20) + '...');
     } else {
      const text = await response.text();
      console.log('❌ Error:', text);
    }
    
  } catch (error) {
    console.error('💥 Error de conexión:', error.message);
  }
}

testSimple();
