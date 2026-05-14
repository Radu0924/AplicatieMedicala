import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_top_bar.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  File? _pickedImage;

  final _picker = ImagePicker();

  final List<String> _categories = [
    'Temperatură necorespunzătoare',
    'Defecțiune Senzor',
    'Baterie descărcată',
    'Problemă aplicație',
    'Altceva',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (picked != null && mounted) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nu s-a putut accesa camera sau galeria.')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Fotografiază'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Alege din galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_pickedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.statusCritical),
                title: const Text('Șterge fotografia'),
                textColor: AppColors.statusCritical,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _pickedImage = null);
                },
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vă rugăm să completați toate câmpurile.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Raportul a fost trimis cu succes.'),
        backgroundColor: AppColors.statusOk,
      ),
    );
    context.pop();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ce problemă întâmpinați?',
              style: AppTypography.headlineLg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Categorie',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Descrieți problema',
              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Ex: Temperatura a crescut brusc după deschiderea ușii...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Photo section
            GestureDetector(
              onTap: _showPhotoOptions,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minHeight: 120),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: _pickedImage != null
                        ? AppColors.secondary
                        : AppColors.outlineVariant,
                    width: _pickedImage != null ? 1.5 : 1.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _pickedImage != null
                    ? Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Image.file(
                            _pickedImage!,
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          ),
                          Positioned(
                            top: AppSpacing.sm,
                            right: AppSpacing.sm,
                            child: GestureDetector(
                              onTap: () => setState(() => _pickedImage = null),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppSpacing.xl),
                          Icon(
                            Icons.add_a_photo,
                            color: AppColors.textDimmed,
                            size: 32,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Adaugă o fotografie (Opțional)',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textDimmed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Atinge pentru cameră sau galerie',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.outline,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            FilledButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Trimite Raportul'),
            ),
          ],
        ),
      ),
    );
  }
}
