import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../models/store_item_model.dart';
import 'store_details_screen.dart'; // سننشئه لاحقًا

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    
    // جلب الدفعة الأولى من المنتجات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false).fetchInitialPaginatedItems();
    });

    // إضافة مستمع للتمرير لتفعيل الـ Pagination
    _scrollController.addListener(_onScroll);

    // إضافة مستمع للبحث لتفعيل البحث التلقائي بعد التوقف عن الكتابة
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // إذا وصل المستخدم إلى نهاية القائمة، قم بجلب المزيد من البيانات
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      storeProvider.fetchMorePaginatedItems(searchTerm: _searchController.text);
    }
  }

  void _onSearchChanged() {
    // استخدام Debouncer لتجنب إرسال طلبات بحث مع كل حرف يكتبه المستخدم
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      Provider.of<StoreProvider>(context, listen: false)
          .fetchInitialPaginatedItems(searchTerm: _searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final items = storeProvider.items;

    return Column(
      children: [
        // --- شريط البحث ---
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),

        // --- قائمة المنتجات ---
        Expanded(
          child: storeProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? const Center(child: Text('لا توجد منتجات تطابق بحثك.'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: items.length + (storeProvider.hasMore ? 1 : 0), // +1 لعرض مؤشر التحميل
                      itemBuilder: (context, index) {
                        // إذا كان هذا هو العنصر الأخير وهناك المزيد، اعرض مؤشر التحميل
                        if (index == items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final StoreItem item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            leading: SizedBox(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                      )
                                    : const Icon(Icons.image_not_supported),
                              ),
                            ),
                            title: Text(item.name),
                            subtitle: Text('السعر: ${item.price.toStringAsFixed(2)} د.م'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // TODO: الانتقال إلى صفحة تفاصيل المنتج أو المتجر
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailsScreen(storeId: item.supplierId)));
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
