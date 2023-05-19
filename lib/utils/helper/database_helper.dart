import 'package:rsue_food_app/data/models/restaurant_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static late Database _database;

  DatabaseHelper._internal() {
    _instance = this;
  }

  factory DatabaseHelper() => _instance ?? DatabaseHelper._internal();

  static const String _tableRestaurantFavorite = 'restaurantFavorite';

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      '$path/restaurant-favorite.db',
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableRestaurantFavorite (
            id TEXT PRIMARY KEY,
            name TEXT,
            city TEXT,
            pictureId TEXT,
            rating REAL
          )
        ''');
      },
      version: 1,
    );
    return db;
  }

  Future<Database> get database async {
    _database = await _initializeDb();
    return _database;
  }

  Future<void> insertFavorite(
      RestaurantDetail restaurantDetail, String email, String token) async {
    final db = await database;
    final insert = await db.insert(
      _tableRestaurantFavorite,
      restaurantDetail.toMap(),
    );
    print('Add Favorite $insert');

    try {
      final headers = {'Authorization': 'Bearer $token'};
      final Map<String, String> body = {
        'id': restaurantDetail.id,
        'title': restaurantDetail.name,
        'description': restaurantDetail.description ?? "",
        "url": restaurantDetail.pictureId
      };
      final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/users/$email/favorites'),
          headers: headers,
          body: jsonEncode(body));

      if (response.statusCode != 201) {
        throw Exception('Failed to save favorite');
      }

      print('Favorite saved successfully');
    } catch (e) {
      print('Error saving favorite: $e');
    }
  }

  Future<List<RestaurantDetail>> getFavorite(String email, String token) async {
    final db = await database;
    List<Map<String, dynamic>> results =
        await db.query(_tableRestaurantFavorite);

    final getList =
        results.map((res) => RestaurantDetail.fromMap(res)).toList();

    final headers = {'Authorization': 'Bearer $token'};
    final response = await http
        .get(Uri.parse("http://10.0.2.2:5000/users/$email"), headers: headers);

    if (response.statusCode == 200) {
      return getList;
    }

    return getList;
  }

  Future<Map> getFavoriteById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      _tableRestaurantFavorite,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return {};
    }
  }

  Future<void> updateFavorite(RestaurantDetail restaurantDetail) async {
    final db = await database;

    final update = await db.update(
      _tableRestaurantFavorite,
      restaurantDetail.toMap(),
      where: 'id = ?',
      whereArgs: [restaurantDetail.id],
    );
    print('Update Favorite $update');
  }

  Future<void> removeFavorite(String id, String email, String token) async {
    final db = await database;
    final headers = {'Authorization': 'Bearer $token'};
    final delete = await db.delete(
      _tableRestaurantFavorite,
      where: 'id = ?',
      whereArgs: [id],
    );
    try {
      await http.delete(
          Uri.parse("http://10.0.2.2:5000/users/$email/favorites/$id"),
          headers: headers);
    } catch (e) {
      print(e);
    }

    print('Delete Favorite $delete');
  }
}
