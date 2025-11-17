
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AddButtonCard extends StatelessWidget {
  final VoidCallback? onTap;
  const AddButtonCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 150,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colors.background,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: context.theme.colors.foreground.withValues(alpha: 0.2),
              width: 1,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: Center(child: Icon(Icons.add, size: 28, color: Colors.white)),
        ),
      ),
    );
  }
}
