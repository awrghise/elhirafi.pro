import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../models/store_model.dart';
import 'store_details_screen.dart'; // سننشئه في الخطوة الأخيرة

class StoresTabScreen extends StatefulWidget {
  const StoresTabScreen({super.key});

  @override
  State<StoresTabScreen> createState() => _StoresTabScreenState();
}

class _StoresTabScreenState extends State<StoresTabScreen> {
  @override
  void initState() {
    super.initState();
    // جلب قائمة المتاجر عند فتح الشاشة لأول مرة
    // نستخدم listen: false داخل initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false).fetchStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final stores = storeProvider.stores;

    return storeProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : stores.isEmpty
            ? const Center(child: Text('لا توجد متاجر متاحة حاليًا.'))
            : GridView.builder(
                padding: const EdgeInsets.all(12.0),
                // --- تحديد شكل الشبكة ---
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عدد الأعمدة
                  crossAxisSpacing: 12.0, // المسافة الأفقية بين العناصر
                  mainAxisSpacing: 12.0,  // المسافة العمودية بين العناصر
                  childAspectRatio: 0.9,  // نسبة العرض إلى الارتفاع لكل عنصر
                ),
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final StoreModel store = stores[index];
                  return GestureDetector(
                    onTap: () {
                      // --- الانتقال إلى شاشة تفاصيل المتجر عند الضغط ---
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => StoreDetailsScreen(store: store),
                         ),
                       );
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.antiAlias, // لضمان أن الصورة تلتزم بحواف الكارد
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- صورة المتجر ---
                          Expanded(
                            flex: 3,
                            child: store.storeName.isNotEmpty // يمكنك استخدام صورة المتجر هنا إذا أضفتها للنموذج
                                ? Center(child: Text(store.storeName[0], style: const TextStyle(fontSize: 40, color: Colors.grey))) // حل مؤقت: عرض أول حرف من اسم المتجر
                                : const Icon(Icons.store, size: 50, color: Colors.grey),
                          ),
                          // --- اسم المتجر ---
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.black.withOpacity(0.05),
                              child: Center(
                                child: Text(
                                  store.storeName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
