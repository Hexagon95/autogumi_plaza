import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AndroidSafeArea extends StatelessWidget {
  final Widget child;

  const AndroidSafeArea({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return SafeArea(
      top: false,
      bottom: true,
      child: child,
    );
  }
}