import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

/// Base class for all Home presentation states
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
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final CategoryEntity selectedCategory;
  final bool isProductsLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;

  const HomeLoaded({
    required this.categories,
    required this.products,
    required this.selectedCategory,
    this.isProductsLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  HomeLoaded copyWith({
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    CategoryEntity? selectedCategory,
    bool? isProductsLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// Error state when data fetching fails
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});
}
