const fs = require('fs');
const path = require('path');

// Función para recorrer directorios de forma recursiva y filtrar archivos .dart
function readDirRecursive(dir, baseDir, fileList = []) {
  const files = fs.readdirSync(dir);

  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      // Si es un directorio, recorrerlo recursivamente
      readDirRecursive(filePath, baseDir, fileList);
    } else if (path.extname(file) === '.dart') {
      // Si es un archivo .dart, agregarlo a la lista con la ruta relativa
      const relativePath = path.relative(baseDir, filePath);
      fileList.push(relativePath);
    }
  });

  return fileList;
}

// Función para leer el contenido de los archivos y acumularlo
function accumulateContent(files, baseDir) {
  let content = '';

  files.forEach(file => {
    const filePath = path.join(baseDir, file);
    const fileContent = fs.readFileSync(filePath, 'utf8');
    content += `file: -- ${file}\n${fileContent}\n\n`;
  });

  return content;
}

function main() {
  const parentDir = './'; // Carpeta padre (actual)
  const outputFile = './content.txt'; // Archivo de salida

  // Obtener la lista de archivos .dart de forma recursiva
  const files = readDirRecursive(parentDir, parentDir);

  // Leer el contenido de los archivos y acumularlo
  const content = accumulateContent(files, parentDir);

  // Escribir el contenido en el archivo de salida
  fs.writeFileSync(outputFile, content);

  console.log(`Archivos .dart procesados: ${files.length}`);
  console.log(`Contenido acumulado: ${content.length} caracteres`);
  console.log('Archivo content.txt creado con éxito.');
}

main();