import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryInfo(this.name, this.icon, this.color);
}

const expenseCategories = [
  CategoryInfo('อาหาร', Icons.restaurant_rounded, Color(0xFFFF7043)),
  CategoryInfo('เดินทาง', Icons.directions_bus_rounded, Color(0xFF42A5F5)),
  CategoryInfo('ช้อปปิ้ง', Icons.shopping_bag_rounded, Color(0xFFAB47BC)),
  CategoryInfo('บันเทิง', Icons.movie_rounded, Color(0xFFEC407A)),
  CategoryInfo('การศึกษา', Icons.school_rounded, Color(0xFF5C6BC0)),
  CategoryInfo('อื่นๆ', Icons.more_horiz_rounded, Color(0xFF78909C)),
];

const incomeCategories = [
  CategoryInfo('เงินเดือน', Icons.payments_rounded, Color(0xFF26A69A)),
  CategoryInfo('ค่าขนม', Icons.savings_rounded, Color(0xFF66BB6A)),
  CategoryInfo('งานเสริม', Icons.work_rounded, Color(0xFFFFA726)),
  CategoryInfo('อื่นๆ', Icons.more_horiz_rounded, Color(0xFF78909C)),
];

CategoryInfo findCategory(String name, bool isIncome) {
  final list = isIncome ? incomeCategories : expenseCategories;
  return list.firstWhere(
    (c) => c.name == name,
    orElse: () => list.last,
  );
}
