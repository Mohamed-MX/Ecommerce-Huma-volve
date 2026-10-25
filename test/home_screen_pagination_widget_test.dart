import 'dart:async';
import 'dart:io';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/category_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_all_products_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_products_by_category_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #openUrl) {
      return Future.value(_MockHttpClientRequest());
    }
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return _MockHttpHeaders();
    }
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kTransparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #headers) {
      return _MockHttpHeaders();
    }
    return super.noSuchMethod(invocation);
  }
}

class _FakeHomeRepo implements HomeRepository {
  @override
  Future<List<CategoryEntity>> getCategories() async {
    return [
      const CategoryEntity(id: 1, name: 'Clothes', image: ''),
      const CategoryEntity(id: 2, name: 'Electronics', image: ''),
    ];
  }

  @override
  Future<List<ProductEntity>> getAllProducts({int? limit, int? offset}) async {
    final count = limit ?? 16;
    final start = offset ?? 0;
    return List.generate(
      count,
      (i) => ProductEntity(
        rawId: start + i,
        title: 'Product ${start + i}',
        description: 'Test product',
        price: 19.99,
        images: const ['https://example.com/item.png'],
      ),
    );
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  }) async {
    return List.generate(
      limit ?? 16,
      (i) => ProductEntity(
        rawId: (offset ?? 0) + i,
        title: 'Cat $categoryId Item $i',
        description: 'Category item',
        price: 29.99,
        images: const ['https://example.com/cat.png'],
      ),
    );
  }

  @override
  Future<ProductEntity> getProductById(int id) async {
    return ProductEntity(
      rawId: id,
      title: 'Product $id',
      description: 'Detail',
      price: 10.0,
      images: const [],
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('HomeScreen renders with infinite scroll pagination', (tester) async {
    final fakeRepo = _FakeHomeRepo();
    final cubit = HomeCubit(
      getCategoriesUseCase: GetCategoriesUseCase(fakeRepo),
      getAllProductsUseCase: GetAllProductsUseCase(fakeRepo),
      getProductsByCategoryUseCase: GetProductsByCategoryUseCase(fakeRepo),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(cubit: cubit..loadHomeData()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Best trendy collection!'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Clothes'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);

    // Initial 16 items loaded and rendered
    expect(find.text('Product 0'), findsOneWidget);
  });

  testWidgets('HomeScreen updates product cards when category chip is tapped',
      (tester) async {
    final fakeRepo = _FakeHomeRepo();
    final cubit = HomeCubit(
      getCategoriesUseCase: GetCategoriesUseCase(fakeRepo),
      getAllProductsUseCase: GetAllProductsUseCase(fakeRepo),
      getProductsByCategoryUseCase: GetProductsByCategoryUseCase(fakeRepo),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(cubit: cubit..loadHomeData()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Product 0'), findsOneWidget);

    // Tap "Clothes" (category ID 1)
    await tester.tap(find.text('Clothes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should now show category 1 items
    expect(find.text('Cat 1 Item 0'), findsOneWidget);
    expect(find.text('Product 0'), findsNothing);

    // Tap "Electronics" (category ID 2)
    await tester.tap(find.text('Electronics'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should now show category 2 items
    expect(find.text('Cat 2 Item 0'), findsOneWidget);
    expect(find.text('Cat 1 Item 0'), findsNothing);

    // Tap "All" to return to all products
    await tester.tap(find.text('All'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Product 0'), findsOneWidget);
  });
}
