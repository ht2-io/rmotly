import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/shared/services/auth_service.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

// Mock classes
class MockSessionManager extends Mock implements SessionManager {}

class MockCaller extends Mock implements Caller {}

class MockModules extends Mock implements Modules {}

class MockAuth extends Mock implements Auth {}

class MockEmailAuth extends Mock implements EmailAuth {}

class MockUserInfo extends Mock implements UserInfo {}

class FakeAuthenticationResponse extends Fake implements AuthenticationResponse {
  @override
  final bool success;
  @override
  final UserInfo? userInfo;
  @override
  final String? keyId;
  @override
  final String? key;
  @override
  final UserInfoFailReason? failReason;

  FakeAuthenticationResponse({
    required this.success,
    this.userInfo,
    this.keyId,
    this.key,
    this.failReason,
  });
}

void main() {
  late MockSessionManager mockSessionManager;
  late MockCaller mockCaller;
  late MockModules mockModules;
  late MockAuth mockAuth;
  late MockEmailAuth mockEmailAuth;
  late AuthService authService;

  setUp(() {
    mockSessionManager = MockSessionManager();
    mockCaller = MockCaller();
    mockModules = MockModules();
    mockAuth = MockAuth();
    mockEmailAuth = MockEmailAuth();

    // Set up mock chain
    when(() => mockSessionManager.caller).thenReturn(mockCaller);
    when(() => mockCaller.modules).thenReturn(mockModules);
    when(() => mockModules.auth).thenReturn(mockAuth);
    when(() => mockAuth.email).thenReturn(mockEmailAuth);
    when(() => mockSessionManager.initialize()).thenAnswer((_) async => {});
    when(() => mockSessionManager.signedInUser).thenReturn(null);

    authService = AuthService(mockSessionManager);
  });

  group('AuthService', () {
    group('initialization', () {
      test('should initialize with no user when session is empty', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(authService.state.isAuthenticated, false);
        expect(authService.state.userInfo, isNull);
        expect(authService.state.isLoading, false);
        verify(() => mockSessionManager.initialize()).called(1);
      });

      test('should initialize with user when session exists', () async {
        // Arrange
        final mockUserInfo = MockUserInfo();
        when(() => mockUserInfo.id).thenReturn(123);
        when(() => mockSessionManager.signedInUser).thenReturn(mockUserInfo);

        // Act
        final service = AuthService(mockSessionManager);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(service.state.isAuthenticated, true);
        expect(service.state.userInfo, isNotNull);
      });

      test('should handle initialization error', () async {
        // Arrange
        when(() => mockSessionManager.initialize())
            .thenThrow(Exception('Init failed'));

        // Act
        final service = AuthService(mockSessionManager);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(service.state.error, isNotNull);
        expect(service.state.error, contains('Failed to initialize'));
      });
    });

    group('signInWithEmail', () {
      test('should sign in successfully with valid credentials', () async {
        // Arrange
        final mockUserInfo = MockUserInfo();
        when(() => mockUserInfo.id).thenReturn(123);

        final response = FakeAuthenticationResponse(
          success: true,
          userInfo: mockUserInfo,
          keyId: 'key-id',
          key: 'secret-key',
        );

        when(() => mockEmailAuth.authenticate(any(), any()))
            .thenAnswer((_) async => response);
        when(() => mockSessionManager.registerSignedInUser(any(), any(), any()))
            .thenAnswer((_) async => {});

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.signInWithEmail(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, true);
        expect(authService.state.isAuthenticated, true);
        expect(authService.state.userInfo, isNotNull);
        expect(authService.state.error, isNull);
        verify(() => mockEmailAuth.authenticate('test@example.com', 'password123'))
            .called(1);
        verify(() => mockSessionManager.registerSignedInUser(
              mockUserInfo,
              'key-id',
              'secret-key',
            )).called(1);
      });

      test('should fail with invalid credentials', () async {
        // Arrange
        final response = FakeAuthenticationResponse(
          success: false,
          failReason: UserInfoFailReason.wrongPassword,
        );

        when(() => mockEmailAuth.authenticate(any(), any()))
            .thenAnswer((_) async => response);

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.signInWithEmail(
          'test@example.com',
          'wrongpassword',
        );

        // Assert
        expect(result, false);
        expect(authService.state.isAuthenticated, false);
        expect(authService.state.error, isNotNull);
        expect(authService.state.error, contains('wrongPassword'));
      });

      test('should handle network errors', () async {
        // Arrange
        when(() => mockEmailAuth.authenticate(any(), any()))
            .thenThrow(Exception('Network error'));

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.signInWithEmail(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, false);
        expect(authService.state.error, isNotNull);
        expect(authService.state.error, contains('Sign in failed'));
      });
    });

    group('createAccount', () {
      test('should create account successfully', () async {
        // Arrange
        final response = FakeAuthenticationResponse(success: true);

        when(() => mockEmailAuth.createAccountRequest(any(), any(), any()))
            .thenAnswer((_) async => response);

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.createAccount(
          'test@example.com',
          'password123',
          userName: 'testuser',
        );

        // Assert
        expect(result, true);
        expect(authService.state.error, isNull);
        verify(() => mockEmailAuth.createAccountRequest(
              'testuser',
              'test@example.com',
              'password123',
            )).called(1);
      });

      test('should use email as username when not provided', () async {
        // Arrange
        final response = FakeAuthenticationResponse(success: true);

        when(() => mockEmailAuth.createAccountRequest(any(), any(), any()))
            .thenAnswer((_) async => response);

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.createAccount(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, true);
        verify(() => mockEmailAuth.createAccountRequest(
              'test@example.com',
              'test@example.com',
              'password123',
            )).called(1);
      });

      test('should fail when account creation fails', () async {
        // Arrange
        final response = FakeAuthenticationResponse(
          success: false,
          failReason: UserInfoFailReason.emailAlreadyInUse,
        );

        when(() => mockEmailAuth.createAccountRequest(any(), any(), any()))
            .thenAnswer((_) async => response);

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.createAccount(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, false);
        expect(authService.state.error, isNotNull);
        expect(authService.state.error, contains('emailAlreadyInUse'));
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(() => mockSessionManager.signOutDevice())
            .thenAnswer((_) async => {});

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        await authService.signOut();

        // Assert
        expect(authService.state.isAuthenticated, false);
        expect(authService.state.userInfo, isNull);
        verify(() => mockSessionManager.signOutDevice()).called(1);
      });

      test('should handle sign out errors gracefully', () async {
        // Arrange
        when(() => mockSessionManager.signOutDevice())
            .thenThrow(Exception('Sign out failed'));

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        await authService.signOut();

        // Assert
        expect(authService.state.error, isNotNull);
        expect(authService.state.error, contains('Sign out failed'));
      });
    });

    group('properties', () {
      test('userId should return user ID when authenticated', () async {
        // Arrange
        final mockUserInfo = MockUserInfo();
        when(() => mockUserInfo.id).thenReturn(123);
        when(() => mockSessionManager.signedInUser).thenReturn(mockUserInfo);

        // Act
        final service = AuthService(mockSessionManager);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(service.userId, 123);
      });

      test('userId should return null when not authenticated', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(authService.userId, isNull);
      });

      test('isAuthenticated should reflect auth state', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(authService.isAuthenticated, false);
      });
    });
  });
}
