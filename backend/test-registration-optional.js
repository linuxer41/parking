// Test script para verificar el registro con ubicación y dirección opcionales
const testRegistration = async () => {
  const baseUrl = 'http://localhost:3000';
  
  // Test 1: Registro con solo dirección (sin coordenadas)
  console.log('=== Test 1: Registro con solo dirección ===');
  const test1Data = {
    user: {
      name: "Test User 1",
      email: "test1@example.com",
      password: "password123",
      phone: "1234567890"
    },
    parking: {
      name: "Estacionamiento Test 1",
      capacity: 10,
      address: "Calle Principal 123, Ciudad Test"
    }
  };
  
  try {
    const response1 = await fetch(`${baseUrl}/auth/register-complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(test1Data)
    });
    
    const result1 = await response1.json();
    console.log('Status:', response1.status);
    console.log('Result:', JSON.stringify(result1, null, 2));
  } catch (error) {
    console.error('Error en test 1:', error.message);
  }
  
  console.log('\n');
  
  // Test 2: Registro con solo coordenadas (sin dirección)
  console.log('=== Test 2: Registro con solo coordenadas ===');
  const test2Data = {
    user: {
      name: "Test User 2",
      email: "test2@example.com",
      password: "password123",
      phone: "1234567890"
    },
    parking: {
      name: "Estacionamiento Test 2",
      capacity: 15,
      location: [40.7128, -74.0060] // Nueva York
    }
  };
  
  try {
    const response2 = await fetch(`${baseUrl}/auth/register-complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(test2Data)
    });
    
    const result2 = await response2.json();
    console.log('Status:', response2.status);
    console.log('Result:', JSON.stringify(result2, null, 2));
  } catch (error) {
    console.error('Error en test 2:', error.message);
  }
  
  console.log('\n');
  
  // Test 3: Registro con dirección y coordenadas
  console.log('=== Test 3: Registro con dirección y coordenadas ===');
  const test3Data = {
    user: {
      name: "Test User 3",
      email: "test3@example.com",
      password: "password123",
      phone: "1234567890"
    },
    parking: {
      name: "Estacionamiento Test 3",
      capacity: 20,
      address: "Times Square, New York, NY",
      location: [40.7580, -73.9855]
    }
  };
  
  try {
    const response3 = await fetch(`${baseUrl}/auth/register-complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(test3Data)
    });
    
    const result3 = await response3.json();
    console.log('Status:', response3.status);
    console.log('Result:', JSON.stringify(result3, null, 2));
  } catch (error) {
    console.error('Error en test 3:', error.message);
  }
  
  console.log('\n');
  
  // Test 4: Registro sin ubicación ni dirección
  console.log('=== Test 4: Registro sin ubicación ni dirección ===');
  const test4Data = {
    user: {
      name: "Test User 4",
      email: "test4@example.com",
      password: "password123",
      phone: "1234567890"
    },
    parking: {
      name: "Estacionamiento Test 4",
      capacity: 5
    }
  };
  
  try {
    const response5 = await fetch(`${baseUrl}/auth/register-complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(test5Data)
    });
    
    const result5 = await response5.json();
    console.log('Status:', response5.status);
    console.log('Result:', JSON.stringify(result5, null, 2));
  } catch (error) {
    console.error('Error en test 5:', error.message);
  }
  
  console.log('\n');
  
  // Test 5: Registro con array vacío en ubicación
  console.log('=== Test 5: Registro con array vacío en ubicación ===');
  const test5Data = {
    user: {
      name: "Test User 5",
      email: "test5@example.com",
      password: "password123",
      phone: "1234567890"
    },
    parking: {
      name: "Estacionamiento Test 5",
      capacity: 8,
      location: []
    }
  };
  
  try {
    const response4 = await fetch(`${baseUrl}/auth/register-complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(test4Data)
    });
    
    const result4 = await response4.json();
    console.log('Status:', response4.status);
    console.log('Result:', JSON.stringify(result4, null, 2));
  } catch (error) {
    console.error('Error en test 4:', error.message);
  }
};

// Ejecutar las pruebas
testRegistration().catch(console.error);
