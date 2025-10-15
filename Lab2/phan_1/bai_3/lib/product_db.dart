import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Product {
  int? id;
  String name;
  double price;
  String description;
  String imagePaths; // Dạng chuỗi, các path cách nhau bằng ; hoặc json
  String category;
  bool hasDiscount;
  String? discountTime; // ISO string

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePaths,
    required this.category,
    required this.hasDiscount,
    this.discountTime,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'description': description,
    'imagePaths': imagePaths,
    'category': category,
    'hasDiscount': hasDiscount ? 1 : 0,
    'discountTime': discountTime,
  };

  static Product fromMap(Map<String, dynamic> map) => Product(
    id: map['id'],
    name: map['name'],
    price: map['price'],
    description: map['description'],
    imagePaths: map['imagePaths'],
    category: map['category'],
    hasDiscount: map['hasDiscount'] == 1,
    discountTime: map['discountTime'],
  );
}

class ProductDatabaseHelper {
  static final ProductDatabaseHelper _instance = ProductDatabaseHelper._();
  static Database? _db;

  ProductDatabaseHelper._();

  factory ProductDatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String dbPath = join(await getDatabasesPath(), 'product.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            description TEXT,
            imagePaths TEXT,
            category TEXT,
            hasDiscount INTEGER,
            discountTime TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'id DESC');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}