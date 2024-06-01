import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String text;

  const ErrorText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}
