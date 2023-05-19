import 'package:flutter/material.dart';
import 'package:rsue_food_app/extensions/extension.dart';
import 'package:rsue_food_app/utils/provider/preference_settings_provider.dart';
import 'package:rsue_food_app/utils/provider/token_manager.dart';
import 'package:rsue_food_app/utils/utils.dart';
import 'package:rsue_food_app/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../routes/routes.dart';
import '../welcome/widgets/button_signin_widget.dart';
import 'widgets/login_form_widget.dart';
import 'package:provider/provider.dart';
import 'package:rsue_food_app/utils/provider/user_provider.dart';
import 'dart:convert';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  late TextEditingController _email;
  late TextEditingController _password;
  // Constants
  final String kLoginSuccessTitle = 'Войти успешно!';
  final String kWrongEmailOrPasswordTitle =
      'Неправильный адрес электронной почты или пароль';

  Future<bool> _login(UserProvider userProvider) async {
    final Uri url = Uri.parse('http://10.0.2.2:5000/login');
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {
      'email': _email.text,
      'password': _password.text,
    };
    final String jsonBody = json.encode(body);

    try {
      final http.Response response =
          await http.post(url, headers: headers, body: jsonBody);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final bool status = responseBody['success'];
        if (status) {
          // Successful login
          final String token = responseBody['access_token'];

          // Store token in UserProvider
          userProvider.setEmail(_email.text);
          userProvider.setToken(token);
          userProvider.setIsAuthenticated(true);
          TokenManager.setJwtToken(token);

          return true; // Return true if login is successful
        } else {
          // Failed login
          return false; // Return false if login fails
        }
      } else {
        // Failed request
        return false; // Return false if request fails
      }
    } catch (e) {
      return false; // Return false if exception occurs
    }
  }

  void onPressSignInButton(UserProvider userProvider) async {
    final bool success = await _login(userProvider);
    if (_formState.currentState?.validate() == true && success) {
      context.showCustomFlashMessage(
        status: 'success',
        title: kLoginSuccessTitle,
        positionBottom: false,
      );

      Future.delayed(const Duration(seconds: 1)).then(
        (_) => Navigator.pushReplacementNamed(
          context,
          Routes.homeScreen,
        ),
      );
    } else {
      context.showCustomFlashMessage(
        status: 'failed',
        title: kWrongEmailOrPasswordTitle,
        positionBottom: false,
        message: "Error",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = context.theme;

    return Consumer2<PreferenceSettingsProvider, UserProvider>(
      builder: (context, preferenceSettingsProvider, userProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('assets/images/header.png'),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 37,
                    left: 27,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    enableFeedback: false,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: blackColor80,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 92.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Sign In',
                    style: theme.textTheme.headline4!.copyWith(
                      fontSize: 34,
                      color: preferenceSettingsProvider.isDarkTheme
                          ? grayColor50
                          : blackColor,
                    ),
                  ),
                  const SizedBox(height: 38.0),
                  Form(
                    key: _formState,
                    child: LoginFormWidget(
                      emailController: _email,
                      passwordController: _password,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  Center(
                    child: InkWell(
                      onTap: () =>
                          context.showCustomFlashMessage(status: 'info'),
                      child: Text(
                        'Forgot password?',
                        style: context.theme.textTheme.subtitle2!.copyWith(
                          color: orangeColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42.0),
                    child: ButtonWidget(
                      onPress: () => onPressSignInButton(userProvider),
                      title: 'LOGIN',
                      buttonColor: orangeColor,
                      titleColor: whiteColor,
                      borderColor: orangeColor,
                      paddingHorizontal: 22.0,
                      paddingVertical: 22.0,
                    ),
                  ),
                  const SizedBox(height: 36.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: context.theme.textTheme.subtitle2!.copyWith(
                          color: preferenceSettingsProvider.isDarkTheme
                              ? whiteColor
                              : blackColor20,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.registerScreen,
                        ),
                        child: Text(
                          'Sign Up',
                          style: context.theme.textTheme.subtitle2!.copyWith(
                            color: orangeColor,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: orangeColor,
                            decorationThickness: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: grayColor20,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: Text(
                            'sign in with',
                            style: theme.textTheme.subtitle2!.apply(
                                color: preferenceSettingsProvider.isDarkTheme
                                    ? whiteColor
                                    : blackColor20),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: grayColor20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  const ButtonSigninWith(
                    positionButtom: false,
                  ),
                  const SizedBox(height: 18.0),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
