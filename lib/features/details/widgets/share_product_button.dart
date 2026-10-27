import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/dummy_data.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../core/theme.dart';

/// Reusable button widget that shares product details with a deep link
class ShareProductButton extends StatelessWidget {
  final Product product;
  final Color? iconColor;
  final double iconSize;

  const ShareProductButton({
    super.key,
    required this.product,
    this.iconColor,
    this.iconSize = 18,
  });

  /// Build the product deep link URL
  static String generateProductDeepLink(String productId) {
    return DeepLinkService.buildProductDeepLink(productId);
  }

  /// Generate share message text containing title, price, and deep link
  static String generateShareText(Product product) {
    final link = generateProductDeepLink(product.id);
    return 'Check out "${product.name}" on Huma-volve for \$${product.price.toStringAsFixed(2)}!\n$link';
  }

  Future<void> _handleShare(BuildContext context) async {
    final text = generateShareText(product);
    final subject = 'Check out ${product.name}';

    // Position origin for iPads, tablets, and desktop popovers
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing product: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open share dialog: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Share product',
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.share_outlined,
          size: iconSize,
          color: iconColor ?? AppTheme.textPrimary,
        ),
      ),
      onPressed: () => _handleShare(context),
    );
  }
}
