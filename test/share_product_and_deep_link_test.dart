import 'dart:async';
import 'dart:io';

import 'package:ecommerce_app_huma_volve/core/dummy_data.dart';
import 'package:ecommerce_app_huma_volve/core/services/deep_link_service.dart';
import 'package:ecommerce_app_huma_volve/features/details/screens/product_details_screen.dart';
import 'package:ecommerce_app_huma_volve/features/details/widgets/share_product_button.dart';
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

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
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

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  group('DeepLinkService URI Parsing Tests', () {
    test('extracts product ID from HTTPS path /product/123', () {
      final uri = Uri.parse('https://ecommerceapp.com/product/123');
      final id = DeepLinkService.extractProductId(uri);
      expect(id, equals('123'));
    });

    test('extracts product ID from HTTPS query ?id=456', () {
      final uri = Uri.parse('https://ecommerceapp.com/product?id=456');
      final id = DeepLinkService.extractProductId(uri);
      expect(id, equals('456'));
    });

    test('extracts product ID from custom scheme ecommerce://product/789', () {
      final uri = Uri.parse('ecommerce://product/789');
      final id = DeepLinkService.extractProductId(uri);
      expect(id, equals('789'));
    });

    test('extracts product ID from custom scheme query ecommerce://product?id=999', () {
      final uri = Uri.parse('ecommerce://product?id=999');
      final id = DeepLinkService.extractProductId(uri);
      expect(id, equals('999'));
    });

    test('returns null for unrelated URIs', () {
      final uri = Uri.parse('https://ecommerceapp.com/categories');
      final id = DeepLinkService.extractProductId(uri);
      expect(id, isNull);
    });

    test('buildProductDeepLink creates valid URLs', () {
      final webLink = DeepLinkService.buildProductDeepLink('1');
      expect(webLink, equals('https://ecommerceapp.com/product/1'));

      final customSchemeLink =
          DeepLinkService.buildProductDeepLink('1', useWebUrl: false);
      expect(customSchemeLink, equals('ecommerce://product/1'));
    });
  });

  group('ShareProductButton Widget Tests', () {
    testWidgets('renders share icon button properly', (WidgetTester tester) async {
      final product = dummyProducts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                ShareProductButton(product: product),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShareProductButton), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    test('generates expected share text and deep link', () {
      final product = dummyProducts.first;
      final shareText = ShareProductButton.generateShareText(product);

      expect(shareText, contains(product.name));
      expect(shareText, contains('\$${product.price.toStringAsFixed(2)}'));
      expect(shareText, contains('https://ecommerceapp.com/product/${product.id}'));
    });
  });

  group('ProductDetailsScreen Widget Tests', () {
    testWidgets('displays share button next to heart icon in AppBar actions',
        (WidgetTester tester) async {
      final product = dummyProducts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(product: product),
        ),
      );

      await tester.pumpAndSettle();

      // Verify share button and favorite icon exist
      expect(find.byType(ShareProductButton), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Verify product details display
      expect(find.text(product.name), findsOneWidget);
      expect(find.text('\$${product.price.toStringAsFixed(2)}'), findsOneWidget);
    });

    testWidgets('loads and displays product when opened via productId',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailsScreen(productId: '1'),
        ),
      );

      await tester.pumpAndSettle();

      final expectedProduct = dummyProducts.firstWhere((p) => p.id == '1');
      expect(find.text(expectedProduct.name), findsOneWidget);
      expect(find.byType(ShareProductButton), findsOneWidget);
    });
  });
}
