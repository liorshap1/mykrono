import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class PriorityButton extends StatelessWidget {
  final bool isSelected;
  final String label;
  final VoidCallback onPress;

  const PriorityButton({
    super.key,
    required this.isSelected,
    required this.onPress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPress,
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: isSelected ? Colors.blue : context.theme.colors.secondary, width: isSelected ? 3 : 1)
        ),
        foregroundColor: WidgetStatePropertyAll(
          isSelected ? Colors.white : Colors.black,
        ),
        backgroundColor: WidgetStatePropertyAll(
          isSelected ? const Color.fromARGB(255, 13, 72, 161).withValues(alpha: 0.5) : Colors.transparent
        ),
        minimumSize: WidgetStatePropertyAll(const Size.fromHeight(50)),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.white)),
    );
  }
}
