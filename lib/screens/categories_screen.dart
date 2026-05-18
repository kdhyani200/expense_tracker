import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../image_helper.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customCats = ref.watch(categoryProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    final customIncome = customCats.where((c) => c.type == 'income').toList();
    final customExpense = customCats.where((c) => c.type == 'expense').toList();

    final builtInIncome = builtInCategories
        .where((c) => c.type == 'income')
        .toList();
    final builtInExpense = builtInCategories
        .where((c) => c.type == 'expense')
        .toList();

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.08),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      label: "Income",
                      color: const Color(0xFF00885d),
                      icon: Icons.arrow_downward_rounded,
                    ),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      builtIns: builtInIncome,
                      customs: customIncome,
                      onDelete: (id) => ref
                          .read(categoryProvider.notifier)
                          .deleteCategory(id),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      label: "Expense",
                      color: Colors.redAccent,
                      icon: Icons.arrow_upward_rounded,
                    ),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      builtIns: builtInExpense,
                      customs: customExpense,
                      onDelete: (id) => ref
                          .read(categoryProvider.notifier)
                          .deleteCategory(id),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => _showAddDialog(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00885d),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Add Category",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddCategoryDialog(
        onSave: (cat) => ref.read(categoryProvider.notifier).addCategory(cat),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Category grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final List<BuiltInCategory> builtIns;
  final List<CategoryModel> customs;
  final void Function(String id) onDelete;

  const _CategoryGrid({
    required this.builtIns,
    required this.customs,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: builtIns.length + customs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        if (index < builtIns.length) {
          final b = builtIns[index];
          return _CategoryChip(
            label: b.name,
            icon: b.icon,
            color: b.color,
            imagePath: null,
            isDeletable: false,
            onDelete: null,
          );
        }
        final c = customs[index - builtIns.length];
        return _CategoryChip(
          label: c.name,
          icon: c.iconCodePoint == -1 ? null : _safeIcon(c.iconCodePoint),
          color: Color(c.colorValue),
          imagePath: c.imagePath,
          isDeletable: true,
          onDelete: () => onDelete(c.id),
        );
      },
    );
  }
}

IconData _safeIcon(int codePoint) => kCategoryIcons.firstWhere(
  (e) => e.codePoint == codePoint,
  orElse: () => Icons.label_outline,
);

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final String? imagePath;
  final bool isDeletable;
  final VoidCallback? onDelete;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.imagePath,
    required this.isDeletable,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: _buildIcon(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 80,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        if (isDeletable)
          Positioned(
            top: -5,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIcon() {
    if (imagePath != null && File(imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(File(imagePath!), fit: BoxFit.cover),
      );
    }
    return Icon(icon ?? Icons.label_outline, color: color, size: 34);
  }
}

// ── Add category dialog ───────────────────────────────────────────────────────

class _AddCategoryDialog extends StatefulWidget {
  final void Function(CategoryModel cat) onSave;
  const _AddCategoryDialog({required this.onSave});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  String _type = 'expense';
  final _nameCtrl = TextEditingController();
  IconData _selectedIcon = kCategoryIcons[0];
  Color _selectedColor = kCategoryColors[0];
  String? _galleryImagePath;

  bool get _usingImage => _galleryImagePath != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final path = await ImageHelper.pickAndSaveImage();
    if (path == null) return;
    setState(() => _galleryImagePath = path);
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a category name")),
      );
      return;
    }
    final duplicate = builtInCategories.any(
      (c) => c.type == _type && c.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This category already exists")),
      );
      return;
    }
    widget.onSave(
      CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        iconCodePoint: _usingImage ? -1 : _selectedIcon.codePoint,
        colorValue: _selectedColor.value,
        type: _type,
        imagePath: _galleryImagePath,
      ),
    );
    Navigator.pop(context);
  }

  // ── Section label with optional "disabled" hint ──────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (_usingImage) ...[
          const SizedBox(width: 8),
          Text(
            "(using image)",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                "New Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Type toggle
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _typeTab('expense', 'Expense', Colors.redAccent),
                    _typeTab('income', 'Income', const Color(0xFF00885d)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Name
              const Text("Name", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: "e.g. Groceries",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: .8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF00885d),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Color (disabled when image chosen) ───────────────────
              _sectionLabel("Color"),
              const SizedBox(height: 8),
              Opacity(
                opacity: _usingImage ? 0.35 : 1.0,
                child: AbsorbPointer(
                  absorbing: _usingImage,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kCategoryColors.map((c) {
                      final sel = c.value == _selectedColor.value;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: sel
                                ? Border.all(color: Colors.black, width: 2.5)
                                : null,
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                      color: c.withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          child: sel
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Icon grid (disabled when image chosen) ───────────────
              _sectionLabel("Icon"),
              const SizedBox(height: 8),
              Opacity(
                opacity: _usingImage ? 0.35 : 1.0,
                child: AbsorbPointer(
                  absorbing: _usingImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                      itemCount: kCategoryIcons.length,
                      itemBuilder: (_, i) {
                        final ic = kCategoryIcons[i];
                        final sel =
                            !_usingImage &&
                            ic.codePoint == _selectedIcon.codePoint;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedIcon = ic;
                            _galleryImagePath = null;
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: sel
                                  ? _selectedColor.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: sel
                                  ? Border.all(
                                      color: _selectedColor,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              ic,
                              size: 22,
                              color: sel
                                  ? _selectedColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Gallery row ──────────────────────────────────────────
              GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: _usingImage
                        ? const Color(0xFF00885d).withOpacity(0.06)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _usingImage
                          ? const Color(0xFF00885d).withOpacity(0.4)
                          : Colors.grey.shade300,
                      width: _usingImage ? 1.2 : .8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Preview thumbnail when image is selected
                      if (_usingImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(_galleryImagePath!),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Icon(
                          Icons.photo_library_outlined,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      const SizedBox(width: 10),
                      Text(
                        _usingImage
                            ? "Image selected — tap to change"
                            : "Choose from gallery",
                        style: TextStyle(
                          color: _usingImage
                              ? const Color(0xFF00885d)
                              : Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: _usingImage
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      if (_usingImage) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _galleryImagePath = null),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00885d),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeTab(String value, String label, Color activeColor) {
    final sel = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: sel ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sel ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
