import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/product_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://fakestoreapi.com/', // رجعنا للرابط القديم
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _dio.get('products'); // طلب المنتجات من السيرفر القديم

      if (response.statusCode == 200) {
        List<dynamic> data = response.data; // هنا بنستقبل الـ List مباشرة بدون كلمة ['products']
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل في تحميل المنتجات: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهى وقت الاتصال (Timeout).');
      } else {
        throw Exception('مشكلة في الاتصال بالشبكة: ${e.message} (تأكد من تشغيل الـ VPN)');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}