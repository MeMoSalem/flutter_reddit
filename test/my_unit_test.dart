
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_reddit/provider/dataProvider.dart';


main() {
  group('fetchPosts', () {
    test('stage equals PostLoadingStage.DONE & completes successfully', () async {

      var loadPost = DataProvider();
      await loadPost.fetchPosts();
      expect(loadPost.stage, equals(PostLoadingStage.DONE));
    });

    test('if the stage equals PostLoadingStage.ERROR', () async{
      var loadPost = DataProvider();
      await loadPost.fetchPosts();
      expect(loadPost.stage, equals(PostLoadingStage.ERROR));
    });

  });
}
