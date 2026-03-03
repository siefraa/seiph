import 'package:flutter/material.dart';
import '../models/person.dart';
import '../providers/family_tree_provider.dart';

class TreeNode {
  final Person person;
  double x;
  double y;
  double width;
  double height;

  TreeNode({
    required this.person,
    this.x = 0,
    this.y = 0,
    this.width = 150,
    this.height = 80,
  });

  Rect get rect => Rect.fromCenter(
        center: Offset(x, y),
        width: width,
        height: height,
      );
}

class TreePainter extends CustomPainter {
  final List<TreeNode> nodes;
  final List<Person> persons;
  final String? selectedPersonId;
  final bool isHorizontal;

  TreePainter({
    required this.nodes,
    required this.persons,
    this.selectedPersonId,
    this.isHorizontal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final spousePaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final selectedLinePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Map<String, TreeNode> nodeMap = {for (var n in nodes) n.person.id: n};

    // Draw connections
    for (final node in nodes) {
      final person = node.person;

      // Parent-child connection
      if (person.parentId != null && nodeMap.containsKey(person.parentId)) {
        final parentNode = nodeMap[person.parentId]!;
        final isSelected = selectedPersonId == person.id ||
            selectedPersonId == person.parentId;
        final paint = isSelected ? selectedLinePaint : linePaint;

        if (isHorizontal) {
          _drawHorizontalConnection(canvas, parentNode, node, paint);
        } else {
          _drawVerticalConnection(canvas, parentNode, node, paint);
        }
      }

      // Spouse connection
      if (person.spouseId != null && nodeMap.containsKey(person.spouseId)) {
        final spouseNode = nodeMap[person.spouseId]!;
        if (person.id.compareTo(person.spouseId!) < 0) {
          final path = Path();
          if (isHorizontal) {
            final midY = (node.y + spouseNode.y) / 2;
            path.moveTo(node.x + node.width / 2, node.y);
            path.cubicTo(
              node.x + node.width / 2 + 30, node.y,
              spouseNode.x + spouseNode.width / 2 + 30, spouseNode.y,
              spouseNode.x + spouseNode.width / 2, spouseNode.y,
            );
          } else {
            path.moveTo(node.x + node.width / 2, node.y);
            path.quadraticBezierTo(
              (node.x + spouseNode.x) / 2 + node.width / 2,
              node.y - 15,
              spouseNode.x + spouseNode.width / 2,
              spouseNode.y,
            );
          }
          // Heart connector line
          final start = Offset(node.x + node.width / 2, node.y);
          final end = Offset(spouseNode.x + spouseNode.width / 2, spouseNode.y);
          if (isHorizontal) {
            canvas.drawLine(
              Offset(node.x + node.width / 2, node.y),
              Offset(spouseNode.x + spouseNode.width / 2, spouseNode.y),
              spousePaint,
            );
          } else {
            canvas.drawLine(
              Offset(node.x + node.width / 2, node.y),
              Offset(spouseNode.x + spouseNode.width / 2, spouseNode.y),
              spousePaint,
            );
          }
        }
      }
    }
  }

  void _drawVerticalConnection(
      Canvas canvas, TreeNode parent, TreeNode child, Paint paint) {
    final startX = parent.x + parent.width / 2;
    final startY = parent.y + parent.height / 2;
    final endX = child.x + child.width / 2;
    final endY = child.y - child.height / 2;
    final midY = (startY + endY) / 2;

    final path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(startX, midY, endX, midY, endX, endY);
    canvas.drawPath(path, paint);
  }

  void _drawHorizontalConnection(
      Canvas canvas, TreeNode parent, TreeNode child, Paint paint) {
    final startX = parent.x + parent.width / 2;
    final startY = parent.y;
    final endX = child.x - child.width / 2;
    final endY = child.y;
    final midX = (startX + endX) / 2;

    final path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(midX, startY, midX, endY, endX, endY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) =>
      oldDelegate.nodes != nodes || oldDelegate.selectedPersonId != selectedPersonId;
}

// Helper to build a positioned tree
List<TreeNode> buildVerticalTree(List<Person> persons, {double nodeW = 150, double nodeH = 80}) {
  if (persons.isEmpty) return [];
  
  const hGap = 40.0;
  const vGap = 120.0;
  final nodes = <String, TreeNode>{};
  
  // Create nodes
  for (var p in persons) {
    nodes[p.id] = TreeNode(person: p, width: nodeW, height: nodeH);
  }
  
  // Build adjacency - find roots
  final roots = persons.where((p) => p.parentId == null || !persons.any((pp) => pp.id == p.parentId)).toList();
  
  double _layoutSubtree(List<Person> children, double startX, double y, Map<String, TreeNode> nodes) {
    double currentX = startX;
    for (final child in children) {
      final childChildren = persons.where((p) => p.parentId == child.id).toList();
      if (childChildren.isEmpty) {
        nodes[child.id]!.x = currentX + nodeW / 2;
        nodes[child.id]!.y = y;
        currentX += nodeW + hGap;
      } else {
        final subtreeStart = currentX;
        currentX = _layoutSubtree(childChildren, currentX, y + vGap, nodes);
        final subtreeEnd = currentX;
        nodes[child.id]!.x = (subtreeStart + subtreeEnd - hGap) / 2;
        nodes[child.id]!.y = y;
      }
    }
    return currentX;
  }
  
  double startX = 20;
  for (final root in roots) {
    final children = persons.where((p) => p.parentId == root.id).toList();
    if (children.isEmpty) {
      nodes[root.id]!.x = startX + nodeW / 2;
      nodes[root.id]!.y = 60;
      startX += nodeW + hGap;
    } else {
      final before = startX;
      startX = _layoutSubtree(children, startX, 60 + vGap, nodes);
      nodes[root.id]!.x = (before + startX - hGap) / 2;
      nodes[root.id]!.y = 60;
    }
    startX += hGap;
  }
  
  // Layout spouses side by side
  for (var p in persons) {
    if (p.spouseId != null && nodes.containsKey(p.spouseId)) {
      final pNode = nodes[p.id]!;
      final sNode = nodes[p.spouseId!]!;
      if (sNode.x == 0 && sNode.y == 0) {
        sNode.x = pNode.x + nodeW + 20;
        sNode.y = pNode.y;
      }
    }
  }
  
  return nodes.values.toList();
}

List<TreeNode> buildHorizontalTree(List<Person> persons, {double nodeW = 150, double nodeH = 80}) {
  if (persons.isEmpty) return [];
  
  const hGap = 160.0;
  const vGap = 50.0;
  final nodes = <String, TreeNode>{};
  
  for (var p in persons) {
    nodes[p.id] = TreeNode(person: p, width: nodeW, height: nodeH);
  }
  
  final roots = persons.where((p) => p.parentId == null || !persons.any((pp) => pp.id == p.parentId)).toList();
  
  double _layoutSubtree(List<Person> children, double x, double startY) {
    double currentY = startY;
    for (final child in children) {
      final childChildren = persons.where((p) => p.parentId == child.id).toList();
      if (childChildren.isEmpty) {
        nodes[child.id]!.x = x;
        nodes[child.id]!.y = currentY + nodeH / 2;
        currentY += nodeH + vGap;
      } else {
        final subtreeStart = currentY;
        currentY = _layoutSubtree(childChildren, x + hGap, currentY);
        nodes[child.id]!.x = x;
        nodes[child.id]!.y = (subtreeStart + currentY - vGap) / 2;
      }
    }
    return currentY;
  }
  
  double startY = 20;
  for (final root in roots) {
    final children = persons.where((p) => p.parentId == root.id).toList();
    if (children.isEmpty) {
      nodes[root.id]!.x = 80;
      nodes[root.id]!.y = startY + nodeH / 2;
      startY += nodeH + vGap;
    } else {
      final before = startY;
      startY = _layoutSubtree(children, 80 + hGap, startY);
      nodes[root.id]!.x = 80;
      nodes[root.id]!.y = (before + startY - vGap) / 2;
    }
    startY += vGap;
  }
  
  return nodes.values.toList();
}
