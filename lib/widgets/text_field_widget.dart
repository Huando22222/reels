// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool? isValid;
  final IconData icon;
  final Widget? trailing;
  const TextFieldWidget({
    super.key,
    required this.controller,
    this.hintText,
    this.isValid = true,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isValid! ? Colors.grey : Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            color:
                isValid! ? Colors.black : Theme.of(context).colorScheme.error,
            size: 24.0,
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          if (trailing != null) trailing!
        ],
      ),
    );
  }
}
