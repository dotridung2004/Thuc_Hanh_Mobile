import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductFilterScreen extends StatelessWidget {
  const ProductFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // NumberFormat để định dạng giá tiền
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lọc sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // PHẦN BỘ LỌC
            _buildFilterSection(context),
            const Divider(height: 32, thickness: 1),
            // PHẦN KẾT QUẢ
            const Text('Kết quả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (ctx, provider, _) {
                  if (provider.filteredProducts.isEmpty) {
                    return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
                  }
                  return ListView.builder(
                    itemCount: provider.filteredProducts.length,
                    itemBuilder: (ctx, index) {
                      final product = provider.filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.imageUrl.startsWith('http')
                                ? Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                                : Image.file(File(product.imageUrl), width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(product.category),
                          trailing: Text(
                            currencyFormatter.format(product.price),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    return SingleChildScrollView( // Cho phép cuộn nếu bộ lọc quá dài
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lọc theo giá
          const Text('Giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: provider.fromPriceController,
                  decoration: const InputDecoration(labelText: 'Từ', hintText: '0'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: provider.toPriceController,
                  decoration: const InputDecoration(labelText: 'Đến', hintText: '1.000.000'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lọc theo danh mục
          const Text('Danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Consumer<ProductProvider>( // Dùng Consumer để rebuild khi chọn
            builder: (ctx, provider, _) => Wrap(
              spacing: 8.0,
              children: provider.allCategories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: provider.selectedCategories.contains(category),
                  onSelected: (selected) {
                    provider.toggleCategory(category);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Sắp xếp
          const Text('Xếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Consumer<ProductProvider>(
            builder: (ctx, provider, _) => DropdownButtonFormField<String>(
              value: provider.selectedSortBy,
              items: provider.sortOptions.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setSortBy(value);
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Nút bấm
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.resetFilters();
                  },
                  child: const Text('Đặt lại'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    provider.applyFilters();
                  },
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}