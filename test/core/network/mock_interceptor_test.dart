import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:walk/core/network/interceptors/mock_interceptor.dart';
import 'package:walk/core/config/app_config.dart';

void main() {
  setUpAll(() {
    // 初始化AppConfig（启用Mock模式）
    AppConfig.instance.initialize(useMockServices: true);
  });

  group('MockInterceptor Tests', () {
    late Dio dio;
    late MockInterceptor mockInterceptor;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8080'));
      mockInterceptor = MockInterceptor();
      dio.interceptors.add(mockInterceptor);
    });

    test('Mock用户信息API应返回mock数据', () async {
      final response = await dio.get('/walkbg/api/v1/user/profile');

      expect(response.statusCode, 200);
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['code'], 200);
      expect(response.data['message'], 'success');
      expect(response.data['data'], isNotNull);
      expect(response.data['data']['id'], 'mock_user_001');
      expect(response.data['data']['username'], 'hiker_zhang');
    });

    test('Mock天气信息API应返回mock数据', () async {
      final response = await dio.get('/walkbg/api/v1/weather');

      expect(response.statusCode, 200);
      expect(response.data['code'], 200);
      expect(response.data['data']['city'], '北京');
      expect(response.data['data']['condition'], '晴朗');
      expect(response.data['data']['temperature'], isA<double>());
    });

    test('Mock规划行程API应返回mock数据', () async {
      final response = await dio.get('/walkbg/api/v1/trips/planned');

      expect(response.statusCode, 200);
      expect(response.data['code'], 200);
      expect(response.data['data']['content'], isA<List>());
      expect(response.data['data']['content'].length, 2);
      expect(response.data['data']['page'], 0);
      expect(response.data['data']['total_elements'], 2);
    });

    test('Mock推荐路线API应返回mock数据', () async {
      final response = await dio.get('/walkbg/api/v1/routes');

      expect(response.statusCode, 200);
      expect(response.data['code'], 200);
      expect(response.data['data']['content'], isA<List>());
      expect(response.data['data']['content'].length, 3);
      expect(response.data['data']['content'][0]['name'], '鳌太穿越');
    });

    test('Mock徒步攻略API应返回mock数据', () async {
      final response = await dio.get('/walkbg/api/v1/guides');

      expect(response.statusCode, 200);
      expect(response.data['code'], 200);
      expect(response.data['data']['content'], isA<List>());
      expect(response.data['data']['content'].length, 4);
      expect(response.data['data']['content'][0]['title'], contains('鳌太穿越'));
    });

    test('未匹配的API应正常发送（会失败因为没有后端）', () async {
      // 对于未匹配的Mock端点，应该尝试请求真实API
      // 但因为没有后端，所以会失败
      expect(
        () async => await dio.get('/walkbg/api/v1/unknown-endpoint'),
        throwsA(isA<DioException>()),
      );
    });

    test('Mock数据包含合理的延迟', () async {
      final stopwatch = Stopwatch()..start();
      await dio.get('/walkbg/api/v1/user/profile');
      stopwatch.stop();

      // 验证延迟在200-500ms之间
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(200));
      expect(stopwatch.elapsedMilliseconds, lessThan(600)); // 留一点余地
    });
  });
}
