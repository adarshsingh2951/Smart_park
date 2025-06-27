// import 'package:flutter/material.dart';
// import 'noti_service.dart';
//
// class NotifiHandler extends StatefulWidget {
//   const NotifiHandler({super.key});
//
//   @override
//   State<NotifiHandler> createState() => _NotifiHandlerState();
// }
//
// class _NotifiHandlerState extends State<NotifiHandler> {
//   final TextEditingController _hourController = TextEditingController();
//   final TextEditingController _minController = TextEditingController();
//   final NotiService _notiService = NotiService();
//
//   @override
//   void initState() {
//     super.initState();
//     _notiService.initNotification();
//   }
//
//   void _handleInstantNotification() {
//     _notiService.showNotification(
//       title: 'Instant Notification',
//       body: 'Step 1 Done',
//     );
//   }
//
//   void _handleScheduledNotification() {
//     _notiService.scheduleNotificationBefore20Min(
//       _hourController,
//       _minController,
//     );
//   }
//
//   void _scheduleFixedTimeNotification() {
//     _notiService.scheduleNotification(
//       title: 'Fixed Time Notification',
//       body: 'Step 3 Done',
//       hour: 12,
//       min: 30,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Notification Handler")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: _handleInstantNotification,
//               child: const Text("Instant Notification"),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _hourController,
//               decoration: const InputDecoration(labelText: 'Hour'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: _minController,
//               decoration: const InputDecoration(labelText: 'Minute'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: _handleScheduledNotification,
//               child: const Text("Schedule 20 Min Before"),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: _scheduleFixedTimeNotification,
//               child: const Text("Fixed Time Notification"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
