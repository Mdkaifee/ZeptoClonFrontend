import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/bottom_nav.dart';
import 'package:flutter_application_1/core/routes/app_routes.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_state.dart';
import 'package:flutter_application_1/features/auth/data/models/user_model.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_event.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_state.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/categories/cubit/categories_cubit.dart';
import 'package:flutter_application_1/features/categories/cubit/categories_state.dart';
import 'package:flutter_application_1/features/categories/cubit/category_products_cubit.dart';
import 'package:flutter_application_1/features/categories/data/repositories/category_repository.dart';
import 'package:flutter_application_1/features/categories/presentation/category_products_screen.dart';
import 'package:flutter_application_1/features/catalog/cubit/catalog_cubit.dart';
import 'package:flutter_application_1/features/catalog/cubit/catalog_state.dart';
import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';
import 'package:flutter_application_1/features/orders/cubit/orders_cubit.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_cubit.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_state.dart';
import 'package:flutter_application_1/register_page.dart';

import 'cart.dart';
import 'your_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = AppRoutes.home;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _shopIndex = 0;
  static const int _categoriesIndex = 1;
  static const int _accountIndex = 2;

  int _currentIndex = _shopIndex;
  bool _cartRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeFetchCart();
  }

  void _maybeFetchCart() {
    if (_cartRequested) return;
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    if (authState.status == AuthStatus.authenticated && user.isNotEmpty) {
      context.read<CartBloc>().add(CartRequested(userId: user.id));
      _cartRequested = true;
    }
  }

  void _addToCart(String productId) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    if (authState.status != AuthStatus.authenticated || user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items to cart')),
      );
      Navigator.pushReplacementNamed(context, RegisterPage.routeName);
      return;
    }

    context.read<CartBloc>().add(
          CartItemAdded(
            userId: user.id,
            productId: productId,
          ),
        );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartBloc>(),
          child: const CartScreen(),
        ),
      ),
    );
  }

  void _openOrders(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersCubit>(),
          child: YourOrdersScreen(userId: user.id),
        ),
      ),
    );
  }

  void _openCategoryProducts(String category) {
    final repository = context.read<CategoryRepository>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartBloc>()),
            BlocProvider<CategoryProductsCubit>(
              create: (_) =>
                  CategoryProductsCubit(categoryRepository: repository),
            ),
          ],
          child: CategoryProductsScreen(
            category: category,
            onAddToCart: _addToCart,
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final mobileController = TextEditingController(text: user.mobile ?? '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mobile number is required';
                    }
                    if (value.length != 10) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                        AuthProfileUpdated(
                          userId: user.id,
                          name: nameController.text.trim(),
                          mobile: mobileController.text.trim(),
                        ),
                      );
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updating profile...')),
      );
    }
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    if (index == _categoriesIndex) {
      final categoriesState = context.read<CategoriesCubit>().state;
      if (categoriesState.status == CategoriesStatus.initial) {
        context.read<CategoriesCubit>().fetchCategories();
      }
    }
  }

  String _appBarTitle(AuthState state) {
    switch (_currentIndex) {
      case _shopIndex:
        final user = state.user;
        return user.isNotEmpty ? 'Hi, ${user.name}' : 'Welcome';
      case _categoriesIndex:
        return 'Categories';
      case _accountIndex:
        return 'Account';
      default:
        return 'My App';
    }
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case _shopIndex:
        return _ShopTab(onAddToCart: _addToCart);
      case _categoriesIndex:
        return _CategoriesTab(onCategoryTap: _openCategoryProducts);
      case _accountIndex:
        return _AccountTab(
          onEditProfile: _showEditProfileDialog,
          onViewOrders: _openOrders,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool get _showFab => _currentIndex != _accountIndex;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.infoMessage != current.infoMessage ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.status == AuthStatus.unauthenticated) {
              _cartRequested = false;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            } else if (state.status == AuthStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            } else if (state.infoMessage != null &&
                state.infoMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.infoMessage!)),
              );
            }

            if (state.status == AuthStatus.authenticated) {
              _cartRequested = false;
              _maybeFetchCart();
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (previous, current) =>
              previous.infoMessage != current.infoMessage ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.infoMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.infoMessage!)),
              );
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
        ),
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.infoMessage != current.infoMessage ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.status == CheckoutStatus.success &&
                state.infoMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.infoMessage!)),
              );
            } else if (state.status == CheckoutStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => Text(_appBarTitle(state)),
          ),
          actions: [
            IconButton(
              icon: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state.totalItems == 0) {
                    return const Icon(Icons.shopping_cart_outlined);
                  }
                  return Stack(
                    children: [
                      const Icon(Icons.shopping_cart),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '${state.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              onPressed: _openCart,
            ),
          ],
        ),
        body: _buildCurrentTab(),
        floatingActionButton: _showFab
            ? FloatingActionButton.extended(
                onPressed: _openCart,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('View Cart'),
              )
            : null,
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

class _ShopTab extends StatelessWidget {
  const _ShopTab({required this.onAddToCart});

  final void Function(String productId) onAddToCart;

  Future<void> _refresh(BuildContext context) async {
    final catalogCubit = context.read<CatalogCubit>();
    final cartBloc = context.read<CartBloc>();
    final authState = context.read<AuthBloc>().state;

    await catalogCubit.fetchProducts();
    if (authState.status == AuthStatus.authenticated &&
        authState.user.isNotEmpty) {
      cartBloc.add(CartRequested(userId: authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, catalogState) {
          if (catalogState.status == CatalogStatus.loading &&
              catalogState.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catalogState.status == CatalogStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  catalogState.errorMessage ?? 'Failed to load products',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final products = catalogState.products;
          if (products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 80, top: 12),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductTile(
                    product: product,
                    onAddToCart: () => onAddToCart(product.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onAddToCart,
  });

  final ProductModel product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if ((product.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(product.description!),
            ],
            if (product.formattedQuantity.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Quantity: ${product.formattedQuantity}'),
            ],
            const SizedBox(height: 8),
            Text(
              '₹ ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                CartItemModel? cartItem;
                for (final item in cartState.items) {
                  if (item.product.id == product.id) {
                    cartItem = item;
                    break;
                  }
                }

                if (cartItem == null) {
                  final isLoading = cartState.isUpdating &&
                      cartState.pendingProductId == product.id;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add to Cart'),
                    ),
                  );
                }

                final cartItemId = cartItem.id;
                final isUpdatingQuantity =
                    cartState.isUpdating && cartState.pendingCartItemId == cartItemId;
                final user = context.read<AuthBloc>().state.user;
                final quantityText = '${cartItem.quantity}';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: isUpdatingQuantity
                                ? null
                                : () {
                                    if (user.isEmpty) return;
                                    context.read<CartBloc>().add(
                                          CartItemQuantityChanged(
                                            userId: user.id,
                                            cartItemId: cartItemId,
                                            quantityChange: -1,
                                          ),
                                        );
                                  },
                          ),
                          Text(
                            quantityText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: isUpdatingQuantity
                                ? null
                                : () {
                                    if (user.isEmpty) return;
                                    context.read<CartBloc>().add(
                                          CartItemQuantityChanged(
                                            userId: user.id,
                                            cartItemId: cartItemId,
                                            quantityChange: 1,
                                          ),
                                        );
                                  },
                          ),
                        ],
                      ),
                      if (isUpdatingQuantity)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.onCategoryTap});

  final ValueChanged<String> onCategoryTap;

  Future<void> _refresh(BuildContext context) {
    return context
        .read<CategoriesCubit>()
        .fetchCategories(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          switch (state.status) {
            case CategoriesStatus.initial:
              context.read<CategoriesCubit>().fetchCategories();
              return const Center(child: CircularProgressIndicator());
            case CategoriesStatus.loading:
              if (state.categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              break;
            case CategoriesStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Failed to load categories.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<CategoriesCubit>()
                            .fetchCategories(forceRefresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            case CategoriesStatus.success:
              break;
          }

          final categories = state.categories;
          if (categories.isEmpty) {
            return const Center(child: Text('No categories available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                child: ListTile(
                  title: Text(category.name),
                  subtitle: Text('${category.productCount} products'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onCategoryTap(category.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.onEditProfile,
    required this.onViewOrders,
  });

  final ValueChanged<UserModel> onEditProfile;
  final ValueChanged<UserModel> onViewOrders;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (state.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (user.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Login to manage your account.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RegisterPage.routeName,
                    );
                  },
                  child: const Text('Login / Register'),
                ),
              ],
            );
          }

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.name),
                subtitle: Text(user.email),
              ),
              if ((user.mobile ?? '').isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(user.mobile!),
                  subtitle: const Text('Mobile'),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => onEditProfile(user),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => onViewOrders(user),
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Orders'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}


