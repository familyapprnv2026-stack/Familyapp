import 'package:go_router/go_router.dart';
import '../models/event.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/main_wrapper.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/calendar/create_edit_event_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/tasks/create_edit_task_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/generic_info_screen.dart';
import '../screens/auth/recover_password_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/recover-password',
        builder: (context, state) => const RecoverPasswordScreen(),
      ),
      GoRoute(
        path: '/create-task',
        builder: (context, state) => const CreateEditTaskScreen(isEdit: false),
      ),
      GoRoute(
        path: '/create-event',
        builder: (context, state) => const CreateEditEventScreen(),
      ),
      GoRoute(
        path: '/edit-event',
        builder: (context, state) =>
            CreateEditEventScreen(event: state.extra as FamilyEvent?),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const GenericInfoScreen(title: 'Configuración'),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const GenericInfoScreen(title: 'Notificaciones'),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const GenericInfoScreen(title: 'Ayuda y Soporte'),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const GenericInfoScreen(title: 'Términos y Condiciones'),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const GenericInfoScreen(title: 'Política de Privacidad'),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const GenericInfoScreen(title: 'Acerca de FamilyApp'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
