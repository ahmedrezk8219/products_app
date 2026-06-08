import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/product_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://fakestoreapi.com/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _dio.get('products');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'فشل في تحميل المنتجات. كود الخطأ: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;

      // تفصيل كل نوع خطأ يخرج من مكتبة Dio باللغة العربية
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'انتهى وقت الاتصال. خادم البيانات بطيء حالياً أو شبكة الإنترنت لديك ضعيفة، يرجى إعادة المحاولة.';
          break;

        case DioExceptionType.badResponse:
          errorMessage =
              'حدث خطأ من سيرفر البيانات. كود الاستجابة: ${e.response?.statusCode}';
          break;

        case DioExceptionType.connectionError:
          errorMessage =
              'فشل الاتصال بالإنترنت. يرجى التأكد من الشبكة، أو تفعيل تطبيق الـ VPN وتجربة تشغيل بيانات الهاتف (Mobile Data) لتخطي حجب السيرفر.';
          break;

        case DioExceptionType.cancel:
          errorMessage = 'تم إلغاء عملية طلب البيانات من السيرفر.';
          break;

        default:
          errorMessage =
              'يرجى تفعيل تطبيق الـ VPN أو تشغيل بيانات الهاتف (Mobile Data) لتخطي حجب السيرفر، أو التأكد من جودة اتصالك بالإنترنت.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      // خطأ عام غير متوقع (مثلاً مشكلة في الـ Parsing أو الـ Mapping)
      throw Exception(
        'حدث خطأ غير متوقع أثناء معالجة البيانات، يرجى المحاولة مرة أخرى.',
      );
    }
  }
}
