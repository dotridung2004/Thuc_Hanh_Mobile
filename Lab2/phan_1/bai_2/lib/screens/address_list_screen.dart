import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final addresses = addressProvider.addresses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AddAddressScreen()),
              );
            },
          ),
        ],
      ),
      body: addresses.isEmpty
          ? const Center(
        child: Text('No addresses added yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
      )
          : ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (ctx, i) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: ListTile(
            title: Text(addresses[i].recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${addresses[i].addressDetails}, ${addresses[i].ward}, ${addresses[i].district}, ${addresses[i].province}\n${addresses[i].phoneNumber}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => AddAddressScreen(address: addresses[i])),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Thêm dialog xác nhận xóa
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text('Do you want to remove this address?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('No')),
                            TextButton(onPressed: (){
                              addressProvider.deleteAddress(addresses[i].id);
                              Navigator.of(ctx).pop();
                            }, child: const Text('Yes')),
                          ],
                        )
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}