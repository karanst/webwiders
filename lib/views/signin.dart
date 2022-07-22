import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webwiders/services/signin_service.dart';
import 'package:webwiders/views/home.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.deepPurpleAccent,
            fixedSize: Size(200, 50)
          ),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            SignInService service = new SignInService();
            try {
              await service.signInwithGoogle();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
             // Navigator.pushNamedAndRemoveUntil(context, Constants.homeNavigate, (route) => false);
            } catch(e){
              if(e is FirebaseAuthException){
                final snackBar = SnackBar(
                  content:  Text(e.message!),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () {
                    },
                  ),
                );


                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
            setState(() {
              isLoading = false;
            });
          },
          child: isLoading ?
              Container(
                height: 20,
                width: 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text("Login with Google"),
        ),
      ),
    );
  }
}
