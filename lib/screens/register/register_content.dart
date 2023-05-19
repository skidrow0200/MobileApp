import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rsue_food_app/extensions/extension.dart';
import 'package:rsue_food_app/screens/register/widgets/register_form_widget.dart';
import 'package:rsue_food_app/utils/provider/preference_settings_provider.dart';
import 'package:rsue_food_app/utils/utils.dart';
import 'package:rsue_food_app/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../../routes/routes.dart';
import '../welcome/widgets/button_signin_widget.dart';

class RegisterContent extends StatefulWidget {
  const RegisterContent({Key? key}) : super(key: key);

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  late TextEditingController _fullName;
  late TextEditingController _email;
  late TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<bool> _registerUser() async {
    final url = Uri.parse("http://10.0.2.2:5000/register");
    final headers = {'Content-Type': 'application/json'};
    final Map<String, String> jsonBody = {
      "fullname": _fullName.text,
      "email": _email.text,
      "password": _password.text,
    };
    try {
      final http.Response response =
          await http.post(url, headers: headers, body: json.encode(jsonBody));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool status = responseData['success'];

        if (status) {
          // Registration successful
          context.showCustomFlashMessage(
            status: 'success',
            title: 'Вы успешно зарегистрировались!',
            positionBottom: false,
          );
          // Navigate to login screen after a delay
          Future.delayed(const Duration(seconds: 2)).then(
            (_) => Navigator.pushNamed(
              context,
              Routes.loginScreen,
            ),
          );
          return true; // Return true if registration is successful
        } else {
          // Registration failed
          context.showCustomFlashMessage(
            status: 'failed',
            title: 'Регистрация не удалась',
            message: responseData['message'],
            positionBottom: false,
          );
          return false; // Return false if registration fails
        }
      } else {
        // Registration failed
        context.showCustomFlashMessage(
          status: 'failed',
          title: 'Регистрация не удалась',
          message: 'Произошла ошибка при регистрации.',
          positionBottom: false,
        );
        return false; // Return false if registration fails
      }
    } catch (e) {
      // Registration failed
      context.showCustomFlashMessage(
        status: 'failed',
        title: 'Регистрация не удалась',
        message: 'Произошла ошибка: $e',
        positionBottom: false,
      );
      return false; // Return false if registration fails
    }
  }

  void onPressSignUpButton() {
    if (_formState.currentState?.validate() == true) {
      _registerUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = context.theme;

    return Consumer<PreferenceSettingsProvider>(
      builder: (context, preferenceSettingsProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('assets/images/header.png'),
              ],
            ),
            const SizedBox(height: 28.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Sign Up',
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
                    child: RegisterFormWidget(
                      fullNameController: _fullName,
                      emailController: _email,
                      passwordController: _password,
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42.0),
                    child: ButtonWidget(
                      onPress: () => onPressSignUpButton(),
                      title: 'SIGN UP',
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
                        'Already have an account?',
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
                          Routes.loginScreen,
                        ),
                        child: Text(
                          'Sign In',
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
                            'sign up with',
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
            ),
          ],
        );
      },
    );
  }
}
