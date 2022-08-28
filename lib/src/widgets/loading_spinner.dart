import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
