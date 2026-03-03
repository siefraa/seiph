import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/person.dart';
import '../models/theme_model.dart';
import '../providers/family_tree_provider.dart';

class TreeNode {
  final Person person;
  double x;
  double y;
  double width;
  double height;
  int generation;

  TreeNode({
    required this.person,
    this.x = 0,
    this.y = 0,
    this.width = 130,
    this.height = 170,
    this.generation = 0,
  });

  Offset get center => Offset(x, y);
  Offset get topCenter => Offset(x, y - height / 2);
  Offset get bottomCenter => Offset(x, y + height / 2);
  Offset get leftCenter => Offset(x - width / 2, y);
  Offset get rightCenter => Offset(x + width / 2, y);
}

class RoyalTreePainter extends CustomPainter {
  final List<TreeNode> nodes;
  final List<Person> persons;
  final String? selectedPersonId;
  final FamilyThemeData theme;
  final bool isHorizontal;

  RoyalTreePainter({
    required this.nodes,
    required this.persons,
    this.selectedPersonId,
    required this.theme,
    this.isHorizontal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Map<String, TreeNode> nodeMap = {for (var n in nodes) n.person.id: n};

    // Draw parent-child lines
    for (final node in nodes) {
      final person = node.person;
      if (person.parentId != null && nodeMap.containsKey(person.parentId)) {
        final parentNode = nodeMap[person.parentId]!;
        _drawParentChildLine(canvas, parentNode, node, nodeMap);
      }
    }

    // Draw spouse connections (dashed line with dot connector)
    final drawnSpouses = <String>{};
    for (final node in nodes) {
      final person = node.person;
      if (person.spouseId != null && nodeMap.containsKey(person.spouseId)) {
        final key = [person.id, person.spouseId!]..sort();
        final keyStr = key.join('-');
        if (!drawnSpouses.contains(keyStr)) {
          drawnSpouses.add(keyStr);
          _drawSpouseConnection(canvas, node, nodeMap[person.spouseId!]!);
        }
      }
    }
  }

  void _drawParentChildLine(Canvas canvas, TreeNode parent, TreeNode child, Map<String, TreeNode> nodeMap) {
    final bool isSelected = selectedPersonId == child.person.id ||
        selectedPersonId == child.person.parentId;

    final paint = Paint()
      ..color = isSelected
          ? theme.selectedCardBorder.withOpacity(0.8)
          : theme.lineColor
      ..strokeWidth = isSelected ? 2.5 : theme.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Determine if parent has a spouse — line comes from midpoint between them
    final parentPerson = parent.person;
    TreeNode? spouse;
    if (parentPerson.spouseId != null && nodeMap.containsKey(parentPerson.spouseId)) {
      spouse = nodeMap[parentPerson.spouseId!];
    }

    Offset startPoint;
    if (isHorizontal) {
      startPoint = parent.rightCenter;
    } else {
      if (spouse != null) {
        // Line comes from midpoint of the couple
        final midX = (parent.x + spouse.x) / 2;
        startPoint = Offset(midX, parent.bottomCenter.dy);
      } else {
        startPoint = parent.bottomCenter;
      }
    }

    Offset endPoint;
    if (isHorizontal) {
      endPoint = child.leftCenter;
    } else {
      endPoint = child.topCenter;
    }

    // Draw an L-shaped or curved connector
    if (isHorizontal) {
      final midX = (startPoint.dx + endPoint.dx) / 2;
      final path = Path()
        ..moveTo(startPoint.dx, startPoint.dy)
        ..cubicTo(midX, startPoint.dy, midX, endPoint.dy, endPoint.dx, endPoint.dy);
      canvas.drawPath(path, paint);
    } else {
      final midY = (startPoint.dy + endPoint.dy) / 2;
      final path = Path()
        ..moveTo(startPoint.dx, startPoint.dy)
        ..lineTo(startPoint.dx, midY)
        ..lineTo(endPoint.dx, midY)
        ..lineTo(endPoint.dx, endPoint.dy);
      canvas.drawPath(path, paint);
    }

    // Junction dot
    canvas.drawCircle(
      isHorizontal ? endPoint : Offset(endPoint.dx, midY(startPoint.dy, endPoint.dy)),
      3.5,
      Paint()..color = isSelected ? theme.selectedCardBorder : theme.lineColor,
    );
  }

  double midY(double a, double b) => (a + b) / 2;

  void _drawSpouseConnection(Canvas canvas, TreeNode node1, TreeNode node2) {
    // Dashed horizontal line between spouses
    final paint = Paint()
      ..color = theme.spouseLineColor
      ..strokeWidth = theme.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset start, end;
    if (isHorizontal) {
      // Vertical dashed line
      if (node1.y < node2.y) {
        start = node1.bottomCenter;
        end = node2.topCenter;
      } else {
        start = node2.bottomCenter;
        end = node1.topCenter;
      }
    } else {
      // Horizontal dashed line
      if (node1.x < node2.x) {
        start = Offset(node1.x + node1.width / 2, node1.y);
        end = Offset(node2.x - node2.width / 2, node2.y);
      } else {
        start = Offset(node2.x + node2.width / 2, node2.y);
        end = Offset(node1.x - node1.width / 2, node1.y);
      }
    }

    // Draw dashed line
    if (theme.dashedSpouseLine) {
      _drawDashedLine(canvas, start, end, paint);
    } else {
      canvas.drawLine(start, end, paint);
    }

    // Draw dot connector in the middle
    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    canvas.drawCircle(
      mid,
      5,
      Paint()
        ..color = theme.spouseLineColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      mid,
      5,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 4.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final unitX = dx / len;
    final unitY = dy / len;
    double dist = 0;
    bool drawing = true;
    while (dist < len) {
      final segLen = drawing ? dashLen : gapLen;
      final nextDist = math.min(dist + segLen, len);
      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + unitX * dist, start.dy + unitY * dist),
          Offset(start.dx + unitX * nextDist, start.dy + unitY * nextDist),
          paint,
        );
      }
      dist = nextDist;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(RoyalTreePainter old) => true;
}

// ─── Layout algorithms ───

List<TreeNode> buildVerticalTree(List<Person> persons, CardStyle style) {
  if (persons.isEmpty) return [];
  final cs = cardSize(style);
  final nodeW = cs.width;
  final nodeH = cs.height;
  const hGap = 30.0;
  const vGap = 80.0;

  final genMap = _computeGenerations(persons);
  final nodes = <String, TreeNode>{};

  for (var p in persons) {
    nodes[p.id] = TreeNode(
      person: p,
      width: nodeW,
      height: nodeH,
      generation: genMap[p.id] ?? 0,
    );
  }

  final roots = persons.where((p) => p.parentId == null || !persons.any((pp) => pp.id == p.parentId)).toList();

  double layoutSubtree(String personId, double startX, double y) {
    final children = persons.where((p) => p.parentId == personId).toList();
    if (children.isEmpty) {
      nodes[personId]!.x = startX + nodeW / 2;
      nodes[personId]!.y = y;
      return startX + nodeW + hGap;
    }
    double childX = startX;
    for (final child in children) {
      childX = layoutSubtree(child.id, childX, y + nodeH + vGap);
    }
    final firstChild = persons.firstWhere((p) => p.parentId == personId && nodes.containsKey(p.id));
    final lastChild = persons.lastWhere((p) => p.parentId == personId && nodes.containsKey(p.id));
    nodes[personId]!.x = (nodes[firstChild.id]!.x + nodes[lastChild.id]!.x) / 2;
    nodes[personId]!.y = y;
    return childX;
  }

  double x = 20;
  for (final root in roots) {
    x = layoutSubtree(root.id, x, 80);
    x += hGap * 2;
  }

  // Position spouses adjacent
  for (final node in nodes.values) {
    final p = node.person;
    if (p.spouseId != null && nodes.containsKey(p.spouseId)) {
      final spouseNode = nodes[p.spouseId]!;
      if (spouseNode.x == 0.0 && spouseNode.y == 0.0) {
        spouseNode.x = node.x + nodeW + hGap;
        spouseNode.y = node.y;
      }
    }
  }

  return nodes.values.toList();
}

List<TreeNode> buildHorizontalTree(List<Person> persons, CardStyle style) {
  if (persons.isEmpty) return [];
  final cs = cardSize(style);
  final nodeW = cs.width;
  final nodeH = cs.height;
  const hGap = 120.0;
  const vGap = 30.0;

  final genMap = _computeGenerations(persons);
  final nodes = <String, TreeNode>{};

  for (var p in persons) {
    nodes[p.id] = TreeNode(
      person: p,
      width: nodeW,
      height: nodeH,
      generation: genMap[p.id] ?? 0,
    );
  }

  final roots = persons.where((p) => p.parentId == null || !persons.any((pp) => pp.id == p.parentId)).toList();

  double layoutSubtree(String personId, double x, double startY) {
    final children = persons.where((p) => p.parentId == personId).toList();
    if (children.isEmpty) {
      nodes[personId]!.x = x;
      nodes[personId]!.y = startY + nodeH / 2;
      return startY + nodeH + vGap;
    }
    double childY = startY;
    for (final child in children) {
      childY = layoutSubtree(child.id, x + nodeW + hGap, childY);
    }
    final firstChild = persons.firstWhere((p) => p.parentId == personId && nodes.containsKey(p.id));
    final lastChild = persons.lastWhere((p) => p.parentId == personId && nodes.containsKey(p.id));
    nodes[personId]!.x = x;
    nodes[personId]!.y = (nodes[firstChild.id]!.y + nodes[lastChild.id]!.y) / 2;
    return childY;
  }

  double y = 20;
  for (final root in roots) {
    y = layoutSubtree(root.id, 80, y);
    y += vGap * 2;
  }

  return nodes.values.toList();
}

Map<String, int> _computeGenerations(List<Person> persons) {
  final result = <String, int>{};
  final personMap = {for (var p in persons) p.id: p};

  int getGen(String id) {
    if (result.containsKey(id)) return result[id]!;
    final p = personMap[id];
    if (p == null || p.parentId == null || !personMap.containsKey(p.parentId)) {
      result[id] = 1;
      return 1;
    }
    final gen = getGen(p.parentId!) + 1;
    result[id] = gen;
    return gen;
  }

  for (final p in persons) {
    getGen(p.id);
  }
  return result;
}

Size cardSize(CardStyle style) {
  switch (style) {
    case CardStyle.royal: return const Size(130, 170);
    case CardStyle.compact: return const Size(165, 64);
    case CardStyle.portrait: return const Size(100, 180);
    case CardStyle.minimal: return const Size(160, 44);
  }
}
