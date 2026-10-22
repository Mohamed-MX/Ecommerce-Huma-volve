import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/core/network/api_client.dart';
import 'package:ecommerce_app_huma_volve/features/home/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/cubit/home_states.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/category_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/product_model.dart';
import 'package:ecommerce_app_huma_volve/features/services/home_service.dart';

void main() {
  group('CategoryModel & ProductModel Tests', () {
    test('CategoryModel.all has id 0 and isAll returns true', () {
      expect(CategoryModel.all.id, 0);
      expect(CategoryModel.all.name, 'All');
      expect(CategoryModel.all.isAll, isTrue);
    });

    test('CategoryModel correctly parses JSON', () {
      final json = {
        'id': 2,
        'name': 'Electronics',
        'image': 'https://placeimg.com/640/480/any',
      };
      final cat = CategoryModel.fromJson(json);
      expect(cat.id, 2);
      expect(cat.name, 'Electronics');
      expect(cat.image, 'https://placeimg.com/640/480/any');
      expect(cat.isAll, isFalse);
    });

    test('ProductModel sanitizes escaped JSON image strings', () {
      final json = {
        'id': 10,
        'title': 'Test Shoes',
        'price': 49.99,
        'description': 'A nice pair of shoes',
        'images': [
          '["https://example.com/shoe1.png"]',
          'https://example.com/shoe2.png',
        ],
        'category': {
          'id': 1,
          'name': 'Shoes',
          'image': 'https://example.com/cat.png',
        },
      };

      final product = ProductModel.fromJson(json);
      expect(product.rawId, 10);
      expect(product.title, 'Test Shoes');
      expect(product.price, 49.99);
      expect(product.images.length, 2);
      expect(product.images[0], 'https://example.com/shoe1.png');
      expect(product.imageUrl, 'https://example.com/shoe1.png');
      expect(product.category?.name, 'Shoes');
      expect(product.colors, isNotEmpty);
      expect(product.sizes, isNotEmpty);
    });
  });

  group('HomeService & HomeCubit Tests with Mock Dio', () {
    test('HomeCubit loadHomeData emits HomeLoading then HomeLoaded with All category first', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/categories') && !options.path.contains('/products')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {'id': 1, 'name': 'Clothes', 'image': 'https://example.com/1.png'},
                    {'id': 2, 'name': 'Electronics', 'image': 'https://example.com/2.png'},
                  ],
                ),
              );
            } else if (options.path.contains('/products')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 101,
                      'title': 'Cool Shirt',
                      'price': 25.0,
                      'description': 'Cotton shirt',
                      'images': ['https://example.com/shirt.png'],
                    },
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final apiClient = ApiClient(dio: dio);
      final homeService = HomeService(apiClient: apiClient);
      final cubit = HomeCubit(homeService: homeService);

      expect(cubit.state, isA<HomeInitial>());

      final futureExpect = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          isA<HomeLoaded>(),
        ]),
      );

      await cubit.loadHomeData();
      await futureExpect;

      final loaded = cubit.state as HomeLoaded;
      expect(loaded.categories.length, 3); // "All" + 2 from API
      expect(loaded.categories[0].name, 'All');
      expect(loaded.selectedCategory.isAll, isTrue);
      expect(loaded.products.length, 1);
      expect(loaded.products[0].title, 'Cool Shirt');
    });

    test('HomeCubit selectCategory filters products by category ID', () async {
      String? lastRequestedPath;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            lastRequestedPath = options.path;
            if (options.path.contains('/categories') && !options.path.contains('/products')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {'id': 1, 'name': 'Clothes', 'image': 'https://example.com/1.png'},
                  ],
                ),
              );
            } else if (options.path.contains('/categories/1/products')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 201,
                      'title': 'Category 1 Item',
                      'price': 40.0,
                      'description': 'Category product',
                      'images': ['https://example.com/cat1.png'],
                    },
                  ],
                ),
              );
            } else {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [],
                ),
              );
            }
          },
        ),
      );

      final apiClient = ApiClient(dio: dio);
      final homeService = HomeService(apiClient: apiClient);
      final cubit = HomeCubit(homeService: homeService);

      await cubit.loadHomeData();
      final loadedState = cubit.state as HomeLoaded;

      final clothesCat = loadedState.categories.firstWhere((c) => c.id == 1);
      await cubit.selectCategory(clothesCat);

      final filteredState = cubit.state as HomeLoaded;
      expect(filteredState.selectedCategory.id, 1);
      expect(filteredState.products.length, 1);
      expect(filteredState.products.first.title, 'Category 1 Item');
      expect(lastRequestedPath, contains('/categories/1/products'));
    });
  });
}
