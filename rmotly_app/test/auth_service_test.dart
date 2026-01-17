import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/shared/services/auth_service.dart';
import 'package:rmotly_client/rmotly_client.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as auth;
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

// Mock classes
class MockSessionManager extends Mock implements SessionManager {}

class MockClient extends Mock implements Client {}

class MockModules extends Mock implements Modules {}

class MockAuthCaller extends Mock implements auth.Caller {}

class MockEndpointEmail extends Mock implements auth.EndpointEmail {}

class MockUserInfo extends Mock implements auth.UserInfo {}

void main() {
  late MockSessionManager mockSessionManager;
  late MockClient mockClient;
  late MockModules mockModules;
  late MockAuthCaller mockAuthCaller;
  late MockEndpointEmail mockEmailAuth;
  late AuthService authService;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(MockUserInfo());
  });

  setUp(() {
    mockSessionManager = MockSessionManager();
    mockClient = MockClient();
    mockModules = MockModules();
    mockAuthCaller = MockAuthCaller();
    mockEmailAuth = MockEndpointEmail();

    // Set up mock chain: client.modules.auth.email
    when(() => mockClient.modules).thenReturn(mockModules);
    when(() => mockModules.auth).thenReturn(mockAuthCaller);
    when(() => mockAuthCaller.email).thenReturn(mockEmailAuth);

    // Default SessionManager behavior
    when(() => mockSessionManager.initialize()).thenAnswer((_) async => true);
    when(() => mockSessionManager.signedInUser).thenReturn(null);

    authService = AuthService(mockSessionManager, mockClient);
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
        final service = AuthService(mockSessionManager, mockClient);
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
        final service = AuthService(mockSessionManager, mockClient);
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

        final response = auth.AuthenticationResponse(
          success: true,
          userInfo: mockUserInfo,
          keyId: 1,
          key: 'secret-key',
        );

        when(() => mockEmailAuth.authenticate(any(), any()))
            .thenAnswer((_) async => response);
        when(() => mockSessionManager.registerSignedInUser(any(), any(), any()))
            .thenAnswer((_) async {});

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
              any(),
              1,
              'secret-key',
            )).called(1);
      });

      test('should fail with invalid credentials', () async {
        // Arrange
        final response = auth.AuthenticationResponse(
          success: false,
          failReason: auth.AuthenticationFailReason.invalidCredentials,
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
        when(() => mockEmailAuth.createAccountRequest(any(), any(), any()))
            .thenAnswer((_) async => true);

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
        when(() => mockEmailAuth.createAccountRequest(any(), any(), any()))
            .thenAnswer((_) async => true);

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
        when(() => mockEmailAuth.createAccountRequest(any(), any(), any()))
            .thenAnswer((_) async => false);

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
        expect(authService.state.error, contains('Account creation failed'));
      });
    });

    group('verifyEmail', () {
      test('should verify email successfully', () async {
        // Arrange
        final mockUserInfo = MockUserInfo();
        when(() => mockEmailAuth.createAccount(any(), any()))
            .thenAnswer((_) async => mockUserInfo);

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.verifyEmail(
          'test@example.com',
          '123456',
        );

        // Assert
        expect(result, true);
        verify(() => mockEmailAuth.createAccount('test@example.com', '123456'))
            .called(1);
      });

      test('should fail when verification fails', () async {
        // Arrange
        when(() => mockEmailAuth.createAccount(any(), any()))
            .thenAnswer((_) async => null);

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        final result = await authService.verifyEmail(
          'test@example.com',
          '123456',
        );

        // Assert
        expect(result, false);
        expect(authService.state.error, isNotNull);
        expect(authService.state.error, contains('Verification failed'));
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(() => mockSessionManager.signOutDevice())
            .thenAnswer((_) async => true);

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
        final service = AuthService(mockSessionManager, mockClient);
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
