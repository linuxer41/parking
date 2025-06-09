import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/_base_model.dart';
import '../state/app_state.dart';
import 'service_locator.dart'; // Importa el ServiceLocator

typedef FromJsonFactory<T> = T Function(Map<String, dynamic> json);

class BaseService<
    Model extends JsonConvertible<Model>,
    CreateModel extends JsonConvertible<CreateModel>,
    UpdateModel extends JsonConvertible<UpdateModel>> {
  final http.Client httpClient = http.Client();
  final String baseUrl = 'http://192.168.1.10:3001';
  final String path; // Definir el path como propiedad de la clase
  final FromJsonFactory<Model> fromJsonFactory; // Función factory para Model

  BaseService({
    required this.path,
    required this.fromJsonFactory, // Recibir la función factory
  });

  // Obtener el AppState desde el ServiceLocator
  AppState get _state => ServiceLocator().getAppState();

  // Obtener un elemento por ID
  Future<Model> get(String id) async {
    final uri =
        Uri.parse('$baseUrl$path/$id'); // Usar el path de la clase y el ID
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final data = jsonDecode(response.body);
    return fromJsonFactory(data);
  }

  // Crear un nuevo elemento
  Future<Model> create(CreateModel createModel) async {
    final uri = Uri.parse('$baseUrl$path'); // Usar el path de la clase
    final response = await http.post(
      uri,
      headers: buildHeaders(),
      body: jsonEncode(createModel.toJson()), // Convertir CreateModel a JSON
    );
    handleResponse(response);
    final data = jsonDecode(response.body);
    return fromJsonFactory(data);
  }

  // Actualizar un elemento existente
  Future<Model> update(String id, UpdateModel updateModel) async {
    final uri =
        Uri.parse('$baseUrl$path/$id'); // Usar el path de la clase y el ID
    final response = await http.patch(
      uri,
      headers: buildHeaders(),
      body: jsonEncode(
          removeNulls(updateModel.toJson())), // Convertir UpdateModel a JSON
    );
    handleResponse(response);
    final data = jsonDecode(response.body);
    return fromJsonFactory(data);
  }

  // Eliminar un elemento por ID
  Future<void> delete(String id) async {
    final uri =
        Uri.parse('$baseUrl$path/$id'); // Usar el path de la clase y el ID
    final response = await http.delete(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
  }

  // Listar elementos con filtros
  Future<List<Model>> list({Map<String, dynamic>? filters}) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: filters, // Añadir filtros como parámetros de consulta
    );
    final response = await http.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => fromJsonFactory(item)).toList();
  }

  // Construir encabezados
  Map<String, String> buildHeaders() {
    print({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_state.authToken}',
      'branch-id': '${_state.branchId}',
    });
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_state.authToken}',
      'Access-Code': '${_state.employee?.id}:${_state.currentParking?.id}',
    };
  }

  // Manejar la respuesta
  void handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Map<String, dynamic> removeNulls(Map<String, dynamic> map) {
    // Crear un nuevo mapa para almacenar los valores no nulos
    Map<String, dynamic> result = {};

    map.forEach((key, value) {
      if (value != null) {
        // Si el valor es un mapa, aplicar recursividad
        if (value is Map<String, dynamic>) {
          result[key] = removeNulls(value);
        }
        // Si el valor es una lista, procesar sus elementos
        else if (value is List) {
          result[key] = value.map((item) {
            if (item is Map<String, dynamic>) {
              return removeNulls(item);
            }
            return item;
          }).toList();
        }
        // Si no es nulo, ni mapa ni lista, agregarlo directamente
        else {
          result[key] = value;
        }
      }
    });

    return result;
  }
}
