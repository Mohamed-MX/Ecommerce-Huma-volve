import 'package:ecommerce_app_huma_volve/features/home/domain/entities/category_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_all_products_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_products_by_category_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_states.dart';
import 'package:flutter_test/flutter_test.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<List<CategoryEntity>> getCategories() async {
    return [
      const CategoryEntity(id: 1, name: 'Clothes', image: 'clothes.png'),
      const CategoryEntity(id: 2, name: 'Shoes', image: 'shoes.png'),
    ];
  }

  @override
  Future<List<ProductEntity>> getAllProducts({int? limit, int? offset}) async {
    return [
      ProductEntity(
        rawId: 101,
        title: 'T-Shirt',
        description: 'Cotton T-Shirt',
        price: 25.0,
        images: ['https://example.com/shirt.png'],
      ),
    ];
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  }) async {
    return [
      ProductEntity(
        rawId: 201,
        title: 'Sneakers',
        description: 'Cool sneakers',
        price: 80.0,
        images: ['https://example.com/shoes.png'],
      ),
    ];
  }

  @override
  Future<ProductEntity> getProductById(int id) async {
    return ProductEntity(
      rawId: id,
      title: 'Sneakers',
      description: 'Cool sneakers',
      price: 80.0,
      images: ['https://example.com/shoes.png'],
    );
  }
}

void main() {
  group('Home Clean Architecture Tests', () {
    late MockHomeRepository mockRepository;
    late GetCategoriesUseCase getCategoriesUseCase;
    late GetAllProductsUseCase getAllProductsUseCase;
    late GetProductsByCategoryUseCase getProductsByCategoryUseCase;

    setUp(() {
      mockRepository = MockHomeRepository();
      getCategoriesUseCase = GetCategoriesUseCase(mockRepository);
      getAllProductsUseCase = GetAllProductsUseCase(mockRepository);
      getProductsByCategoryUseCase =
          GetProductsByCategoryUseCase(mockRepository);
    });

    test('GetCategoriesUseCase returns categories from repository', () async {
      final categories = await getCategoriesUseCase();
      expect(categories.length, 2);
      expect(categories[0].name, 'Clothes');
    });

    test('GetAllProductsUseCase returns products from repository', () async {
      final products = await getAllProductsUseCase();
      expect(products.length, 1);
      expect(products[0].title, 'T-Shirt');
    });

    test('HomeCubit uses UseCases and emits HomeLoading then HomeLoaded',
        () async {
      final cubit = HomeCubit(
        getCategoriesUseCase: getCategoriesUseCase,
        getAllProductsUseCase: getAllProductsUseCase,
        getProductsByCategoryUseCase: getProductsByCategoryUseCase,
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          isA<HomeLoaded>(),
        ]),
      );

      await cubit.loadHomeData();
      await expectation;

      final state = cubit.state as HomeLoaded;
      expect(state.categories.length, 3); // "All" + 2 categories
      expect(state.categories.first.isAll, isTrue);
      expect(state.products.length, 1);
      expect(state.products.first.title, 'T-Shirt');
    });

    test('HomeCubit selects category and filters via UseCase', () async {
      final cubit = HomeCubit(
        getCategoriesUseCase: getCategoriesUseCase,
        getAllProductsUseCase: getAllProductsUseCase,
        getProductsByCategoryUseCase: getProductsByCategoryUseCase,
      );

      await cubit.loadHomeData();
      final loadedState = cubit.state as HomeLoaded;

      final category = loadedState.categories.firstWhere((c) => c.id == 2);
      await cubit.selectCategory(category);

      final filteredState = cubit.state as HomeLoaded;
      expect(filteredState.selectedCategory.id, 2);
      expect(filteredState.products.first.title, 'Sneakers');
    });
  });
}
