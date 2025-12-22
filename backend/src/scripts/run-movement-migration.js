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
    const migrationPath = join(process.cwd(), 'src', 'migrations', 'add-movement-origin-columns.sql');
    const migrationSQL = readFileSync(migrationPath, 'utf8');

    console.log('📝 Ejecutando migración...');
    console.log('   Agregando columnas originId, originType y actualizando type en t_movement...');

    await client.query(migrationSQL);

    console.log('✅ Migración completada exitosamente');
    console.log('   Se agregó la columna originId a t_movement');
    console.log('   Se agregó la columna originType a t_movement');
    console.log('   Se actualizó la restricción de type para usar income|expense');
    console.log('   Se agregó la restricción de originType para usar access|booking|subscription');

  } catch (error) {
    console.error('❌ Error durante la migración:', error);
    process.exit(1);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

runMigration();