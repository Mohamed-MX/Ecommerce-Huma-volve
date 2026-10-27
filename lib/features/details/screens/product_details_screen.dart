import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';
import '../../../core/theme.dart';
import '../../home/data/repositories/home_repository_impl.dart';
import '../../home/domain/usecases/get_product_by_id_usecase.dart';
import '../widgets/color_selector.dart';
import '../widgets/share_product_button.dart';
import '../widgets/size_selector.dart';
import '../../../core/widgets/primary_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;
  final String? productId;

  const ProductDetailsScreen({
    super.key,
    this.product,
    this.productId,
  }) : assert(
          product != null || productId != null,
          'Either product or productId must be provided',
        );

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  bool _isLoading = false;
  String? _errorMessage;
  late Color _selectedColor;
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _initProduct(widget.product!);
    } else if (widget.productId != null) {
      _loadProduct(widget.productId!);
    }
  }

  void _initProduct(Product product) {
    _product = product;
    _selectedColor =
        product.colors.isNotEmpty ? product.colors.first : Colors.black;
    _selectedSize = product.sizes.isNotEmpty ? product.sizes.first : 'M';
  }

  Future<void> _loadProduct(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 1. Try finding in dummy products first
    final dummyMatch = dummyProducts.where((p) => p.id == id).firstOrNull;
    if (dummyMatch != null) {
      if (mounted) {
        setState(() {
          _initProduct(dummyMatch);
          _isLoading = false;
        });
      }
      return;
    }

    // 2. Fetch from remote repository via use case
    final numericId = int.tryParse(id);
    if (numericId != null) {
      try {
        final useCase = GetProductByIdUseCase(HomeRepositoryImpl());
        final fetched = await useCase(numericId);
        if (mounted) {
          setState(() {
            _initProduct(fetched);
            _isLoading = false;
          });
        }
        return;
      } catch (e) {
        debugPrint('Error fetching product with ID $id: $e');
      }
    }

    if (mounted) {
      setState(() {
        _errorMessage = 'Could not load product. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Product details unavailable.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.productId != null
                      ? () => _loadProduct(widget.productId!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentProduct = _product!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              backgroundColor: AppTheme.background,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                ShareProductButton(product: currentProduct),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 18),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'product-${currentProduct.id}',
                  child: Image.network(
                    currentProduct.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                transform: Matrix4.translationValues(0.0, -32.0, 0.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              currentProduct.name,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 28,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '\$${currentProduct.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.primary,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentProduct.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Select Color',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ColorSelector(
                        colors: currentProduct.colors,
                        selectedColor: _selectedColor,
                        onColorSelected: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Select Size',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizeSelector(
                        sizes: currentProduct.sizes,
                        selectedSize: _selectedSize,
                        onSizeSelected: (size) {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'Add to Cart',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${currentProduct.name} added to cart'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
