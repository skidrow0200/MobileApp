import 'package:flutter/material.dart';
import 'package:rsue_food_app/data/models/restaurant_detail.dart';
import 'package:rsue_food_app/utils/helper/database_helper.dart';
import 'package:rsue_food_app/utils/provider/response_state.dart';
import 'package:rsue_food_app/utils/provider/user_provider.dart';

class RestaurantFavoriteProvider extends ChangeNotifier {
  final DatabaseHelper databaseHelper;
  final UserProvider userProvider;

  RestaurantFavoriteProvider({
    required this.databaseHelper,
    required this.userProvider,
  }) {
    _getRestaurantFavorite(userProvider.email ?? '', userProvider.token ?? '');
  }

  late ResponseState _state;
  ResponseState get state => _state;

  String _message = '';
  String get message => _message;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  List<RestaurantDetail> _favorite = [];
  List<RestaurantDetail> get favorite => _favorite;

  void _getRestaurantFavorite(String email, String token) async {
    _favorite = await databaseHelper.getFavorite(email, token);

    if (_favorite.isNotEmpty) {
      _state = ResponseState.hasData;
      _message = 'Data Found';
    } else {
      _state = ResponseState.noData;
      _message = 'Empty Data';
    }
    notifyListeners();
  }

  void addResturantFavorite(
      RestaurantDetail restaurantDetail, String email, String token) async {
    try {
      await databaseHelper.insertFavorite(restaurantDetail, email, token);
      _getRestaurantFavorite(email, token);
    } catch (e) {
      _state = ResponseState.error;
      _message = '$e';
      notifyListeners();
    }
  }

  Future<bool> isRestaurantFavorite(String id) async {
    final resFav = await databaseHelper.getFavoriteById(id);
    _isFavorite = resFav.isNotEmpty;
    return resFav.isNotEmpty;
  }

  void removeRestaurantFavorite(String id, String email, String token) async {
    try {
      await databaseHelper.removeFavorite(id, email, token);
      _getRestaurantFavorite(email, token);
    } catch (e) {
      _state = ResponseState.error;
      _message = '$e';
      notifyListeners();
    }
  }
}
