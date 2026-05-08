import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/message_bubble.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

void main() {
  // Initialize binding before tests
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('MessageBubble Widget Tests', () {
    // Helper to wrap widget with ScreenUtil
    Widget wrapWithScreenUtil(Widget widget) {
      return MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => widget,
          ),
        ),
      );
    }

    testWidgets('displays user message correctly', (tester) async {
      final message = Message(
        id: '1',
        content: 'Hello from user',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        wrapWithScreenUtil(
          MessageBubble(message: message, showAvatar: true, showStatus: true),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hello from user'), findsOneWidget);
    });

    testWidgets('displays other user message correctly', (tester) async {
      final message = Message(
        id: '2',
        content: 'Hello from other',
        timestamp: DateTime.now(),
        sender: MessageSender.other,
        status: MessageStatus.read,
      );

      await tester.pumpWidget(
        wrapWithScreenUtil(
          MessageBubble(message: message, showAvatar: true, showStatus: true),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hello from other'), findsOneWidget);
    });

    testWidgets('shows sending status', (tester) async {
      final message = Message(
        id: '3',
        content: 'Sending message',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.sending,
      );

      await tester.pumpWidget(
        wrapWithScreenUtil(
          MessageBubble(message: message, showAvatar: true, showStatus: true),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sending'), findsOneWidget);
    });

    testWidgets('shows failed status', (tester) async {
      final message = Message(
        id: '4',
        content: 'Failed message',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.failed,
      );

      await tester.pumpWidget(
        wrapWithScreenUtil(
          MessageBubble(message: message, showAvatar: true, showStatus: true),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsOneWidget);
    });
  });
}
