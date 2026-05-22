import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/common/access_denied_screen.dart';
import '../../providers/auth_provider.dart';
import 'route_names.dart';

class RouteGuard {
  RouteGuard._();

  static Route<dynamic> protect(RouteSettings settings, Widget page) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) {
        return Consumer<AuthProvider>(
          builder: (_, authProvider, __) {
            if (authProvider.isLoading) {
              return const _GuardLoadingScreen();
            }

            if (!authProvider.isLoggedIn) {
              return const LoginScreen();
            }

            return page;
          },
        );
      },
    );
  }

  static Route<dynamic> protectAdmin(RouteSettings settings, Widget page) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) {
        return Consumer<AuthProvider>(
          builder: (_, authProvider, __) {
            if (authProvider.isLoading) {
              return const _GuardLoadingScreen();
            }

            if (!authProvider.isLoggedIn) {
              return const LoginScreen();
            }

            if (authProvider.isAdmin) {
              return page;
            }

            if (authProvider.isClient) {
              return const _RoleRedirectScreen(
                targetRoute: RouteNames.clientDashboard,
              );
            }

            return const AccessDeniedScreen();
          },
        );
      },
    );
  }

  static Route<dynamic> protectClient(RouteSettings settings, Widget page) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) {
        return Consumer<AuthProvider>(
          builder: (_, authProvider, __) {
            if (authProvider.isLoading) {
              return const _GuardLoadingScreen();
            }

            if (!authProvider.isLoggedIn) {
              return const LoginScreen();
            }

            if (authProvider.isClient) {
              return page;
            }

            if (authProvider.isAdmin) {
              return const _RoleRedirectScreen(
                targetRoute: RouteNames.adminDashboard,
              );
            }

            return const AccessDeniedScreen();
          },
        );
      },
    );
  }

  static Route<dynamic> protectByRole({
    required RouteSettings settings,
    required Widget adminPage,
    required Widget clientPage,
  }) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) {
        return Consumer<AuthProvider>(
          builder: (_, authProvider, __) {
            if (authProvider.isLoading) {
              return const _GuardLoadingScreen();
            }

            if (!authProvider.isLoggedIn) {
              return const LoginScreen();
            }

            if (authProvider.isAdmin) {
              return adminPage;
            }

            if (authProvider.isClient) {
              return clientPage;
            }

            return const AccessDeniedScreen();
          },
        );
      },
    );
  }

  static String? redirectHome(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return RouteNames.login;
    }

    if (authProvider.isAdmin) {
      return RouteNames.adminDashboard;
    }

    if (authProvider.isClient) {
      return RouteNames.clientDashboard;
    }

    return RouteNames.accessDenied;
  }
}

class _GuardLoadingScreen extends StatelessWidget {
  const _GuardLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _RoleRedirectScreen extends StatefulWidget {
  final String targetRoute;

  const _RoleRedirectScreen({
    required this.targetRoute,
  });

  @override
  State<_RoleRedirectScreen> createState() => _RoleRedirectScreenState();
}

class _RoleRedirectScreenState extends State<_RoleRedirectScreen> {
  bool _redirected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_redirected) return;
    _redirected = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.targetRoute,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
