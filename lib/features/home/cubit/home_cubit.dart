import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/home_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'home_states.dart';

/// Cubit managing the state of the Home screen, including categories and product filtering
class HomeCubit extends Cubit<HomeState> {
  final HomeService _homeService;

  HomeCubit({HomeService? homeService})
      : _homeService = homeService ?? HomeService(),
        super(const HomeInitial());

  /// Load initial categories and products (default filter is "All")
  Future<void> loadHomeData() async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _homeService.getCategories(),
        _homeService.getAllProducts(),
      ]);

      final apiCategories = results[0] as List<CategoryModel>;
      final products = results[1] as List<ProductModel>;

      // Ensure "All" category is the first chip
      final allCategories = [CategoryModel.all, ...apiCategories];

      emit(
        HomeLoaded(
          categories: allCategories,
          products: products,
          selectedCategory: CategoryModel.all,
          isProductsLoading: false,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Select a category and filter displayed products.
  /// If [category.isAll] (id == 0), retrieves all products.
  /// Otherwise, queries products specifically for the selected category ID.
  Future<void> selectCategory(CategoryModel category) async {
    final currentState = state;
    if (currentState is! HomeLoaded) {
      await loadHomeData();
      return;
    }

    if (currentState.selectedCategory.id == category.id &&
        !currentState.isProductsLoading) {
      return;
    }

    // Set product loading state while keeping category UI active
    emit(
      currentState.copyWith(
        selectedCategory: category,
        isProductsLoading: true,
      ),
    );

    try {
      final List<ProductModel> products;
      if (category.isAll) {
        products = await _homeService.getAllProducts();
      } else {
        products = await _homeService.getProductsByCategory(category.id);
      }

      emit(
        currentState.copyWith(
          selectedCategory: category,
          products: products,
          isProductsLoading: false,
        ),
      );
    } catch (e) {
      // In case of network error on category filter, reset loading and show empty
      emit(
        currentState.copyWith(
          selectedCategory: category,
          products: [],
          isProductsLoading: false,
        ),
      );
    }
  }

  /// Refresh Home screen data
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      await selectCategory(currentState.selectedCategory);
    } else {
      await loadHomeData();
    }
  }
}
