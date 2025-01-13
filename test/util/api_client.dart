import 'package:dio/dio.dart';
import 'post_dto.dart';
import 'posts_dto.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<PostDto> getFirstPost() async {
    final response =
        await _dio.get('https://jsonplaceholder.typicode.com/posts/1');
    return PostDto.fromJson(response.data);
  }

  Future<PostsDto> getPosts() async {
    final response =
        await _dio.get('https://jsonplaceholder.typicode.com/posts');
    return PostsDto.fromJson(response.data);
  }
}

Dio buildDioClient(String baseUrl) {
  return Dio(BaseOptions(baseUrl: baseUrl));
}
