import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 64.0,
      child: Center(
        child: SizedBox(
          child: SizedBox(
            height: 32.0,
            width: 32.0,
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}
