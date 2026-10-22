import '../models/category_model.dart';
import '../models/product_model.dart';

/// Base class for all Home states
abstract class HomeState {
  const HomeState();
}

/// Initial state before any data loading begins
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state for the initial page load (both categories and products)
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Loaded state containing categories, displayed products, and active filter
class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final CategoryModel selectedCategory;
  final bool isProductsLoading;

  const HomeLoaded({
    required this.categories,
    required this.products,
    required this.selectedCategory,
    this.isProductsLoading = false,
  });

  HomeLoaded copyWith({
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    CategoryModel? selectedCategory,
    bool? isProductsLoading,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
    );
  }
}

/// Error state when data fetching fails
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});
}
