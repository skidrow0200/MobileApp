import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:rsue_food_app/extensions/extension.dart';
import 'package:rsue_food_app/utils/provider/token_manager.dart';
import 'package:rsue_food_app/utils/provider/user_provider.dart';
import 'package:rsue_food_app/utils/utils.dart';
import '../../../utils/provider/preference_settings_provider.dart';

class CardProfileWidget extends StatefulWidget {
  final PreferenceSettingsProvider preferenceSettingsProvider;

  const CardProfileWidget({
    Key? key,
    required this.preferenceSettingsProvider,
  }) : super(key: key);

  @override
  _CardProfileWidgetState createState() => _CardProfileWidgetState();
}

class _CardProfileWidgetState extends State<CardProfileWidget> {
  Map<String, dynamic>? userData;

  Future<void> _getUserData(String? email, String? jwtToken) async {
    if (email == null) return;

    final url = Uri.parse('http://10.0.2.2:5000/users/$email');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        userData = jsonResponse;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  void initState() {
    super.initState();

    final userEmail = Provider.of<UserProvider>(context, listen: false).email;
    final jwtToken = Provider.of<UserProvider>(context, listen: false).token;
    _getUserData(userEmail, jwtToken);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = context.theme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.person_pin_rounded,
              color: widget.preferenceSettingsProvider.isDarkTheme
                  ? grayColor20
                  : grayColor80,
              size: 18,
            ),
            const SizedBox(width: 5),
            Text(
              'Data Profile',
              style: theme.textTheme.headline4!.copyWith(
                fontSize: 18,
                color: widget.preferenceSettingsProvider.isDarkTheme
                    ? grayColor20
                    : grayColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.preferenceSettingsProvider.isDarkTheme
                ? blackColor80
                : whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                spreadRadius: 0,
                color: widget.preferenceSettingsProvider.isDarkTheme
                    ? blackColor80
                    : grayColor50,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: userData != null
              ? Column(
                  children: [
                    if (userData?['fullname'] != null)
                      const SizedBox(height: 15),
                    DataProfile(
                      preferenceSettingsProvider:
                          widget.preferenceSettingsProvider,
                      icon: const Icon(
                        Icons.credit_card,
                        size: 15,
                        color: whiteColor,
                      ),
                      title: userData!['fullname'] ?? '',
                    ),
                    if (userData?['email'] != null) const SizedBox(height: 15),
                    DataProfile(
                      preferenceSettingsProvider:
                          widget.preferenceSettingsProvider,
                      icon: const Icon(
                        Icons.email,
                        size: 15,
                        color: whiteColor,
                      ),
                      title: userData!['email'] ?? '',
                    ),
                    if (userData?['phone'] != null) const SizedBox(height: 15),
                    DataProfile(
                      preferenceSettingsProvider:
                          widget.preferenceSettingsProvider,
                      icon: const Icon(
                        Icons.phone,
                        size: 15,
                        color: whiteColor,
                      ),
                      title: "+795555623535",
                    ),
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ],
    );
  }
}

class DataProfile extends StatelessWidget {
  final PreferenceSettingsProvider preferenceSettingsProvider;

  const DataProfile({
    Key? key,
    required this.preferenceSettingsProvider,
    required this.icon,
    required this.title,
  }) : super(key: key);

  final Icon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = context.theme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: yellowColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                spreadRadius: 0,
                color: preferenceSettingsProvider.isDarkTheme
                    ? blackColor50
                    : orangeColor20,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: icon,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.headline4!.copyWith(
              fontSize: 14,
              color: preferenceSettingsProvider.isDarkTheme
                  ? grayColor20
                  : grayColor,
            ),
          ),
        )
      ],
    );
  }
}
