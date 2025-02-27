import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/input_field/custom_text_form_field.dart';
import 'package:todo_app/mics/error_box.dart';
import 'package:todo_app/screen/home.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  var autoValidateMode = AutovalidateMode.disabled;
  late String email;
  late String password;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: autoValidateMode,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error.isNotEmpty)
            ErrorBox(content: error)
          else
            const SizedBox(
              height: 0,
            ),
          CustomTextFormField(
            onSaved: (value) {
              email = value!;
            },
            labelText: 'Email',
            icon: Icon(Icons.email),
            textInputAction: TextInputAction.next,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Email.';
              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          CustomTextFormField(
            onChange: (value) {
              setState(
                () {
                  password = value;
                },
              );
            },
            labelText: 'Password',
            icon: Icon(Icons.lock),
            textInputAction: TextInputAction.next,
            isPassword: true,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Password';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300, 40),
              backgroundColor: Colors.blue,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try {
                  // ignore: unused_local_variable
                  final credential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    error = 'No user found for that email.';
                  } else if (e.code == 'wrong-password') {
                    error = 'Wrong password provided for that user.';
                  }
                }
              } else {
                setState(
                  () {
                    autoValidateMode = AutovalidateMode.always;
                  },
                );
              }
            },
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                fontFamily: 'PlayfairDisplay',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
