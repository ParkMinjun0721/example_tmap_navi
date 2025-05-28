// point_shop_view.dart
// Updated point_shop_view.dart with a cleaner and more modern design in blue theme
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/font.dart';
import '../../theme/theme.dart';
import '../../viewmodels/point_provider.dart';
import '../../viewmodels/product_provider.dart';
import '../../models/product.dart';
import '../../models/purchased_product.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';

class PointShopView extends ConsumerStatefulWidget {
  const PointShopView({super.key});

  @override
  ConsumerState<PointShopView> createState() => _PointShopViewState();
}

class _PointShopViewState extends ConsumerState<PointShopView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final point = ref.watch(pointProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'PointShop',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '$point P',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const _PointShopSearchSection(),
            const SizedBox(height: 16),
            _PointShopTabSection(tabController: _tabController),
          ],
        ),
      ),
    );
  }
}

class _PointShopSearchSection extends StatelessWidget {
  const _PointShopSearchSection();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search products',
        prefixIcon: const Icon(Icons.search, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _PointShopTabSection extends ConsumerWidget {
  final TabController tabController;

  const _PointShopTabSection({required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(couponProductProvider);
    final couponProducts = allProducts.where((p) => p.category == ProductCategory.coupon).toList();
    final goodsProducts = allProducts.where((p) => p.category == ProductCategory.goods).toList();

    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            indicatorColor: Colors.transparent,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            labelStyle: pretendardBold(context).copyWith(fontSize: 14),
            tabs: const [
              Tab(text: 'Coupon'),
              Tab(text: 'Goods'),
              Tab(text: 'Exchange'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _ProductGridSection(products: couponProducts),
                _ProductGridSection(products: goodsProducts),
                const Center(child: Text("Cash exchange page coming soon")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGridSection extends ConsumerWidget {
  final List<Product> products;
  const _ProductGridSection({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final point = ref.watch(pointProvider);
    final pointController = ref.read(pointProvider.notifier);
    final purchaseHistory = ref.read(purchaseHistoryProvider.notifier);

    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final bool canPurchase = point >= product.point;

        return Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: canPurchase ? () {} : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Text('Image')),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: pretendardMedium(context)),
                      const SizedBox(height: 4),
                      Text('${product.point} P', style: pretendardRegular(context)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canPurchase ? Colors.blue : Colors.grey[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: canPurchase
                              ? () {
                            final success = pointController.purchase(product.point);
                            if (success) {
                              purchaseHistory.add(PurchasedProduct(name: product.name, point: product.point));
                            }
                          }
                              : null,
                          child: const Text('Purchase'),
                        ),
                      )
                    ],
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
