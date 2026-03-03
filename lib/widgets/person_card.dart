import 'package:flutter/material.dart';
import '../models/person.dart';

class PersonCard extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;
  final double scale;

  const PersonCard({
    super.key,
    required this.person,
    this.isSelected = false,
    this.isHighlighted = false,
    required this.onTap,
    this.scale = 1.0,
  });

  Color get _bgColor {
    if (isSelected) return const Color(0xFF2C6E49);
    if (!isHighlighted) return const Color(0xFFEEEEEE).withOpacity(0.5);
    return person.gender == Gender.male
        ? const Color(0xFF1A3A6B)
        : person.gender == Gender.female
            ? const Color(0xFF6B1A4A)
            : const Color(0xFF4A5568);
  }

  Color get _borderColor {
    if (isSelected) return const Color(0xFF52B788);
    if (!isHighlighted) return Colors.grey.shade400;
    return person.gender == Gender.male
        ? const Color(0xFF4A90D9)
        : person.gender == Gender.female
            ? const Color(0xFFD94A90)
            : const Color(0xFF9F7AEA);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        height: 80,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _borderColor,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _borderColor.withOpacity(isSelected ? 0.6 : 0.2),
              blurRadius: isSelected ? 12 : 4,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _borderColor.withOpacity(0.3),
                    border: Border.all(color: _borderColor, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    person.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  person.gender == Gender.male
                      ? Icons.male
                      : person.gender == Gender.female
                          ? Icons.female
                          : Icons.person,
                  color: _borderColor.withOpacity(0.8),
                  size: 12,
                ),
                if (person.birthDate != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    person.birthDate!,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ],
                if (!person.isAlive) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 10),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
