import { Client } from 'pg';
import { readFileSync } from 'fs';
import { join } from 'path';

const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:anarkia41@localhost:5432/parking';

async function runMigration() {
  const client = new Client({
    connectionString: DATABASE_URL,
  });

  try {
    console.log('🔗 Conectando a la base de datos...');
    await client.connect();
    console.log('✅ Conexión exitosa');

    // Leer el archivo de migración
    const migrationPath = join(process.cwd(), 'src', 'migrations', 'remove-capacity-column.sql');
    const migrationSQL = readFileSync(migrationPath, 'utf8');

    console.log('📝 Ejecutando migración...');
    console.log('   Eliminando columna capacity de t_parking...');
    
    await client.query(migrationSQL);
    
    console.log('✅ Migración completada exitosamente');
    console.log('   La columna capacity ha sido eliminada de la tabla t_parking');
    console.log('   La capacidad ahora es infinita por defecto');

  } catch (error) {
    console.error('❌ Error durante la migración:', error);
    process.exit(1);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

runMigration();
