import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/routes/app_routes.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/presentation/login_page.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/data/repositories/cart_repository.dart';
import 'package:flutter_application_1/features/catalog/cubit/catalog_cubit.dart';
import 'package:flutter_application_1/features/catalog/data/repositories/product_repository.dart';
import 'package:flutter_application_1/features/orders/cubit/orders_cubit.dart';
import 'package:flutter_application_1/features/orders/data/repositories/order_repository.dart';
import 'package:flutter_application_1/features/payment/data/repositories/payment_repository.dart';
import 'package:flutter_application_1/register_page.dart';
import 'package:flutter_application_1/splash_screen.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_cubit.dart';
import 'package:flutter_application_1/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final authRepository = AuthRepository(apiService: apiService);
  final productRepository = ProductRepository(apiService: apiService);
  final cartRepository = CartRepository(apiService: apiService);
  final orderRepository = OrderRepository(apiService: apiService);
  final paymentRepository = PaymentRepository(apiService: apiService);

  runApp(
    MyApp(
      authRepository: authRepository,
      productRepository: productRepository,
      cartRepository: cartRepository,
      orderRepository: orderRepository,
      paymentRepository: paymentRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authRepository,
    required this.productRepository,
    required this.cartRepository,
    required this.orderRepository,
    required this.paymentRepository,
  });

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final OrderRepository orderRepository;
  final PaymentRepository paymentRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: cartRepository),
        RepositoryProvider.value(value: orderRepository),
        RepositoryProvider.value(value: paymentRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(authRepository: authRepository)..add(const AuthStatusRequested()),
          ),
          BlocProvider<CatalogCubit>(
            create: (_) =>
                CatalogCubit(productRepository: productRepository)..fetchProducts(),
          ),
          BlocProvider<CartBloc>(
            create: (_) => CartBloc(cartRepository: cartRepository),
          ),
          BlocProvider<OrdersCubit>(
            create: (_) => OrdersCubit(orderRepository: orderRepository),
          ),
          BlocProvider<CheckoutCubit>(
            create: (context) => CheckoutCubit(
              orderRepository: orderRepository,
              cartRepository: cartRepository,
              paymentRepository: paymentRepository,
              ordersCubit: context.read<OrdersCubit>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'My App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.amber),
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.login: (_) => const LoginPage(),
            AppRoutes.register: (_) => const RegisterPage(),
            AppRoutes.home: (_) => const HomeScreen(),
          },
          initialRoute: AppRoutes.splash,
        ),
      ),
    );
  }
}
