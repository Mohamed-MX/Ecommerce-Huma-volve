import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import 'home_states.dart';

/// Presentation Logic Holder managing the state of the Home screen
class HomeCubit extends Cubit<HomeState> {
  static const int defaultPageSize = 16;

  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetAllProductsUseCase _getAllProductsUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;

  HomeCubit({
    GetCategoriesUseCase? getCategoriesUseCase,
    GetAllProductsUseCase? getAllProductsUseCase,
    GetProductsByCategoryUseCase? getProductsByCategoryUseCase,
    HomeRepository? homeRepository,
    dynamic homeService,
  })  : _getCategoriesUseCase = getCategoriesUseCase ??
            GetCategoriesUseCase(
              homeRepository ??
                  (homeService != null
                      ? _HomeServiceAdapter(homeService)
                      : HomeRepositoryImpl()),
            ),
        _getAllProductsUseCase = getAllProductsUseCase ??
            GetAllProductsUseCase(
              homeRepository ??
                  (homeService != null
                      ? _HomeServiceAdapter(homeService)
                      : HomeRepositoryImpl()),
            ),
        _getProductsByCategoryUseCase = getProductsByCategoryUseCase ??
            GetProductsByCategoryUseCase(
              homeRepository ??
                  (homeService != null
                      ? _HomeServiceAdapter(homeService)
                      : HomeRepositoryImpl()),
            ),
        super(const HomeInitial());

  /// Load initial categories and products (default filter is "All", limit 16)
  Future<void> loadHomeData() async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _getCategoriesUseCase(),
        _getAllProductsUseCase(limit: defaultPageSize, offset: 0),
      ]);

      final apiCategories = results[0] as List<CategoryEntity>;
      final products = results[1] as List<ProductEntity>;

      // Ensure "All" category is the first chip
      final allCategories = [CategoryEntity.all, ...apiCategories];

      emit(
        HomeLoaded(
          categories: allCategories,
          products: products,
          selectedCategory: CategoryEntity.all,
          isProductsLoading: false,
          isLoadingMore: false,
          hasReachedMax: products.length < defaultPageSize,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Load the next 16 products for the active category (pagination)
  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;
    if (currentState.isProductsLoading ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final currentOffset = currentState.products.length;
      final List<ProductEntity> newProducts;
      if (currentState.selectedCategory.isAll) {
        newProducts = await _getAllProductsUseCase(
          limit: defaultPageSize,
          offset: currentOffset,
        );
      } else {
        newProducts = await _getProductsByCategoryUseCase(
          currentState.selectedCategory.id,
          limit: defaultPageSize,
          offset: currentOffset,
        );
      }

      if (newProducts.isEmpty) {
        emit(
          currentState.copyWith(
            isLoadingMore: false,
            hasReachedMax: true,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            products: [...currentState.products, ...newProducts],
            isLoadingMore: false,
            hasReachedMax: newProducts.length < defaultPageSize,
          ),
        );
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Fetch a paginated batch of products
  Future<List<ProductEntity>> fetchProductsPage({
    required int offset,
    int limit = defaultPageSize,
    int? categoryId,
  }) async {
    final targetCategoryId = categoryId ??
        (state is HomeLoaded ? (state as HomeLoaded).selectedCategory.id : 0);

    if (targetCategoryId == 0) {
      return _getAllProductsUseCase(limit: limit, offset: offset);
    } else {
      return _getProductsByCategoryUseCase(
        targetCategoryId,
        limit: limit,
        offset: offset,
      );
    }
  }

  /// Select a category and filter displayed products
  Future<void> selectCategory(CategoryEntity category) async {
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
        products: [],
        isProductsLoading: true,
        isLoadingMore: false,
        hasReachedMax: false,
      ),
    );

    try {
      final List<ProductEntity> products;
      if (category.isAll) {
        products = await _getAllProductsUseCase(limit: defaultPageSize, offset: 0);
      } else {
        products = await _getProductsByCategoryUseCase(
          category.id,
          limit: defaultPageSize,
          offset: 0,
        );
      }

      emit(
        currentState.copyWith(
          selectedCategory: category,
          products: products,
          isProductsLoading: false,
          isLoadingMore: false,
          hasReachedMax: products.length < defaultPageSize,
        ),
      );
    } catch (e) {
      // In case of network error on category filter, reset loading and show empty
      emit(
        currentState.copyWith(
          selectedCategory: category,
          products: [],
          isProductsLoading: false,
          isLoadingMore: false,
          hasReachedMax: true,
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

/// Adapter allowing legacy or test service objects to satisfy [HomeRepository]
class _HomeServiceAdapter implements HomeRepository {
  final dynamic _service;

  _HomeServiceAdapter(this._service);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final res = await _service.getCategories();
    return (res as List).cast<CategoryEntity>();
  }

  @override
  Future<List<ProductEntity>> getAllProducts({int? limit, int? offset}) async {
    final res = await _service.getAllProducts(limit: limit, offset: offset);
    return (res as List).cast<ProductEntity>();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  }) async {
    final res = await _service.getProductsByCategory(
      categoryId,
      limit: limit,
      offset: offset,
    );
    return (res as List).cast<ProductEntity>();
  }

  @override
  Future<ProductEntity> getProductById(int id) async {
    final res = await _service.getProductById(id);
    return res as ProductEntity;
  }
}
