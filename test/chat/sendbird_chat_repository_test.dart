import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:nano_embryo/presentation/features/chat/data/repositories/sendbird_chat_repository.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';

// Mock classes
class MockSendbirdSdk extends Mock implements SendbirdSdk {}
class MockGroupChannel extends Mock implements GroupChannel {}
class MockUser extends Mock implements User {}
class MockUserMessage extends Mock implements UserMessage {}

void main() {
  late SendbirdChatRepository repository;
  late MockSendbirdSdk mockSendbird;
  late MockGroupChannel mockChannel;
  late MockUser mockUser;

  setUp(() {
    mockSendbird = MockSendbirdSdk();
    mockChannel = MockGroupChannel();
    mockUser = MockUser();
    repository = SendbirdChatRepository(mockSendbird);
  });

  group('SendbirdChatRepository Tests', () {
    test('should be instantiated correctly', () {
      expect(repository, isNotNull);
    });

    test('should connect user successfully', () async {
      when(() => mockSendbird.connect(
        any(), 
        nickname: any(named: 'nickname'),
      )).thenAnswer((_) async => mockUser);
      when(() => mockUser.userId).thenReturn('test_user');

      await repository.connect('test_user', nickname: 'Test User');

      verify(() => mockSendbird.connect('test_user', nickname: 'Test User')).called(1);
    });

    test('should throw error on connection failure', () async {
      when(() => mockSendbird.connect(any(), nickname: any(named: 'nickname')))
          .thenThrow(Exception('Connection failed'));

      expect(
        () => repository.connect('test_user'),
        throwsException,
      );
    });

    test('should disconnect successfully', () async {
      when(() => mockSendbird.disconnect()).thenAnswer((_) async => {});

      await repository.disconnect();

      verify(() => mockSendbird.disconnect()).called(1);
    });

    test('should check connection status', () async {
      when(() => mockSendbird.currentUser).thenReturn(mockUser);

      final isConnected = await repository.isConnected();
      expect(isConnected, isTrue);
    });
  });
}