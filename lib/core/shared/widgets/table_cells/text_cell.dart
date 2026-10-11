import 'package:flutter/material.dart';

class TextCell extends StatelessWidget {
  final Widget string;
  final Widget? subString;

  const TextCell({required this.string,this.subString,super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        string,
        (subString !=null)?subString!:SizedBox()
      ],
    );
  }
}
