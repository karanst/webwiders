import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webwiders/services/signin_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user = FirebaseAuth.instance.currentUser;
  final data = FirebaseFirestore.instance.collection('users').snapshots();
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.subscribeToTopic("test");
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: StreamBuilder(
                stream: data,
                //FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, i){
                        DocumentSnapshot ds = snapshot.data!.docs[i];
                      return Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25),
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ds['displayName'],
                              style: const TextStyle(fontSize: 20,
                              fontWeight: FontWeight.w600),),
                              ElevatedButton(onPressed: (){
                                SignInService service = SignInService();
                               service.sendPushMessage(ds['token'], "This is test push notification", "Push Notification" );
                              }, child: Text("Send"))
                            ],
                          ),
                        ),
                      );
                    });
                  }
                  else{
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ElevatedButton(onPressed: (){
            SignInService service = SignInService();
            service.signOutFromGoogle();
            Navigator.pop(context);
          }, child: Text("Sign Out"))
          ],
        )


      //   Center(
      // child: Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text(user!.email!),
      //     Text(user!.displayName!),
      //     CircleAvatar(
      //       backgroundImage: NetworkImage(user!.photoURL!),
      //       radius: 20,
      //     ),
      //     // ListView.builder(
      //     //   itemCount: userData.length,
      //     //     itemBuilder: (context, i){
      //     //   return Container(
      //     //     child: Text(userData[i]),
      //     //   );
      //     // }),
      //     ElevatedButton(onPressed: (){
      //       SignInService service = SignInService();
      //       service.signOutFromGoogle();
      //     }, child: Text("Sign Out"))
      //   ],
      // )
      //   )
      ),
    );
  }
}
