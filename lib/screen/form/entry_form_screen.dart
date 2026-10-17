import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/categories.dart';
import '../../models/money_entry.dart';
import '../../repository/money_repository.dart';

/// หน้าเดียวใช้ทั้ง "เพิ่ม" (entry == null) และ "แก้ไข" (entry != null)
class EntryFormScreen extends StatefulWidget {
  final MoneyEntry? entry;

  const EntryFormScreen({super.key, this.entry});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();

  bool _isIncome = false;
  String _category = expenseCategories.first.name;
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEdit => widget.entry != null;

  List<CategoryInfo> get _categories =>
      _isIncome ? incomeCategories : expenseCategories;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e != null) {
      _title.text = e.title;
      _amount.text = e.amount.toString();
      _isIncome = e.isIncome;
      _category = e.category;
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final entry = MoneyEntry(
      id: widget.entry?.id,
      title: _title.text.trim(),
      amount: double.parse(_amount.text.trim()),
      isIncome: _isIncome,
      category: _category,
      date: _date,
    );

    if (_isEdit) {
      await MoneyRepository.update(entry);
    } else {
      await MoneyRepository.insert(entry);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_isEdit ? 'แก้ไขสำเร็จ!' : 'บันทึกสำเร็จ!'),
      ),
    );
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่?'),
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
    if (ok != true) return;

    await MoneyRepository.delete(widget.entry!.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ลบสำเร็จ!'),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        _isIncome ? const Color(0xFF00897B) : const Color(0xFFE53935);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'แก้ไขรายการ' : 'เพิ่มรายการ'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'ลบ',
              onPressed: _delete,
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.arrow_upward_rounded),
                  label: Text('รายจ่าย'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.arrow_downward_rounded),
                  label: Text('รายรับ'),
                ),
              ],
              selected: {_isIncome},
              onSelectionChanged: (s) => setState(() {
                _isIncome = s.first;
                _category = _categories.first.name;
              }),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(
                    '฿',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'กรุณากรอกจำนวนเงินให้ถูกต้อง';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'ชื่อรายการ เช่น ข้าวมันไก่',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อรายการ' : null,
            ),
            const SizedBox(height: 22),
            const Text('หมวดหมู่', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18, color: c.color),
                    label: Text(c.name),
                    selected: _category == c.name,
                    selectedColor: c.color.withValues(alpha: 0.2),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (_) => setState(() => _category = c.name),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('d MMMM y', 'th_TH').format(_date),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(_isEdit ? 'บันทึกการแก้ไข' : 'บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
