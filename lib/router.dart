import 'package:go_router/go_router.dart';

import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/loyalty_points_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuScreen(),
              routes: [
                GoRoute(
                  path: 'cart',
                  builder: (context, state) => const CartScreen(),
                  routes: [
                    GoRoute(
                      path: 'checkout',
                      builder: (context, state) => CheckoutScreen(
                        usePoints: state.extra == true,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const ProductFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.tryParse(
                      state.pathParameters['id']!,
                    ) ?? -1;

                    return ProductDetailScreen(
                      productId: id,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => ProductFormScreen(
                        productId: int.tryParse(state.pathParameters['id']!) ?? -1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) =>
                  const OrderHistoryScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/points',
              builder: (context, state) =>
                  const LoyaltyPointsScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
