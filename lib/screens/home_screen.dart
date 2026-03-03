import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_tree_provider.dart';
import '../models/person.dart';
import '../models/theme_model.dart';
import '../widgets/royal_tree_painter.dart';
import '../widgets/royal_person_card.dart';
import '../widgets/dialogs.dart';
import '../widgets/person_detail_panel.dart';
import '../utils/import_export.dart';
import 'dart:math' as math;
import '../widgets/royal_tree_painter.dart';
import '../widgets/royal_person_card.dart' as rpc;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransformationController _transformCtrl = TransformationController();
  bool _showThemePanel = false;
  bool _showCardStylePanel = false;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FamilyTreeProvider>(
      builder: (context, provider, _) {
        final td = provider.themeData;

        if (provider.layout == TreeLayout.genealogy) {
          return _GenealogyScaffold(
            provider: provider,
            themeData: td,
            onAddPerson: () => _addPerson(context, provider),
            onImport: () => _importFile(context, provider),
            onExport: () => ImportExportUtil.exportToFile(context, provider.tree),
            onRename: () => _renameTree(context, provider),
            showThemePanel: _showThemePanel,
            showCardStylePanel: _showCardStylePanel,
            onToggleTheme: () => setState(() { _showThemePanel = !_showThemePanel; _showCardStylePanel = false; }),
            onToggleCardStyle: () => setState(() { _showCardStylePanel = !_showCardStylePanel; _showThemePanel = false; }),
            onThemeSelect: (t) { provider.setTheme(t); setState(() => _showThemePanel = false); },
            onCardStyleSelect: (s) { provider.setCardStyle(s); setState(() => _showCardStylePanel = false); },
            onClosePanel: () => setState(() { _showThemePanel = false; _showCardStylePanel = false; }),
          );
        }

        final isHorizontal = provider.layout == TreeLayout.horizontal;
        final visiblePersons = provider.getVisiblePersons();
        final cs = provider.cardStyle;
        final nodes = isHorizontal
            ? buildHorizontalTree(visiblePersons, cs)
            : buildVerticalTree(visiblePersons, cs);

        double maxX = 800, maxY = 600;
        for (final n in nodes) {
          if (n.x + n.width / 2 > maxX) maxX = n.x + n.width / 2 + 80;
          if (n.y + n.height / 2 > maxY) maxY = n.y + n.height / 2 + 80;
        }

        final genMap = <String, int>{for (var n in nodes) n.person.id: n.generation};

        return Scaffold(
          backgroundColor: td.canvasBg,
          body: Row(
            children: [
              _Sidebar(
                provider: provider,
                themeData: td,
                onAddPerson: () => _addPerson(context, provider),
                onImport: () => _importFile(context, provider),
                onExport: () => ImportExportUtil.exportToFile(context, provider.tree),
                onToggleTheme: () => setState(() { _showThemePanel = !_showThemePanel; _showCardStylePanel = false; }),
                onToggleCardStyle: () => setState(() { _showCardStylePanel = !_showCardStylePanel; _showThemePanel = false; }),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _TopBar(
                          provider: provider,
                          themeData: td,
                          onAddPerson: () => _addPerson(context, provider),
                          onRename: () => _renameTree(context, provider),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(child: Container(color: td.canvasBg)),
                              if (td.showGridDots)
                                Positioned.fill(child: CustomPaint(painter: _GridDotsPainter(td.gridColor))),
                              InteractiveViewer(
                                transformationController: _transformCtrl,
                                minScale: 0.15,
                                maxScale: 3.5,
                                boundaryMargin: const EdgeInsets.all(600),
                                child: SizedBox(
                                  width: maxX + 100,
                                  height: maxY + 100,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: RoyalTreePainter(
                                            nodes: nodes,
                                            persons: visiblePersons,
                                            selectedPersonId: provider.selectedPersonId,
                                            theme: td,
                                            isHorizontal: isHorizontal,
                                          ),
                                        ),
                                      ),
                                      ...nodes.map((node) {
                                        final isSelected = node.person.id == provider.selectedPersonId;
                                        final isDimmed = provider.showOnlySelected && !isSelected && provider.selectedPersonId != null;
                                        final sz = rpc.cardSize(cs);
                                        return Positioned(
                                          left: node.x - sz.width / 2,
                                          top: node.y - sz.height / 2,
                                          child: RoyalPersonCard(
                                            person: node.person,
                                            isSelected: isSelected,
                                            isFocused: isSelected,
                                            isDimmed: isDimmed,
                                            generation: genMap[node.person.id],
                                            theme: td,
                                            cardStyle: cs,
                                            onTap: () {
                                              if (isSelected) {
                                                _showPersonDetail(context, node.person);
                                              } else {
                                                provider.selectPerson(node.person.id);
                                              }
                                            },
                                            onDoubleTap: () => _showPersonDetail(context, node.person),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              if (provider.selectedPersonId != null)
                                Positioned(
                                  bottom: 16, left: 0, right: 0,
                                  child: Center(
                                    child: _FocusBanner(
                                      name: provider.selectedPerson?.name ?? '',
                                      theme: td,
                                      onClear: provider.clearSelection,
                                    ),
                                  ),
                                ),
                              if (provider.persons.isEmpty)
                                Center(
                                  child: _EmptyState(theme: td, onLoadSample: provider.loadSampleData),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_showThemePanel)
                      _ThemePanel(
                        currentTheme: provider.appTheme,
                        onSelect: (t) { provider.setTheme(t); setState(() => _showThemePanel = false); },
                        onClose: () => setState(() => _showThemePanel = false),
                      ),
                    if (_showCardStylePanel)
                      _CardStylePanel(
                        currentStyle: provider.cardStyle,
                        onSelect: (s) { provider.setCardStyle(s); setState(() => _showCardStylePanel = false); },
                        onClose: () => setState(() => _showCardStylePanel = false),
                      ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _ZoomControls(ctrl: _transformCtrl, theme: td),
        );
      },
    );
  }

  Future<void> _addPerson(BuildContext context, FamilyTreeProvider provider) async {
    final result = await showDialog<Person>(
      context: context,
      builder: (_) => const AddPersonDialog(title: 'Add New Person'),
    );
    if (result != null) {
      provider.addPerson(name: result.name, gender: result.gender,
        birthDate: result.birthDate, deathDate: result.deathDate,
        notes: result.notes, isAlive: result.isAlive);
    }
  }

  Future<void> _importFile(BuildContext context, FamilyTreeProvider provider) async {
    final tree = await ImportExportUtil.importFromFile(context);
    if (tree != null && context.mounted) {
      provider.importTree(tree);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Imported: ${tree.title} (${tree.persons.length} persons)'),
        backgroundColor: Colors.green,
      ));
    }
  }

  void _showPersonDetail(BuildContext context, Person person) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, maxChildSize: 0.92, minChildSize: 0.3,
        builder: (_, __) => PersonDetailPanel(person: person),
      ),
    );
  }

  Future<void> _renameTree(BuildContext context, FamilyTreeProvider provider) async {
    final ctrl = TextEditingController(text: provider.tree.title);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename Tree', style: TextStyle(color: Colors.white)),
        content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C6E49)),
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('Rename', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) provider.setTreeTitle(result);
  }
}

// ─── Sidebar ───
class _Sidebar extends StatelessWidget {
  final FamilyTreeProvider provider;
  final FamilyThemeData themeData;
  final VoidCallback onAddPerson, onImport, onExport, onToggleTheme, onToggleCardStyle;

  const _Sidebar({required this.provider, required this.themeData,
    required this.onAddPerson, required this.onImport, required this.onExport,
    required this.onToggleTheme, required this.onToggleCardStyle});

  @override
  Widget build(BuildContext context) {
    final td = themeData;
    return Container(
      width: 190,
      color: td.sidebarBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Icon(Icons.account_tree, color: td.sidebarAccent, size: 28),
              const SizedBox(height: 4),
              Text('Family Tree', style: TextStyle(color: td.sidebarText, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(provider.tree.title, style: TextStyle(color: td.sidebarText.withOpacity(0.45), fontSize: 10), overflow: TextOverflow.ellipsis),
            ]),
          ),
          _divider(td),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('LAYOUT', td),
              const SizedBox(height: 5),
              for (final entry in [
                [TreeLayout.vertical, Icons.vertical_align_top, 'Vertical'],
                [TreeLayout.horizontal, Icons.horizontal_distribute, 'Horizontal'],
                [TreeLayout.genealogy, Icons.view_list, 'List View'],
                [TreeLayout.radial, Icons.bubble_chart, 'Radial'],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: _LayoutBtn(provider: provider, layout: entry[0] as TreeLayout, icon: entry[1] as IconData, label: entry[2] as String, td: td),
                ),
            ]),
          ),
          _divider(td),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('APPEARANCE', td),
              const SizedBox(height: 5),
              _menuBtn('${td.emoji} ${td.name} Theme', td, onToggleTheme),
              const SizedBox(height: 3),
              _menuBtn('🃏 ${_csName(provider.cardStyle)} Cards', td, onToggleCardStyle),
            ]),
          ),
          _divider(td),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('STATS', td),
              const SizedBox(height: 5),
              _stat('Members', provider.persons.length.toString(), td),
              _stat('Living', provider.persons.where((p) => p.isAlive).length.toString(), td),
              _stat('Generations', _countGen(provider).toString(), td),
            ]),
          ),
          const Spacer(),
          _divider(td),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              _actionBtn(Icons.upload_file, 'Import', td, onImport),
              const SizedBox(height: 5),
              _actionBtn(Icons.download, 'Export', td, onExport, primary: true),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _divider(FamilyThemeData td) => Divider(color: td.sidebarText.withOpacity(0.1), height: 1);
  Widget _sectionLabel(String l, FamilyThemeData td) => Text(l, style: TextStyle(color: td.sidebarText.withOpacity(0.35), fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w600));
  Widget _stat(String l, String v, FamilyThemeData td) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: TextStyle(color: td.sidebarText.withOpacity(0.5), fontSize: 11)),
    Text(v, style: TextStyle(color: td.sidebarAccent, fontSize: 11, fontWeight: FontWeight.bold)),
  ]));
  Widget _menuBtn(String l, FamilyThemeData td, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: td.sidebarText.withOpacity(0.06), borderRadius: BorderRadius.circular(7)), child: Row(children: [
    Expanded(child: Text(l, style: TextStyle(color: td.sidebarText.withOpacity(0.7), fontSize: 11))),
    Icon(Icons.chevron_right, color: td.sidebarText.withOpacity(0.25), size: 14),
  ])));
  Widget _actionBtn(IconData icon, String l, FamilyThemeData td, VoidCallback onTap, {bool primary = false}) => SizedBox(width: double.infinity, child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: primary ? td.sidebarAccent : td.sidebarText.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: primary ? null : Border.all(color: td.sidebarText.withOpacity(0.15))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 13, color: primary ? _con(td.sidebarAccent) : td.sidebarText.withOpacity(0.6)),
    const SizedBox(width: 5),
    Text(l, style: TextStyle(color: primary ? _con(td.sidebarAccent) : td.sidebarText.withOpacity(0.7), fontSize: 12, fontWeight: primary ? FontWeight.w600 : FontWeight.normal)),
  ]))));
  Color _con(Color c) => c.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  String _csName(CardStyle s) { switch(s) { case CardStyle.royal: return 'Royal'; case CardStyle.compact: return 'Compact'; case CardStyle.portrait: return 'Portrait'; case CardStyle.minimal: return 'Minimal'; } }
  int _countGen(FamilyTreeProvider p) { if (p.persons.isEmpty) return 0; int m = 0; for (final pp in p.persons) { int d = 0; String? c = pp.parentId; while (c != null && d < 20) { d++; c = p.getPersonById(c)?.parentId; } if (d > m) m = d; } return m + 1; }
}

// ─── Layout Button ───
class _LayoutBtn extends StatelessWidget {
  final FamilyTreeProvider provider;
  final TreeLayout layout;
  final IconData icon;
  final String label;
  final FamilyThemeData td;

  const _LayoutBtn({required this.provider, required this.layout, required this.icon, required this.label, required this.td});

  @override
  Widget build(BuildContext context) {
    final isActive = provider.layout == layout;
    return GestureDetector(
      onTap: () => provider.setLayout(layout),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? td.sidebarAccent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: isActive ? td.sidebarAccent.withOpacity(0.4) : Colors.transparent),
        ),
        child: Row(children: [
          Icon(icon, size: 14, color: isActive ? td.sidebarAccent : td.sidebarText.withOpacity(0.45)),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(color: isActive ? td.sidebarAccent : td.sidebarText.withOpacity(0.55), fontSize: 12)),
        ]),
      ),
    );
  }
}

// ─── Top Bar ───
class _TopBar extends StatelessWidget {
  final FamilyTreeProvider provider;
  final FamilyThemeData themeData;
  final VoidCallback onAddPerson, onRename;

  const _TopBar({required this.provider, required this.themeData, required this.onAddPerson, required this.onRename});

  @override
  Widget build(BuildContext context) {
    final td = themeData;
    final isLight = td.canvasBg.computeLuminance() > 0.5;
    final barBg = isLight ? Colors.white : const Color(0xFF0F1923);
    final borderC = isLight ? const Color(0xFFE5E5E5) : Colors.white12;
    final textC = isLight ? const Color(0xFF111111) : Colors.white;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(bottom: BorderSide(color: borderC)),
        boxShadow: isLight ? [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))] : [],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onRename,
            child: Row(children: [
              Text(provider.tree.title, style: TextStyle(color: textC, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(width: 4),
              Icon(Icons.edit, color: textC.withOpacity(0.25), size: 12),
            ]),
          ),
          const Spacer(),
          _btn(context, Icons.person_add, 'Add Person', td.genBadgeBg, td.genBadgeText, onAddPerson),
          const SizedBox(width: 8),
          _btn(context, Icons.visibility, 'Show All', Colors.blue.shade700, Colors.white, provider.clearSelection),
          const SizedBox(width: 8),
          _btn(context, Icons.auto_awesome, 'Sample Data', Colors.deepPurple, Colors.white, provider.loadSampleData),
        ],
      ),
    );
  }

  Widget _btn(BuildContext ctx, IconData icon, String label, Color bg, Color fg, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: bg.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: bg, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: bg, fontSize: 11, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

// ─── Genealogy Scaffold ───
class _GenealogyScaffold extends StatelessWidget {
  final FamilyTreeProvider provider;
  final FamilyThemeData themeData;
  final VoidCallback onAddPerson, onImport, onExport, onRename, onToggleTheme, onToggleCardStyle, onClosePanel;
  final void Function(AppTheme) onThemeSelect;
  final void Function(CardStyle) onCardStyleSelect;
  final bool showThemePanel, showCardStylePanel;

  const _GenealogyScaffold({required this.provider, required this.themeData,
    required this.onAddPerson, required this.onImport, required this.onExport, required this.onRename,
    required this.onToggleTheme, required this.onToggleCardStyle, required this.onClosePanel,
    required this.onThemeSelect, required this.onCardStyleSelect,
    required this.showThemePanel, required this.showCardStylePanel});

  @override
  Widget build(BuildContext context) {
    final td = themeData;
    return Scaffold(
      backgroundColor: td.canvasBg,
      body: Row(
        children: [
          _Sidebar(provider: provider, themeData: td, onAddPerson: onAddPerson, onImport: onImport, onExport: onExport, onToggleTheme: onToggleTheme, onToggleCardStyle: onToggleCardStyle),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    _TopBar(provider: provider, themeData: td, onAddPerson: onAddPerson, onRename: onRename),
                    Expanded(child: _GenealogyList(themeData: td)),
                  ],
                ),
                if (showThemePanel)
                  _ThemePanel(currentTheme: provider.appTheme, onSelect: onThemeSelect, onClose: onClosePanel),
                if (showCardStylePanel)
                  _CardStylePanel(currentStyle: provider.cardStyle, onSelect: onCardStyleSelect, onClose: onClosePanel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenealogyList extends StatelessWidget {
  final FamilyThemeData themeData;
  const _GenealogyList({required this.themeData});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyTreeProvider>();
    final persons = provider.getVisiblePersons();
    final td = themeData;

    return Container(
      color: td.canvasBg,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: persons.length,
        itemBuilder: (ctx, i) {
          final p = persons[i];
          final spouse = p.spouseId != null ? provider.getPersonById(p.spouseId!) : null;
          final isSelected = p.id == provider.selectedPersonId;
          return GestureDetector(
            onTap: () => provider.selectPerson(p.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? td.selectedCardBg : td.cardBg,
                borderRadius: BorderRadius.circular(td.cardRadius),
                border: Border.all(color: isSelected ? td.selectedCardBorder : td.cardBorder, width: isSelected ? 2 : 1),
                boxShadow: [BoxShadow(color: td.cardShadow, blurRadius: 4)],
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.gender == Gender.male ? td.maleCardBorder.withOpacity(0.15) : td.femaleCardBorder.withOpacity(0.15),
                    border: Border.all(color: p.gender == Gender.male ? td.maleCardBorder : td.femaleCardBorder),
                  ),
                  child: Center(child: Text(p.name[0], style: TextStyle(color: p.gender == Gender.male ? td.maleCardBorder : td.femaleCardBorder, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: TextStyle(color: td.namePrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(children: [
                    if (p.birthDate != null) Text('${p.birthDate} – ${p.isAlive ? 'Living' : (p.deathDate ?? '')}', style: TextStyle(color: td.dateColor, fontSize: 12)),
                    if (spouse != null) ...[const SizedBox(width: 8), Icon(Icons.favorite, color: td.spouseLineColor, size: 12), const SizedBox(width: 2), Text(spouse.name, style: TextStyle(color: td.spouseLineColor, fontSize: 12))],
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (!p.isAlive) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: td.dateColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Text('†', style: TextStyle(color: td.dateColor, fontSize: 10))),
                  Text('${p.childrenIds.length} ch.', style: TextStyle(color: td.dateColor, fontSize: 10)),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ─── Focus Banner ───
class _FocusBanner extends StatelessWidget {
  final String name;
  final FamilyThemeData theme;
  final VoidCallback onClear;
  const _FocusBanner({required this.name, required this.theme, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.focusBadgeBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: theme.focusBadgeBg.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.person_pin, color: theme.focusBadgeText, size: 16),
        const SizedBox(width: 6),
        Text('Focus: $name', style: TextStyle(color: theme.focusBadgeText, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        GestureDetector(onTap: onClear, child: Icon(Icons.close, color: theme.focusBadgeText.withOpacity(0.8), size: 16)),
      ]),
    );
  }
}

// ─── Empty State ───
class _EmptyState extends StatelessWidget {
  final FamilyThemeData theme;
  final VoidCallback onLoadSample;
  const _EmptyState({required this.theme, required this.onLoadSample});

  Color _con(Color c) => c.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    final isLight = theme.canvasBg.computeLuminance() > 0.5;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.account_tree_outlined, size: 72, color: isLight ? Colors.black12 : Colors.white12),
      const SizedBox(height: 12),
      Text('Your family tree is empty', style: TextStyle(color: isLight ? Colors.black38 : Colors.white38, fontSize: 18, fontWeight: FontWeight.w300)),
      const SizedBox(height: 8),
      Text('Add a person or load sample data', style: TextStyle(color: isLight ? Colors.black26 : Colors.white24, fontSize: 13)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: theme.sidebarAccent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        onPressed: onLoadSample,
        icon: Icon(Icons.auto_awesome, color: _con(theme.sidebarAccent)),
        label: Text('Load Sample Data', style: TextStyle(color: _con(theme.sidebarAccent), fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}

// ─── Zoom Controls ───
class _ZoomControls extends StatelessWidget {
  final TransformationController ctrl;
  final FamilyThemeData theme;
  const _ZoomControls({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _zBtn(Icons.add, () { final s = ctrl.value.getMaxScaleOnAxis(); ctrl.value = Matrix4.identity()..scale(math.min(s + 0.25, 3.5)); }),
      const SizedBox(height: 6),
      _zBtn(Icons.remove, () { final s = ctrl.value.getMaxScaleOnAxis(); ctrl.value = Matrix4.identity()..scale(math.max(s - 0.25, 0.15)); }),
      const SizedBox(height: 6),
      _zBtn(Icons.center_focus_strong, () => ctrl.value = Matrix4.identity()),
    ]);
  }

  Widget _zBtn(IconData icon, VoidCallback onTap) => FloatingActionButton.small(
    heroTag: icon.codePoint.toString(),
    backgroundColor: theme.sidebarBg,
    elevation: 4,
    onPressed: onTap,
    child: Icon(icon, color: theme.sidebarAccent, size: 18),
  );
}

// ─── Theme Panel ───
class _ThemePanel extends StatelessWidget {
  final AppTheme currentTheme;
  final void Function(AppTheme) onSelect;
  final VoidCallback onClose;
  const _ThemePanel({required this.currentTheme, required this.onSelect, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 52, right: 8,
      child: Material(
        elevation: 16, borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1A2332), borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Choose Theme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              GestureDetector(onTap: onClose, child: const Icon(Icons.close, color: Colors.white54, size: 18)),
            ]),
            const SizedBox(height: 12),
            ...FamilyThemes.themes.entries.map((e) {
              final isActive = e.key == currentTheme;
              final td = e.value;
              return GestureDetector(
                onTap: () => onSelect(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isActive ? Colors.white30 : Colors.transparent),
                  ),
                  child: Row(children: [
                    Text(td.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(td.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      Row(children: [td.canvasBg, td.maleCardBorder, td.femaleCardBorder, td.sidebarAccent].map((c) => Container(margin: const EdgeInsets.only(right: 3, top: 2), width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle))).toList()),
                    ]),
                    const Spacer(),
                    if (isActive) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                  ]),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }
}

// ─── Card Style Panel ───
class _CardStylePanel extends StatelessWidget {
  final CardStyle currentStyle;
  final void Function(CardStyle) onSelect;
  final VoidCallback onClose;
  const _CardStylePanel({required this.currentStyle, required this.onSelect, required this.onClose});

  static const _info = {
    CardStyle.royal: ['👑', 'Royal', 'Photo + name + dates (Findmypast style)'],
    CardStyle.compact: ['📋', 'Compact', 'Dense horizontal row layout'],
    CardStyle.portrait: ['🖼️', 'Portrait', 'Tall card with large avatar'],
    CardStyle.minimal: ['⬜', 'Minimal', 'Name only badge'],
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 52, right: 8,
      child: Material(
        elevation: 16, borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 240, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1A2332), borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Card Style', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              GestureDetector(onTap: onClose, child: const Icon(Icons.close, color: Colors.white54, size: 18)),
            ]),
            const SizedBox(height: 12),
            ...CardStyle.values.map((s) {
              final isActive = s == currentStyle;
              final info = _info[s]!;
              return GestureDetector(
                onTap: () => onSelect(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isActive ? Colors.white30 : Colors.transparent),
                  ),
                  child: Row(children: [
                    Text(info[0], style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(info[1], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(info[2], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ])),
                    if (isActive) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                  ]),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }
}

// ─── Grid Dots Painter ───
class _GridDotsPainter extends CustomPainter {
  final Color color;
  const _GridDotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridDotsPainter old) => old.color != color;
}
