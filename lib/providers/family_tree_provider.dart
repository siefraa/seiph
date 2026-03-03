import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../models/theme_model.dart';
import 'package:uuid/uuid.dart';

enum TreeLayout { vertical, horizontal, radial, genealogy }

class FamilyTreeProvider extends ChangeNotifier {
  FamilyTree _tree = FamilyTree(title: 'My Family Tree');
  String? _selectedPersonId;
  TreeLayout _layout = TreeLayout.vertical;
  bool _showOnlySelected = false;
  double _zoom = 1.0;
  AppTheme _theme = AppTheme.royal;
  CardStyle _cardStyle = CardStyle.royal;
  final _uuid = const Uuid();

  AppTheme get appTheme => _theme;
  FamilyThemeData get themeData => FamilyThemes.get(_theme);
  CardStyle get cardStyle => _cardStyle;

  void setTheme(AppTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  void setCardStyle(CardStyle style) {
    _cardStyle = style;
    notifyListeners();
  }

  FamilyTree get tree => _tree;
  String? get selectedPersonId => _selectedPersonId;
  TreeLayout get layout => _layout;
  bool get showOnlySelected => _showOnlySelected;
  double get zoom => _zoom;

  List<Person> get persons => _tree.persons;

  Person? get selectedPerson => _selectedPersonId != null
      ? _tree.persons.firstWhere((p) => p.id == _selectedPersonId,
          orElse: () => _tree.persons.first)
      : null;

  void selectPerson(String? id) {
    _selectedPersonId = id;
    _showOnlySelected = id != null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPersonId = null;
    _showOnlySelected = false;
    notifyListeners();
  }

  void setLayout(TreeLayout layout) {
    _layout = layout;
    notifyListeners();
  }

  void setZoom(double zoom) {
    _zoom = zoom.clamp(0.3, 3.0);
    notifyListeners();
  }

  String addPerson({
    required String name,
    Gender gender = Gender.male,
    String? birthDate,
    String? deathDate,
    String? notes,
    bool isAlive = true,
  }) {
    final id = _uuid.v4();
    final person = Person(
      id: id,
      name: name,
      gender: gender,
      birthDate: birthDate,
      deathDate: deathDate,
      notes: notes,
      isAlive: isAlive,
    );
    _tree.persons.add(person);
    if (_tree.rootPersonId == null) {
      _tree.rootPersonId = id;
    }
    _tree.updatedAt = DateTime.now();
    notifyListeners();
    return id;
  }

  void updatePerson(Person updated) {
    final idx = _tree.persons.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _tree.persons[idx] = updated;
      _tree.updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void deletePerson(String id) {
    // Remove all references
    for (var p in _tree.persons) {
      if (p.spouseId == id) p.spouseId = null;
      if (p.parentId == id) p.parentId = null;
      p.childrenIds.remove(id);
    }
    _tree.persons.removeWhere((p) => p.id == id);
    if (_selectedPersonId == id) _selectedPersonId = null;
    if (_tree.rootPersonId == id) {
      _tree.rootPersonId = _tree.persons.isNotEmpty ? _tree.persons.first.id : null;
    }
    _tree.updatedAt = DateTime.now();
    notifyListeners();
  }

  void addChild(String parentId, String childName, Gender gender) {
    final childId = _uuid.v4();
    final child = Person(
      id: childId,
      name: childName,
      gender: gender,
      parentId: parentId,
    );
    _tree.persons.add(child);
    final parentIdx = _tree.persons.indexWhere((p) => p.id == parentId);
    if (parentIdx != -1) {
      _tree.persons[parentIdx].childrenIds.add(childId);
    }
    // Also link spouse's children
    final parent = _tree.persons[parentIdx];
    if (parent.spouseId != null) {
      final spouseIdx = _tree.persons.indexWhere((p) => p.id == parent.spouseId);
      if (spouseIdx != -1) {
        _tree.persons[spouseIdx].childrenIds.add(childId);
      }
    }
    _tree.updatedAt = DateTime.now();
    notifyListeners();
  }

  void addChildPerson(String parentId, Person child) {
    _tree.persons.add(child);
    final parentIdx = _tree.persons.indexWhere((p) => p.id == parentId);
    if (parentIdx != -1) {
      _tree.persons[parentIdx].childrenIds.add(child.id);
    }
    _tree.updatedAt = DateTime.now();
    notifyListeners();
  }

  void linkAsSpouse(String personId, String spouseId) {
    final pIdx = _tree.persons.indexWhere((p) => p.id == personId);
    final sIdx = _tree.persons.indexWhere((p) => p.id == spouseId);
    if (pIdx != -1 && sIdx != -1) {
      _tree.persons[pIdx] = _tree.persons[pIdx].copyWith(spouseId: spouseId);
      _tree.persons[sIdx] = _tree.persons[sIdx].copyWith(spouseId: personId);
      _tree.updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void unlinkSpouse(String personId) {
    final pIdx = _tree.persons.indexWhere((p) => p.id == personId);
    if (pIdx != -1) {
      final spouseId = _tree.persons[pIdx].spouseId;
      _tree.persons[pIdx] = _tree.persons[pIdx].copyWith(spouseId: null);
      if (spouseId != null) {
        final sIdx = _tree.persons.indexWhere((p) => p.id == spouseId);
        if (sIdx != -1) {
          _tree.persons[sIdx] = _tree.persons[sIdx].copyWith(spouseId: null);
        }
      }
      _tree.updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void linkParentChild(String parentId, String childId) {
    final cIdx = _tree.persons.indexWhere((p) => p.id == childId);
    final pIdx = _tree.persons.indexWhere((p) => p.id == parentId);
    if (cIdx != -1 && pIdx != -1) {
      _tree.persons[cIdx] = _tree.persons[cIdx].copyWith(parentId: parentId);
      if (!_tree.persons[pIdx].childrenIds.contains(childId)) {
        _tree.persons[pIdx].childrenIds.add(childId);
      }
      _tree.updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void unlinkParentChild(String parentId, String childId) {
    final cIdx = _tree.persons.indexWhere((p) => p.id == childId);
    final pIdx = _tree.persons.indexWhere((p) => p.id == parentId);
    if (cIdx != -1) {
      _tree.persons[cIdx] = _tree.persons[cIdx].copyWith(parentId: null);
    }
    if (pIdx != -1) {
      _tree.persons[pIdx].childrenIds.remove(childId);
    }
    _tree.updatedAt = DateTime.now();
    notifyListeners();
  }

  List<Person> getVisiblePersons() {
    if (!_showOnlySelected || _selectedPersonId == null) {
      return _tree.persons;
    }
    final selected = _tree.persons.firstWhere(
      (p) => p.id == _selectedPersonId,
      orElse: () => _tree.persons.first,
    );
    final visible = <String>{selected.id};
    // Add spouse
    if (selected.spouseId != null) visible.add(selected.spouseId!);
    // Add parents
    if (selected.parentId != null) {
      visible.add(selected.parentId!);
      final parent = _tree.persons.firstWhere(
        (p) => p.id == selected.parentId,
        orElse: () => selected,
      );
      if (parent.spouseId != null) visible.add(parent.spouseId!);
    }
    // Add children
    visible.addAll(selected.childrenIds);
    // Add siblings
    if (selected.parentId != null) {
      final siblings = _tree.persons
          .where((p) => p.parentId == selected.parentId && p.id != selected.id)
          .map((p) => p.id);
      visible.addAll(siblings);
    }
    return _tree.persons.where((p) => visible.contains(p.id)).toList();
  }

  Person? getPersonById(String id) {
    try {
      return _tree.persons.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Person> getChildren(String personId) {
    return _tree.persons.where((p) => p.parentId == personId).toList();
  }

  List<Person> getRootPersons() {
    return _tree.persons.where((p) => p.parentId == null).toList();
  }

  void importTree(FamilyTree tree) {
    _tree = tree;
    _selectedPersonId = null;
    _showOnlySelected = false;
    notifyListeners();
  }

  void setTreeTitle(String title) {
    _tree.title = title;
    notifyListeners();
  }

  void loadSampleData() {
    _tree = FamilyTree(title: 'Sample Family Tree');
    // Grandparents
    final gfId = addPerson(name: 'George Anderson', gender: Gender.male, birthDate: '1940', isAlive: false, deathDate: '2010');
    final gmId = addPerson(name: 'Mary Anderson', gender: Gender.female, birthDate: '1942', isAlive: false, deathDate: '2015');
    linkAsSpouse(gfId, gmId);

    final gf2Id = addPerson(name: 'Robert Johnson', gender: Gender.male, birthDate: '1938', isAlive: false, deathDate: '2008');
    final gm2Id = addPerson(name: 'Patricia Johnson', gender: Gender.female, birthDate: '1940', isAlive: true);
    linkAsSpouse(gf2Id, gm2Id);

    // Parents
    final fatherId = addPerson(name: 'James Anderson', gender: Gender.male, birthDate: '1965', isAlive: true);
    final motherId = addPerson(name: 'Susan Anderson', gender: Gender.female, birthDate: '1968', isAlive: true);
    linkAsSpouse(fatherId, motherId);
    linkParentChild(gfId, fatherId);
    linkParentChild(motherId, fatherId); // fix
    
    // Reset father's parentId properly
    final fIdx = _tree.persons.indexWhere((p) => p.id == fatherId);
    if (fIdx != -1) _tree.persons[fIdx] = _tree.persons[fIdx].copyWith(parentId: gfId);
    final mIdx = _tree.persons.indexWhere((p) => p.id == motherId);
    if (mIdx != -1) _tree.persons[mIdx] = _tree.persons[mIdx].copyWith(parentId: gm2Id);

    final uncleId = addPerson(name: 'Michael Anderson', gender: Gender.male, birthDate: '1967', isAlive: true);
    final auId = _uuid.v4();
    final aunt = Person(id: auId, name: 'Linda Anderson', gender: Gender.female, birthDate: '1970', isAlive: true, parentId: gm2Id);
    _tree.persons.add(aunt);
    final uncIdx = _tree.persons.indexWhere((p) => p.id == uncleId);
    if (uncIdx != -1) _tree.persons[uncIdx] = _tree.persons[uncIdx].copyWith(parentId: gfId);

    // Children
    final child1Id = addPerson(name: 'Emma Anderson', gender: Gender.female, birthDate: '1992', isAlive: true);
    final child2Id = addPerson(name: 'Lucas Anderson', gender: Gender.male, birthDate: '1995', isAlive: true);
    final child3Id = addPerson(name: 'Olivia Anderson', gender: Gender.female, birthDate: '1998', isAlive: true);
    
    for (var cId in [child1Id, child2Id, child3Id]) {
      linkParentChild(fatherId, cId);
    }

    // Grandchild
    final gcId = addPerson(name: 'Liam Parker', gender: Gender.male, birthDate: '2018', isAlive: true);
    final c1Idx = _tree.persons.indexWhere((p) => p.id == child1Id);
    if (c1Idx != -1) _tree.persons[c1Idx].childrenIds.add(gcId);
    final gcIdx = _tree.persons.indexWhere((p) => p.id == gcId);
    if (gcIdx != -1) _tree.persons[gcIdx] = _tree.persons[gcIdx].copyWith(parentId: child1Id);

    _tree.rootPersonId = gfId;
    _selectedPersonId = null;
    notifyListeners();
  }
}
