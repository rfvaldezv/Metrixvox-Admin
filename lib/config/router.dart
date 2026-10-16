import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/screens/auth/login_screen.dart';
import 'package:metrixvox_admin/screens/dashboard/dashboard_screen.dart';
import 'package:metrixvox_admin/widgets/layout/app_shell.dart';

/// Router global de la app con go_router.
/// Guard: si el usuario no está autenticado, redirige a /login.
class AppRouter {
  static GoRouter build(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isAuthenticated;
        final isGoingToLogin = state.matchedLocation == '/login';

        // No autenticado + no va a login → redirigir a login
        if (!isLoggedIn && !isGoingToLogin) return '/login';

        // Ya autenticado + va a login → redirigir a dashboard
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
            // Los siguientes se activan en fases posteriores:
            // GoRoute(path: '/kiosks', builder: (_, __) => const KiosksScreen()),
            // GoRoute(path: '/responses', builder: (_, __) => const ResponsesScreen()),
            // GoRoute(path: '/tenants', builder: (_, __) => const TenantsScreen()),
            // GoRoute(path: '/users', builder: (_, __) => const UsersScreen()),
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
