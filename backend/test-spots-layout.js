// Test para verificar que los spots se crean con separación y layout cuadrado
const testSpotsLayout = async () => {
  const baseUrl = 'http://localhost:3000';
  
  console.log('=== Test de Layout de Spots ===');
  
  // Test con diferentes capacidades para verificar el layout
  const testCases = [
    { capacity: 4, description: "4 spots (2x2)" },
    { capacity: 9, description: "9 spots (3x3)" },
    { capacity: 16, description: "16 spots (4x4)" },
    { capacity: 25, description: "25 spots (5x5)" },
    { capacity: 10, description: "10 spots (4x3)" },
  ];
  
  for (const testCase of testCases) {
    console.log(`\n--- ${testCase.description} ---`);
    
    const testData = {
      user: {
        name: `Usuario Test ${testCase.capacity}`,
        email: `test${testCase.capacity}@example.com`,
        password: "password123",
        phone: "1234567890"
      },
      parking: {
        name: `Estacionamiento Test ${testCase.capacity}`,
        capacity: testCase.capacity
      }
    };
    
    try {
      const response = await fetch(`${baseUrl}/auth/register-complete`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(testData)
      });
      
      if (response.ok) {
        const result = await response.json();
        console.log(`✅ Registro exitoso para ${testCase.capacity} spots`);
        console.log(`   - Usuario creado: ${result.user.name}`);
        console.log(`   - Parking creado: ${result.parking.name}`);
        console.log(`   - Área creada: ${result.area.name}`);
        console.log(`   - Spots creados: ${result.spots.length}`);
        
        // Mostrar información de los primeros 3 spots para verificar posiciones
        console.log('   - Posiciones de los primeros spots:');
        result.spots.slice(0, 3).forEach((spot, index) => {
          console.log(`     Spot ${spot.name}: posX=${spot.posX}, posY=${spot.posY}, tipo=${spot.type}, subTipo=${spot.subType}`);
        });
        
        if (result.spots.length > 3) {
          console.log(`     ... y ${result.spots.length - 3} spots más`);
        }
      } else {
        const error = await response.json();
        console.log(`❌ Error en el registro: ${error.message || response.statusText}`);
      }
    } catch (error) {
      console.error(`❌ Error de conexión: ${error.message}`);
    }
  }
};

// Ejecutar las pruebas
testSpotsLayout().catch(console.error);
