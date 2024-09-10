import 'package:flutter/material.dart';
import 'package:taskmanager/view/home_page.dart'; 

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Homescreen(), 
        ),
      );
    });

    return Scaffold(
      backgroundColor:
          Color.fromARGB(202, 101, 224, 117), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/cf-flow-2lrlDbTI5af8pOIVVwt2QrXfOW5.png', // Correct path
              width: 150, 
              height: 150, 
            ),
            SizedBox(height: 20), 
            Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
