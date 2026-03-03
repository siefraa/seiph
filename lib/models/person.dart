import 'dart:convert';

enum Gender { male, female, other }

class Person {
  String id;
  String name;
  String? birthDate;
  String? deathDate;
  String? photoUrl;
  Gender gender;
  String? spouseId;
  String? parentId; // Primary parent (father or mother)
  List<String> childrenIds;
  String? notes;
  bool isAlive;

  Person({
    required this.id,
    required this.name,
    this.birthDate,
    this.deathDate,
    this.photoUrl,
    this.gender = Gender.male,
    this.spouseId,
    this.parentId,
    List<String>? childrenIds,
    this.notes,
    this.isAlive = true,
  }) : childrenIds = childrenIds ?? [];

  Person copyWith({
    String? id,
    String? name,
    String? birthDate,
    String? deathDate,
    String? photoUrl,
    Gender? gender,
    String? spouseId,
    String? parentId,
    List<String>? childrenIds,
    String? notes,
    bool? isAlive,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      spouseId: spouseId ?? this.spouseId,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? List.from(this.childrenIds),
      notes: notes ?? this.notes,
      isAlive: isAlive ?? this.isAlive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'deathDate': deathDate,
      'photoUrl': photoUrl,
      'gender': gender.name,
      'spouseId': spouseId,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'notes': notes,
      'isAlive': isAlive,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: json['birthDate'] as String?,
      deathDate: json['deathDate'] as String?,
      photoUrl: json['photoUrl'] as String?,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.male,
      ),
      spouseId: json['spouseId'] as String?,
      parentId: json['parentId'] as String?,
      childrenIds: (json['childrenIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: json['notes'] as String?,
      isAlive: json['isAlive'] as bool? ?? true,
    );
  }
}

class FamilyTree {
  String title;
  List<Person> persons;
  String? rootPersonId;
  DateTime createdAt;
  DateTime updatedAt;

  FamilyTree({
    required this.title,
    List<Person>? persons,
    this.rootPersonId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : persons = persons ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'persons': persons.map((p) => p.toJson()).toList(),
      'rootPersonId': rootPersonId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FamilyTree.fromJson(Map<String, dynamic> json) {
    return FamilyTree(
      title: json['title'] as String,
      persons: (json['persons'] as List<dynamic>)
          .map((p) => Person.fromJson(p as Map<String, dynamic>))
          .toList(),
      rootPersonId: json['rootPersonId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory FamilyTree.fromJsonString(String jsonStr) =>
      FamilyTree.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
