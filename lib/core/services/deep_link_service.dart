import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../features/details/screens/product_details_screen.dart';

/// Service responsible for managing deep links and navigating to products
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  static const String appScheme = 'ecommerce';
  static const String webHost = 'ecommerceapp.com';

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Helper to generate a deep link URL for a product
  static String buildProductDeepLink(String productId, {bool useWebUrl = true}) {
    if (useWebUrl) {
      return 'https://$webHost/product/$productId';
    }
    return '$appScheme://product/$productId';
  }

  /// Initialize deep linking with navigatorKey
  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // 1. Handle app launch from cold start with deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error retrieving initial link: $e');
    }

    // 2. Handle deep links while app is running in foreground/background
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        handleUri(uri);
      },
      onError: (err) {
        debugPrint('DeepLinkService: Error listening to uriLinkStream: $err');
      },
    );
  }

  /// Extracts the product ID from various URI formats:
  /// - https://ecommerceapp.com/product/123
  /// - https://ecommerceapp.com/product?id=123
  /// - ecommerce://product/123
  /// - ecommerce://product?id=123
  static String? extractProductId(Uri uri) {
    // Check query parameter ?id=...
    if (uri.queryParameters.containsKey('id')) {
      final id = uri.queryParameters['id'];
      if (id != null && id.trim().isNotEmpty) return id.trim();
    }

    // Check path segments (e.g. /product/123 or /products/123)
    final segments = uri.pathSegments;
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i].toLowerCase();
      if ((seg == 'product' || seg == 'products') && i + 1 < segments.length) {
        final id = segments[i + 1].trim();
        if (id.isNotEmpty) return id;
      }
    }

    // Check host as 'product' with segment ID (ecommerce://product/123)
    if (uri.host.toLowerCase() == 'product' && segments.isNotEmpty) {
      final id = segments.first.trim();
      if (id.isNotEmpty) return id;
    }

    return null;
  }

  /// Handle an incoming deep link URI
  void handleUri(Uri uri) {
    debugPrint('DeepLinkService: Received URI: $uri');
    final productId = extractProductId(uri);
    if (productId != null) {
      openProduct(productId);
    }
  }

  /// Open product details screen in the app
  void openProduct(String productId) {
    final navState = _navigatorKey?.currentState;
    if (navState == null) {
      // Retry on next frame if navigator isn't mounted yet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openProduct(productId);
      });
      return;
    }

    navState.push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: productId,
        ),
      ),
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
