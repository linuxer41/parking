// Test simple para el nuevo esquema simplificado
const API_BASE_URL = 'http://localhost:3002';

async function simpleTest() {
  console.log('🔍 Iniciando test simple con nuevo esquema...');
  
  try {
    const response = await fetch(`${API_BASE_URL}/auth/register-complete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
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
      }),
    });
    
    console.log('Status:', response.status);
    
    const text = await response.text();
    console.log('Response text:', text);
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

simpleTest();
