import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/categories.dart';
import '../../../models/money_entry.dart';

class ItemEntry extends StatelessWidget {
  final MoneyEntry entry;
  final VoidCallback onTap;

  const ItemEntry({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = findCategory(entry.category, entry.isIncome);
    final amountColor =
        entry.isIncome ? const Color(0xFF00897B) : const Color(0xFFE53935);
    final sign = entry.isIncome ? '+' : '-';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(cat.icon, color: cat.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.category} • ${DateFormat('d MMM y', 'th_TH').format(entry.date)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$sign${NumberFormat('#,##0.00').format(entry.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
