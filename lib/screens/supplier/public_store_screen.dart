import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/store_model.dart';
import '../../models/product_model.dart';
import '../../services/store_service.dart';

class PublicStoreScreen extends StatefulWidget {
  final String storeId;

  const PublicStoreScreen({super.key, required this.storeId});

  @override
  State<PublicStoreScreen> createState() => _PublicStoreScreenState();
}

class _PublicStoreScreenState extends State<PublicStoreScreen> {
  final StoreService _storeService = StoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<StoreModel?>(
        future: _storeService.getStoreBySupplier(widget.storeId),
        builder: (context, storeSnapshot) {
          if (storeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!storeSnapshot.hasData || storeSnapshot.data == null) {
            return const Center(child: Text('لم يتم العثور على المتجر.'));
          }

          final store = storeSnapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(store.storeName, style: const TextStyle(color: Colors.white)),
                  background: const Icon(
                    Icons.storefront,
                    size: 100,
                    color: Colors.white54,
                  ), // يمكنك إضافة صورة للمتجر هنا لاحقًا
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.description, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(store.address, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(store.phoneNumber, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Divider(height: 32),
                      const Text(
                        'المنتجات المتوفرة',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<List<ProductModel>>(
                stream: _storeService.getProductsByStore(store.supplierId),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  }
                  if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('لا توجد منتجات في هذا المتجر حاليًا.'),
                        ),
                      ),
                    );
                  }

                  final products = productSnapshot.data!;
                  return SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return _buildProductCard(product);
                        },
                        childCount: products.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: product.imageUrls.isNotEmpty
                ? Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price} درهم',
                  style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
