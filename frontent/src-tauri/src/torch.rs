// use opencv::{
//     prelude::*,
//     videoio,
//     highgui,
//     imgproc,
// };
// use tch::{nn, Tensor, Device};

// fn main() {
//     // Inicializar la cámara
//     let mut cam = videoio::VideoCapture::new(0, videoio::CAP_ANY).unwrap();
//     let mut frame = Mat::default();

//     // Cargar el modelo YOLOv8
//     let weights = std::path::Path::new("yolov8n.pt");
//     let model = tch::CModule::load(weights).unwrap();

//     loop {
//         cam.read(&mut frame).unwrap();
//         let img = Tensor::from_slice(frame.data_bytes().unwrap()).to_device(Device::Cpu);

//         // Preprocesar la imagen
//         let img = img.unsqueeze(0).to_dtype(tch::Kind::Float, false, false);

//         // Pasar la imagen a través del modelo
//         let output = model.forward_t(&[img], false).unwrap();

//         // Procesar la salida para detectar placas
//         // Aquí debes implementar la lógica para detectar y contar las placas

//         // Mostrar el frame con las detecciones
//         highgui::imshow("YOLOv8", &frame).unwrap();
//         if highgui::wait_key(1) == Some('q' as i32) {
//             break;
//         }
//     }
// }