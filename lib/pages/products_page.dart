   import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_provider.dart';
import 'cart_page.dart';
import '../services/auth_service.dart';
import 'profile_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  final List<Product> _products = const []; // We'll use a FutureBuilder or similar for real data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Our Products', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                ),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return cart.itemCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        // For demonstration, we'll use a fixed list if Firestore is empty, 
        // but normally we fetch from FirebaseFirestore.instance.collection('products').snapshots()
        stream: null, 
        builder: (context, snapshot) {
          // Dummy data for now to show the premium design
          final dummyProducts = [
            Product(
              id: '1',
              name: 'Premium Sneakers',
              description: 'Comfortable and stylish sneakers for everyday use.',
              price: 89.99,
              imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
            ),
            Product(
              id: '2',
              name: 'Minimalist Watch',
              description: 'Elegant watch with a clean design and leather strap.',
              price: 129.50,
              imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
            ),
            Product(
              id: '3',
              name: 'Noise Cancelling Headphones',
              description: 'High-quality sound with active noise cancellation.',
              price: 199.99,
              imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
            ),
            Product(
              id: '4',
              name: 'Smart Backpack',
              description: 'Durable backpack with USB charging port and anti-theft features.',
              price: 55.00,
              imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&q=80&w=400',
            ),
          ];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: dummyProducts.length,
            itemBuilder: (context, index) {
              final product = dummyProducts[index];
              return _buildProductCard(context, product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12), // 0.05 * 255 approx 12
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          action: SnackBarAction(
                            label: 'VIEW',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CartPage()),
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
