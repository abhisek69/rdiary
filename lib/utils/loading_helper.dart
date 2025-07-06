import 'package:flutter/material.dart';
import '../widgets/loading_screen.dart'; // Adjust path accordingly

void showLoadingScreen(BuildContext context, {String message = 'Please wait...'}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 0,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 20),
            Text(message, style: (TextStyle(color: Colors.black)),),
          ],
        ),
      );
    },
  );
}

void hideLoadingScreen(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop(); // Close the loading screen
}
