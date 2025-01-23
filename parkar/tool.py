from PIL import Image
import numpy as np
import os

def recortar_margenes_transparentes(ruta_imagen, ruta_salida):
    # Cargar la imagen con Pillow
    imagen = Image.open(ruta_imagen).convert("RGBA")

    # Convertir la imagen a un array de numpy
    imagen_np = np.array(imagen)

    # Obtener el canal alfa (transparencia)
    canal_alfa = imagen_np[:, :, 3]

    # Encontrar los límites del contenido no transparente
    filas_con_contenido = np.where(np.max(canal_alfa, axis=1) > 0)[0]
    columnas_con_contenido = np.where(np.max(canal_alfa, axis=0) > 0)[0]

    if len(filas_con_contenido) == 0 or len(columnas_con_contenido) == 0:
        print(f"La imagen {ruta_imagen} está completamente transparente. No se recortará.")
        return

    # Obtener los límites del contenido
    y1, y2 = filas_con_contenido[0], filas_con_contenido[-1]
    x1, x2 = columnas_con_contenido[0], columnas_con_contenido[-1]

    # Recortar la imagen usando los límites encontrados
    imagen_recortada = imagen_np[y1:y2+1, x1:x2+1]

    # Guardar la imagen recortada
    imagen_recortada_pil = Image.fromarray(imagen_recortada)
    imagen_recortada_pil.save(ruta_salida, "PNG")

def procesar_carpeta(carpeta_entrada, carpeta_salida):
    # Crear la carpeta de salida si no existe
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    # Procesar todas las imágenes en la carpeta de entrada
    for archivo in os.listdir(carpeta_entrada):
        if archivo.lower().endswith(".png"):
            ruta_imagen = os.path.join(carpeta_entrada, archivo)
            ruta_salida = os.path.join(carpeta_salida, archivo)
            recortar_margenes_transparentes(ruta_imagen, ruta_salida)
            print(f"Imagen recortada: {archivo}")

# Rutas de las carpetas
carpeta_entrada = "images"  # Carpeta donde están las imágenes originales
carpeta_salida = "images_recortadas"  # Carpeta donde se guardarán las imágenes recortadas

# Procesar todas las imágenes en la carpeta
procesar_carpeta(carpeta_entrada, carpeta_salida)