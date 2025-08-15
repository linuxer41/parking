// Test simple para verificar que el registro funciona sin errores de ID
const testSimpleRegistration = async () => {
  const baseUrl = 'http://localhost:3000';
  
  console.log('=== Test de Registro Simple ===');
  const testData = {
    user: {
      name: "Usuario Test",
      email: "test@example.com",
      password: "password123",
      phone: "1234567890"
    },
    parking: {
      name: "Estacionamiento Test",
      capacity: 5
    }
  };
  
  try {
    console.log('Enviando datos de registro...');
    const response = await fetch(`${baseUrl}/auth/register-complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(testData)
    });
    
    console.log('Status:', response.status);
    const result = await response.json();
    console.log('Resultado:', JSON.stringify(result, null, 2));
    
    if (response.ok) {
      console.log('✅ Registro exitoso!');
    } else {
      console.log('❌ Error en el registro');
    }
  } catch (error) {
    console.error('❌ Error de conexión:', error.message);
  }
};

// Ejecutar la prueba
testSimpleRegistration().catch(console.error);
