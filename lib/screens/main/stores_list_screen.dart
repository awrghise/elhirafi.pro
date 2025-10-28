import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/store_model.dart';
import '../../services/store_service.dart';
import '../supplier/public_store_screen.dart';

class StoresListScreen extends StatefulWidget {
  const StoresListScreen({super.key});

  @override
  State<StoresListScreen> createState() => _StoresListScreenState();
}

class _StoresListScreenState extends State<StoresListScreen> {
  final StoreService _storeService = StoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: StreamBuilder<List<StoreModel>>(
        stream: _storeService.getAllStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد متاجر متاحة حاليًا.'),
                ],
              ),
            );
          }

          final stores = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLightColor,
                    child: Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text(store.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(store.address),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicStoreScreen(storeId: store.supplierId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
