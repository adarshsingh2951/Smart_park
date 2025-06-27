import 'package:flutter/material.dart';

// Responsive padding
EdgeInsets responsivePadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 900) {
    return const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0);
  } else if (width >= 600) {
    return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0);
  } else {
    return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  }
}
