import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;



class SignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      User? user = FirebaseAuth.instance.currentUser;
      updateUserData(user);
    }on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }
  Future<void> updateUserData(user) async {
    String? token = await FirebaseMessaging.instance.getToken();
    _db.collection('users').add({
      'uid': user.uid,
      'email': user.email,
      'token': token,
      'displayName': user.displayName,
    });
  }


  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAvKXUcLE:APA91bF3JGAa5Y91Gzj5tn6Rsre6Jl9wsaoKAMoDzoRF7ZUVnHikhJjUK3uN9VF9Vhz-AyqnDZ4JZGW-8EKzd1vYqRDR70rcCOoAWcLzc122ek0gdCzmt1428-f77oOmZiKTw1nA-_nI'   },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print("notification sent");
    } catch (e) {
      print("error push notification");
    }
  }

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
