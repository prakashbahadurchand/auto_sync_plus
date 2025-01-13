import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import './util/api_repo.dart';
import './util/post_dto.dart';
import './util/posts_dto.dart';

@GenerateMocks([DefaultCacheManager, ApiRepo, Connectivity])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ApiRepo', () {
    late ApiRepo apiRepo;

    setUp(() {
      apiRepo = ApiRepo();
    });

    testWidgets('syncAllDataWithProgress emits progress', (WidgetTester tester) async {
      when(apiRepo.getPosts()).thenAnswer((_) async => PostsDto(posts: [PostDto(id: 1, title: 'Test Post', body: 'This is a test post')]));

      final stream = apiRepo.syncAllDataWithProgress();
      final progress = await stream.toList();

      expect(progress, isNotEmpty);
      expect(progress.last, 1.0);
    });

    testWidgets('getPosts fetches and caches data', (WidgetTester tester) async {
      final postsDto = PostsDto(posts: [PostDto(id: 1, title: 'Test Post', body: 'This is a test post')]);

      when(apiRepo.getPosts()).thenAnswer((_) async => postsDto);

      final result = await apiRepo.getPosts();

      expect(result, postsDto);
    });
  });
}