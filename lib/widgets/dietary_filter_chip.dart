import 'package:flutter/material.dart';
import '../models/establishment.dart';
import '../utils/translations.dart';

class DietaryFilterChip extends StatelessWidget {
  final DietaryFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const DietaryFilterChip({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: filter == DietaryFilter.halal
        ? () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(Translations.getText(context, 'halalExplanationTitle')),
                content: Text(Translations.getText(context, 'halalExplanationBody')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(Translations.getText(context, 'close')),
                  ),
                ],
              ),
            );
          }
        : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.green.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          filter.getLabel(context),
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.green.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}


