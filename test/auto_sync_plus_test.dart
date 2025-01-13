import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'auto_sync_plus_test.mocks.dart';
import 'util/api_repo.dart';
import 'util/post_dto.dart';
import 'util/posts_dto.dart';

@GenerateMocks([DefaultCacheManager, ApiRepo])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiRepo', () {
    late ApiRepo apiRepo;
    late MockApiRepo mockApiRepo;

    setUp(() {
      apiRepo = ApiRepo();
      mockApiRepo = MockApiRepo();
    });

    test('syncAllDataWithProgress emits progress', () async {
      when(mockApiRepo.getPost()).thenAnswer((_) async => PostDto(id: 1, title: 'Test Post', body: 'This is a test post'));

      final stream = apiRepo.syncAllDataWithProgress();
      final progress = await stream.toList();

      expect(progress, isNotEmpty);
      expect(progress.last, 1.0);
    });

    test('getDataFromFirstApiCall fetches and caches data', () async {
      final postsDto = PostsDto(posts: [PostDto(id: 1, title: 'Test Post', body: 'This is a test post')]);

      when(mockApiRepo.getPosts()).thenAnswer((_) async => postsDto);

      final result = await apiRepo.getPosts();

      expect(result, postsDto);
    });
  });
}
