import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/theme_model.dart';

class RoyalPersonCard extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final bool isFocused;
  final bool isDimmed;
  final int? generation;
  final FamilyThemeData theme;
  final CardStyle cardStyle;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const RoyalPersonCard({
    super.key,
    required this.person,
    this.isSelected = false,
    this.isFocused = false,
    this.isDimmed = false,
    this.generation,
    required this.theme,
    required this.cardStyle,
    required this.onTap,
    required this.onDoubleTap,
  });

  Color get _cardBg {
    if (isSelected) return theme.selectedCardBg;
    return person.gender == Gender.male ? theme.maleCardBg : theme.femaleCardBg;
  }

  Color get _borderColor {
    if (isSelected) return theme.selectedCardBorder;
    return person.gender == Gender.male ? theme.maleCardBorder : theme.femaleCardBorder;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Opacity(
        opacity: isDimmed ? 0.25 : 1.0,
        child: _buildByStyle(),
      ),
    );
  }

  Widget _buildByStyle() {
    switch (cardStyle) {
      case CardStyle.royal:
        return _buildRoyalCard();
      case CardStyle.compact:
        return _buildCompactCard();
      case CardStyle.portrait:
        return _buildPortraitCard();
      case CardStyle.minimal:
        return _buildMinimalCard();
    }
  }

  Widget _buildRoyalCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 130,
      constraints: const BoxConstraints(minHeight: 160, maxHeight: 200),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(
          color: isSelected ? theme.selectedCardBorder : theme.cardBorder,
          width: isSelected ? 2.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.selectedCardBorder.withOpacity(0.3)
                : theme.cardShadow,
            blurRadius: isSelected ? 16 : 6,
            offset: const Offset(0, 3),
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Circular avatar
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: person.gender == Gender.male
                      ? theme.maleCardBorder.withOpacity(0.15)
                      : theme.femaleCardBorder.withOpacity(0.15),
                  border: Border.all(
                    color: _borderColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: person.photoUrl != null
                      ? Image.network(
                          person.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildInitialAvatar(),
                        )
                      : _buildInitialAvatar(),
                ),
              ),
              // Generation badge
              if (generation != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.genBadgeBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: _cardBg, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        generation.toString(),
                        style: TextStyle(
                          color: theme.genBadgeText,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              person.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.namePrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Birth - Death
          if (person.birthDate != null || person.deathDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _getDateRange(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.dateColor,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ),
          const SizedBox(height: 4),
          // Focus / Deceased badge
          if (isFocused || !person.isAlive)
            Container(
              margin: const EdgeInsets.only(bottom: 8, top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isFocused
                    ? theme.focusBadgeBg
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isFocused ? 'FOCUS' : '†',
                style: TextStyle(
                  color: isFocused
                      ? theme.focusBadgeText
                      : theme.dateColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCompactCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 160,
      height: 64,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(color: _borderColor, width: isSelected ? 2 : 1),
        boxShadow: [BoxShadow(color: theme.cardShadow, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _borderColor.withOpacity(0.2),
              border: Border.all(color: _borderColor.withOpacity(0.5)),
            ),
            child: ClipOval(child: _buildInitialAvatar()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.namePrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (person.birthDate != null)
                  Text(
                    _getDateRange(),
                    style: TextStyle(color: theme.dateColor, fontSize: 10),
                  ),
              ],
            ),
          ),
          if (generation != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: theme.genBadgeBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(generation.toString(),
                    style: TextStyle(color: theme.genBadgeText, fontSize: 9)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortraitCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 100,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(color: _borderColor, width: isSelected ? 2.5 : 1.5),
        boxShadow: [BoxShadow(color: theme.cardShadow, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large portrait area
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: _borderColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(theme.cardRadius - 1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _borderColor, width: 2),
                  ),
                  child: ClipOval(child: _buildInitialAvatar(size: 28)),
                ),
                if (generation != null)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(color: theme.genBadgeBg, shape: BoxShape.circle),
                      child: Center(child: Text(generation.toString(), style: TextStyle(color: theme.genBadgeText, fontSize: 9, fontWeight: FontWeight.bold))),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(person.name, textAlign: TextAlign.center, maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.namePrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                if (person.birthDate != null)
                  Text(_getDateRange(), textAlign: TextAlign.center,
                      style: TextStyle(color: theme.dateColor, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.selectedCardBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? theme.selectedCardBorder : _borderColor.withOpacity(0.4),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: _borderColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(person.name, style: TextStyle(color: theme.namePrimary, fontSize: 12, fontWeight: FontWeight.w500)),
          if (generation != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: theme.genBadgeBg, borderRadius: BorderRadius.circular(10)),
              child: Text(generation.toString(), style: TextStyle(color: theme.genBadgeText, fontSize: 9)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialAvatar({double size = 22}) {
    final colors = person.gender == Gender.male
        ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
        : [const Color(0xFFC62828), const Color(0xFF880E4F)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: size,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRange() {
    final birth = person.birthDate ?? '';
    final death = person.isAlive ? 'Living' : (person.deathDate ?? '');
    if (birth.isEmpty && death.isEmpty) return '';
    if (birth.isEmpty) return death;
    return '$birth-$death';
  }
}

// Sizes per style
Size cardSize(CardStyle style) {
  switch (style) {
    case CardStyle.royal: return const Size(130, 170);
    case CardStyle.compact: return const Size(160, 64);
    case CardStyle.portrait: return const Size(100, 180);
    case CardStyle.minimal: return const Size(160, 40);
  }
}
