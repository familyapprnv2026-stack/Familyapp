import 'package:family_app/providers/auth_provider.dart';
import 'package:family_app/providers/theme_provider.dart';
import 'package:family_app/screens/auth/login_screen.dart';
import 'package:family_app/screens/auth/recover_password_screen.dart';
import 'package:family_app/screens/auth/register_screen.dart';
import 'package:family_app/screens/auth/verify_email_screen.dart';
import 'package:family_app/screens/calendar/calendar_screen.dart';
import 'package:family_app/screens/calendar/create_edit_event_screen.dart';
import 'package:family_app/screens/chat/chat_screen.dart';
import 'package:family_app/screens/home/home_screen.dart';
import 'package:family_app/screens/profile/about_screen.dart';
import 'package:family_app/screens/profile/edit_profile_screen.dart';
import 'package:family_app/screens/profile/help_support_screen.dart';
import 'package:family_app/screens/profile/members_screen.dart';
import 'package:family_app/screens/profile/notifications_screen.dart';
import 'package:family_app/screens/profile/privacy_screen.dart';
import 'package:family_app/screens/profile/profile_screen.dart';
import 'package:family_app/screens/profile/settings_screen.dart';
import 'package:family_app/screens/profile/terms_screen.dart';
import 'package:family_app/screens/tasks/create_edit_task_screen.dart';
import 'package:family_app/screens/tasks/tasks_screen.dart';
import 'package:family_app/theme/app_theme.dart';
import 'package:family_app/widgets/initials_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class _FakeAuth extends AuthProvider {
  @override
  User? get user => null;

  @override
  Future<String?> familyIdForUser() async => null;
}

final _sizes = <Size>[
  const Size(320, 640),
  const Size(360, 640),
  const Size(400, 800),
  const Size(412, 915),
];

final _screens = <String, Widget Function()>{
  'HomeScreen': () => const HomeScreen(),
  'CalendarScreen': () => const CalendarScreen(),
  'TasksScreen': () => const TasksScreen(),
  'ProfileScreen': () => const ProfileScreen(),
  'MembersScreen': () => const MembersScreen(),
  'ChatScreen': () => const ChatScreen(),
  'SettingsScreen': () => const SettingsScreen(),
  'NotificationsScreen': () => const NotificationsScreen(),
  'AboutScreen': () => const AboutScreen(),
  'HelpSupportScreen': () => const HelpSupportScreen(),
  'TermsScreen': () => const TermsScreen(),
  'PrivacyScreen': () => const PrivacyScreen(),
  'EditProfileScreen': () => const EditProfileScreen(),
  'CreateEditTaskScreen': () => const CreateEditTaskScreen(),
  'CreateEditEventScreen': () => const CreateEditEventScreen(),
  'LoginScreen': () => const LoginScreen(),
  'RegisterScreen': () => const RegisterScreen(),
  'RecoverPasswordScreen': () => const RecoverPasswordScreen(),
  'VerifyEmailScreen': () => const VerifyEmailScreen(),
};

Future<void> pumpScreen(WidgetTester tester, Widget child, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final overflows = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed')) overflows.add(text.split('\n').first);
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _FakeAuth()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(
    overflows,
    isEmpty,
    reason: 'RenderFlex overflow en $size',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('es_ES', null);

  _screens.forEach((name, builder) {
    for (final size in _sizes) {
      testWidgets('$name sin overflow en ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        await pumpScreen(tester, builder(), size);
      });
    }
  });

  testWidgets('InitialsAvatar respeta su tamano', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: Center(
          child: InitialsAvatar(initials: 'AB', size: 40, color: Colors.blue),
        ),
      ),
      const Size(360, 640),
    );
    expect(tester.getSize(find.byType(InitialsAvatar)), const Size(40, 40));
  });
}
