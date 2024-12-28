import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_app/input_field/custom_text_form_field.dart';
import 'package:todo_app/mics/error_box.dart';
import 'package:todo_app/screen/home.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  var autoValidateMode = AutovalidateMode.disabled;
  late String email;
  late String name;
  late String password;
  late String confirmPassword;
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
            SizedBox(
              height: 0,
            ),
          CustomTextFormField(
            onSaved: (value) {
              name = value!;
            },
            autoValidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Name.';
              } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                return 'Name must be English Letters';
              }
              return null;
            },
            labelText: 'Name',
            icon: Icon(FontAwesomeIcons.user),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(
            height: 13,
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
                return 'valid email address';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 15,
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
            height: 13,
          ),
          CustomTextFormField(
            onChange: (value) {
              setState(
                () {
                  confirmPassword = value;
                },
              );
            },
            labelText: 'Repeat Password',
            icon: Icon(Icons.lock),
            textInputAction: TextInputAction.done,
            isPassword: true,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              } else if (value != password) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 13,
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                autoValidateMode = AutovalidateMode.disabled;
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await FirebaseAuth.instance.currentUser
                      ?.sendEmailVerification();

                  await credential.user?.updateDisplayName(name);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    error = 'The password provided is too weak.';
                  } else if (e.code == 'email-already-in-use') {
                    error = 'The account already exists for that email.';
                  }
                } catch (e) {
                  error = e.toString();
                }
              } else {
                autoValidateMode = AutovalidateMode.onUserInteraction;
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300, 40),
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Sign Up',
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
