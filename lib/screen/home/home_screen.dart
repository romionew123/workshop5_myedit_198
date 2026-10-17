import 'package:flutter/material.dart';
import '../../models/money_entry.dart';
import '../../repository/money_repository.dart';
import '../form/entry_form_screen.dart';
import 'widgets/item_entry.dart';
import 'widgets/summary_card.dart';

enum EntryFilter { all, income, expense }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MoneyEntry> _entries = [];
  bool _loading = true;
  EntryFilter _filter = EntryFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await MoneyRepository.getAll();
    if (!mounted) return;
    setState(() {
      _entries = data;
      _loading = false;
    });
  }

  // เปิดหน้าฟอร์ม (เพิ่ม/แก้ไข) แล้วโหลดข้อมูลใหม่เมื่อกลับมา
  Future<void> _openForm({MoneyEntry? entry}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EntryFormScreen(entry: entry)),
    );
    await _load();
  }

  Future<bool> _confirmDelete(MoneyEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${entry.title}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(80, 44),
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok != true) return false;

    await MoneyRepository.delete(entry.id!);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('ลบ "${entry.title}" แล้ว'),
        ),
      );
    }
    // คืน false เพราะเรา reload รายการเองแล้ว ไม่ต้องให้ Dismissible ลบซ้ำ
    return false;
  }

  List<MoneyEntry> get _visible {
    switch (_filter) {
      case EntryFilter.income:
        return _entries.where((e) => e.isIncome).toList();
      case EntryFilter.expense:
        return _entries.where((e) => !e.isIncome).toList();
      case EntryFilter.all:
        return _entries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = _entries
        .where((e) => e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final expense = _entries
        .where((e) => !e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final items = _visible;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Money Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  SummaryCard(income: income, expense: expense),
                  const SizedBox(height: 18),
                  SegmentedButton<EntryFilter>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: EntryFilter.all, label: Text('ทั้งหมด')),
                      ButtonSegment(value: EntryFilter.income, label: Text('รายรับ')),
                      ButtonSegment(value: EntryFilter.expense, label: Text('รายจ่าย')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (s) => setState(() => _filter = s.first),
                  ),
                  const SizedBox(height: 14),
                  if (items.isEmpty)
                    _EmptyState(hasAny: _entries.isNotEmpty)
                  else
                    for (final e in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(e.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(e),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                            ),
                          ),
                          child: ItemEntry(
                            entry: e,
                            onTap: () => _openForm(entry: e),
                          ),
                        ),
                      ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('เพิ่มรายการ'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasAny;
  const _EmptyState({required this.hasAny});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            hasAny ? 'ไม่มีรายการในหมวดนี้' : 'ยังไม่มีรายการ\nกด "เพิ่มรายการ" เพื่อเริ่มบันทึก',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }
}
