import 'package:test/test.dart';
import 'package:rmotly_server/src/services/rate_limit_service.dart';

void main() {
  group('RateLimitService', () {
    late RateLimitService service;

    setUp(() {
      service = RateLimitService(
        const RateLimitConfig(
          maxRequests: 5,
          window: Duration(seconds: 1),
        ),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('allows requests within limit', () {
      for (var i = 0; i < 5; i++) {
        expect(service.isRateLimited('user-1'), isFalse);
      }
    });

    test('blocks requests exceeding limit', () {
      // Use up the limit
      for (var i = 0; i < 5; i++) {
        service.isRateLimited('user-1');
      }

      // Next request should be blocked
      expect(service.isRateLimited('user-1'), isTrue);
    });

    test('tracks different keys separately', () {
      // User 1 uses their limit
      for (var i = 0; i < 5; i++) {
        service.isRateLimited('user-1');
      }

      // User 2 should still be able to make requests
      expect(service.isRateLimited('user-2'), isFalse);
    });

    test('resets after time window', () async {
      // Use up the limit
      for (var i = 0; i < 5; i++) {
        service.isRateLimited('user-1');
      }

      // Should be blocked
      expect(service.isRateLimited('user-1'), isTrue);

      // Wait for window to expire
      await Future.delayed(const Duration(seconds: 2));

      // Should be allowed again
      expect(service.isRateLimited('user-1'), isFalse);
    });

    test('checkRateLimit does not count towards limit', () {
      // Check limit 10 times
      for (var i = 0; i < 10; i++) {
        expect(service.checkRateLimit('user-1'), isFalse);
      }

      // Should still have full quota
      expect(service.getRemainingRequests('user-1'), equals(5));
    });

    test('getRemainingRequests returns correct count', () {
      expect(service.getRemainingRequests('user-1'), equals(5));

      service.isRateLimited('user-1');
      expect(service.getRemainingRequests('user-1'), equals(4));

      service.isRateLimited('user-1');
      service.isRateLimited('user-1');
      expect(service.getRemainingRequests('user-1'), equals(2));
    });

    test('getResetTime returns null when not rate limited', () {
      expect(service.getResetTime('user-1'), isNull);
    });

    test('getResetTime returns duration when rate limited', () {
      // Use up the limit
      for (var i = 0; i < 5; i++) {
        service.isRateLimited('user-1');
      }

      final resetTime = service.getResetTime('user-1');
      expect(resetTime, isNotNull);
      expect(resetTime!.inMilliseconds, greaterThanOrEqualTo(0));
      expect(resetTime.inSeconds, lessThanOrEqualTo(1));
    });

    test('getRateLimitInfo returns correct information', () {
      service.isRateLimited('user-1');
      service.isRateLimited('user-1');

      final info = service.getRateLimitInfo('user-1');

      expect(info['limit'], equals(5));
      expect(info['remaining'], equals(3));
    });

    test('reset clears rate limit for key', () {
      // Use up the limit
      for (var i = 0; i < 5; i++) {
        service.isRateLimited('user-1');
      }

      expect(service.isRateLimited('user-1'), isTrue);

      // Reset
      service.reset('user-1');

      // Should be allowed again
      expect(service.isRateLimited('user-1'), isFalse);
    });

    test('resetAll clears all rate limits', () {
      // Use up limits for multiple keys
      for (var i = 0; i < 5; i++) {
        service.isRateLimited('user-1');
        service.isRateLimited('user-2');
      }

      expect(service.isRateLimited('user-1'), isTrue);
      expect(service.isRateLimited('user-2'), isTrue);

      // Reset all
      service.resetAll();

      // Both should be allowed again
      expect(service.isRateLimited('user-1'), isFalse);
      expect(service.isRateLimited('user-2'), isFalse);
    });

    test('sliding window allows new requests as old ones expire', () async {
      // Make 3 requests
      for (var i = 0; i < 3; i++) {
        service.isRateLimited('user-1');
      }

      // Wait for 0.5 seconds
      await Future.delayed(const Duration(milliseconds: 500));

      // Make 2 more requests (should be at limit: 5)
      for (var i = 0; i < 2; i++) {
        expect(service.isRateLimited('user-1'), isFalse);
      }

      // Should be at limit now
      expect(service.isRateLimited('user-1'), isTrue);

      // Wait for first requests to expire (another 0.6 seconds)
      await Future.delayed(const Duration(milliseconds: 600));

      // First 3 requests should have expired, allowing 3 more
      expect(service.getRemainingRequests('user-1'), equals(3));
    });
  });

  group('RateLimitConfig', () {
    test('webhook config has correct defaults', () {
      expect(RateLimitConfig.webhook.maxRequests, equals(100));
      expect(RateLimitConfig.webhook.window, equals(const Duration(minutes: 1)));
    });

    test('userEvents config has correct defaults', () {
      expect(RateLimitConfig.userEvents.maxRequests, equals(1000));
      expect(RateLimitConfig.userEvents.window, equals(const Duration(minutes: 1)));
    });

    test('openApi config has correct defaults', () {
      expect(RateLimitConfig.openApi.maxRequests, equals(10));
      expect(RateLimitConfig.openApi.window, equals(const Duration(minutes: 1)));
    });

    test('auth config has correct defaults', () {
      expect(RateLimitConfig.auth.maxRequests, equals(5));
      expect(RateLimitConfig.auth.window, equals(const Duration(minutes: 1)));
    });
  });
}
