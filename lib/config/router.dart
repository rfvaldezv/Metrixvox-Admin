import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/screens/auth/login_screen.dart';
import 'package:metrixvox_admin/screens/dashboard/dashboard_screen.dart';
import 'package:metrixvox_admin/screens/kiosks/kiosks_screen.dart';
import 'package:metrixvox_admin/widgets/layout/app_shell.dart';

/// Router global de la app con go_router.
class AppRouter {
  static GoRouter build(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isAuthenticated;
        final isGoingToLogin = state.matchedLocation == '/login';

        if (!isLoggedIn && !isGoingToLogin) return '/login';
        if (isLoggedIn && isGoingToLogin) return '/dashboard';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/kiosks',
              builder: (_, __) => const KiosksScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Página no encontrada: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
