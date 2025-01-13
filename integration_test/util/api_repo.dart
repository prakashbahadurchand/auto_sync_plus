import 'package:auto_sync_plus/auto_sync_plus_v2_backup.dart';
import 'api_client.dart';
import 'post_dto.dart';
import 'posts_dto.dart';

class ApiRepo {
  final AutoSyncPlus autoSync = AutoSyncPlus(logging: true);

  final List<AutoSyncPlusParam> _syncTasks = [
    AutoSyncPlusParam(
      key: 'post_api_call',
      apiCall: () => _getApiClient().getFirstPost(),
      fromJson: (json) => PostDto.fromJson(json),
      toJson: (dto) => dto.toJson(),
    ),
  ];

  static ApiClient _getApiClient() => ApiClient(buildDioClient('https://jsonplaceholder.typicode.com/'));

  Stream<double> syncAllDataWithProgress() async* {
    await for (var progress in autoSync.fetchAndCacheMultipleData(params: _syncTasks)) {
      yield progress;
    }
  }

  Future<PostDto> getPost() => autoSync.fetchAndCacheData(
        key: 'get_post_api_call',
        apiCall: () => _getApiClient().getFirstPost(),
        fromJson: (json) => PostDto.fromJson(json),
        toJson: (dto) => dto.toJson(),
      );

  Future<PostsDto> getPosts() => autoSync.fetchAndCacheData(
        key: 'get_posts_api_call',
        apiCall: () => _getApiClient().getPosts(),
        fromJson: (json) => PostsDto.fromJson(json),
        toJson: (dto) => dto.toJson(),
      );
}
