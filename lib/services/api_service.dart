import 'package:dio/dio.dart';
import '../models/manga_item.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://localhost:8080';

  // Метод для получения всех манга-товаров
  Future<List<MangaItem>> fetchProducts() async {
    try {
      final response = await _dio.get('$baseUrl/mangaItems');
      if (response.statusCode == 200) {
        List<MangaItem> products = (response.data as List)
            .map((item) => MangaItem.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Метод для инициализации данных (обновление отсутствующих данных через PUT)
  Future<void> initializeData() async {
    List<MangaItem> items = await fetchProducts();
    for (var item in items) {
      if (item.format.isEmpty || item.publisher.isEmpty) {
        MangaItem updatedItem = MangaItem(
          id: item.id,
          imagePath: item.imagePath,
          title: item.title,
          description: item.description,
          price: item.price,
          additionalImages: item.additionalImages,
          format: item.format.isNotEmpty ? item.format : 'Не указан',
          publisher: item.publisher.isNotEmpty ? item.publisher : 'Не указан',
          chapters: item.chapters,
        );
        await updateProduct(updatedItem); // Обновление на сервере через PUT
      }
    }
  }

  // Метод для создания нового манга-товара
  Future<MangaItem> createProduct(MangaItem item) async {
    try {
      final response = await _dio.post(
        '$baseUrl/mangaItems',  // Используем базовый маршрут для создания
        data: item.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MangaItem.fromJson(response.data);
      } else {
        throw Exception('Failed to create product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Метод для обновления манга-товара через PUT
  Future<MangaItem> updateProduct(MangaItem item) async {
    try {
      final response = await _dio.put(
        '$baseUrl/mangaItems/${item.id}',  // Обновленный путь для PUT запроса
        data: item.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        return MangaItem.fromJson(response.data);
      } else {
        throw Exception('Failed to update product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // Метод для удаления манга-товара
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/mangaItems/$id');  // Путь для удаления продукта
      if (response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}