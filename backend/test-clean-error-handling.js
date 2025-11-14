const API_BASE = "http://localhost:3002";

async function testCleanErrorHandling() {
  console.log("🧪 Probando manejo de errores limpio...\n");

  // Test 1: Registro con email duplicado
  console.log("📝 Test 1: Registro con email duplicado");
  const testData1 = {
    user: {
      name: "Test User Clean",
      email: "test.clean@example.com",
      password: "password123",
      phone: "1234567890"
    },
    parking: {
      name: "Parking Clean"
    }
  };

  try {
    // Primer registro (debe funcionar)
    const response1 = await fetch(`${API_BASE}/auth/register-complete`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(testData1),
    });

    if (response1.ok) {
      console.log("✅ Primer registro exitoso");
    }

    // Segundo registro con el mismo email (debe fallar)
    const response2 = await fetch(`${API_BASE}/auth/register-complete`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(testData1),
    });

    const errorResult = await response2.json();
    console.log("✅ Error capturado correctamente:");
    console.log("   Status:", response2.status);
    console.log("   Error:", errorResult);
    console.log("");

  } catch (error) {
    console.error("❌ Error en test 1:", error);
  }

  // Test 2: Login con credenciales incorrectas
  console.log("📝 Test 2: Login con credenciales incorrectas");
  try {
    const loginData = {
      email: "nonexistent@example.com",
      password: "wrongpassword"
    };

    const response = await fetch(`${API_BASE}/auth/sign-in`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(loginData),
    });

    const errorResult = await response.json();
    console.log("✅ Error de autenticación capturado:");
    console.log("   Status:", response.status);
    console.log("   Error:", errorResult);
    console.log("");

  } catch (error) {
    console.error("❌ Error en test 2:", error);
  }

  // Test 3: Acceder a endpoint protegido sin token
  console.log("📝 Test 3: Acceso sin autenticación");
  try {
    const response = await fetch(`${API_BASE}/auth/me`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    const errorResult = await response.json();
    console.log("✅ Error de autorización capturado:");
    console.log("   Status:", response.status);
    console.log("   Error:", errorResult);
    console.log("");

  } catch (error) {
    console.error("❌ Error en test 3:", error);
  }

  // Test 4: Obtener parking que no existe
  console.log("📝 Test 4: Obtener parking inexistente");
  try {
    // Primero crear un usuario y obtener token
    const registerData = {
      user: {
        name: "Test User Clean Error",
        email: `test.clean.error.${Date.now()}@example.com`,
        password: "password123",
        phone: "1234567890"
      },
      parking: {
        name: "Parking Clean Error Test"
      }
    };

    const registerResponse = await fetch(`${API_BASE}/auth/register-complete`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(registerData),
    });

    const registerResult = await registerResponse.json();
    const authToken = registerResult.token;

    // Intentar obtener un parking que no existe
    const response = await fetch(`${API_BASE}/parkings/nonexistent-id`, {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${authToken}`,
        "Content-Type": "application/json",
      },
    });

    const errorResult = await response.json();
    console.log("✅ Error de recurso no encontrado capturado:");
    console.log("   Status:", response.status);
    console.log("   Error:", errorResult);
    console.log("");

  } catch (error) {
    console.error("❌ Error en test 4:", error);
  }

  // Test 5: Registro exitoso con location
  console.log("📝 Test 5: Registro exitoso con location");
  try {
    const testData2 = {
      user: {
        name: "Test User Location",
        email: `test.location.${Date.now()}@example.com`,
        password: "password123",
        phone: "1234567890"
      },
      parking: {
        name: "Parking con Location",
        location: {
          lat: 40.7128,
          lng: -74.0060
        },
        address: "123 Test Street"
      }
    };

    const response = await fetch(`${API_BASE}/auth/register-complete`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(testData2),
    });

    const result = await response.json();
    console.log("✅ Registro exitoso con location:");
    console.log("   Status:", response.status);
    console.log("   Location:", result.parking.location);
    console.log("   Address:", result.parking.address);
    console.log("");

  } catch (error) {
    console.error("❌ Error en test 5:", error);
  }

  console.log("🎉 Todos los tests de manejo de errores limpio completados!");
}

// Ejecutar los tests
testCleanErrorHandling();
