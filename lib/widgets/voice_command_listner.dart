import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkeasy2/screens/add_parking_screen.dart';
import 'package:parkeasy2/screens/history_user_screen.dart';
import 'package:provider/provider.dart';

import '../providers/speech_provider.dart';

class VoiceCommandListener extends StatelessWidget {
  final Widget child;

  const VoiceCommandListener({super.key, required this.child});

  void _processCommand(BuildContext context, String intent) {
    print('🙏 Global Intent: $intent');

    switch (intent) {
      case "ShowParkingByPrice":
        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryUserScreen()));
        break;

      case "ShowParkingByReview":
        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryUserScreen()));
        break;

      case "ShowBookingHistory":
        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryUserScreen()));
        break;

      case "AddNewSlot":
        User? user = FirebaseAuth.instance.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddParkingScreen(ownerId: user!.uid)));
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sorry, I didn't understand the command.")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, provider, _) {
        print('🌟');
        if (provider.getIntent.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _processCommand(context, provider.getIntent);
            provider.clearIntent();
          });
        }
        return child;
      },
    );
  }
}