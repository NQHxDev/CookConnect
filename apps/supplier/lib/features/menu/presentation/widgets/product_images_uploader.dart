import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';

/// Modern product images uploader widget for Supplier app.
/// Designed specifically for food & supplier e-commerce products with:
/// - Prominent Hero Cover slot (tỷ lệ chuẩn, nổi bật bộ mặt sản phẩm)
/// - Sub-gallery slots with one-tap "Đặt làm ảnh bìa"
/// - Dynamic progress bar tracking the 5-photo minimum requirement
/// - Collapsible food photography tips (Góc chụp chuẩn xét duyệt)
/// - Interactive full-screen preview lightbox
/// - Modern image picker bottom sheet (Camera / Multi-gallery)
class ProductImagesUploader extends StatefulWidget {
  final List<String> images;
  final ValueChanged<List<String>> onImagesChanged;
  final int minImages;
  final int maxImages;

  const ProductImagesUploader({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.minImages = 5,
    this.maxImages = 10,
  });

  @override
  State<ProductImagesUploader> createState() => _ProductImagesUploaderState();
}

class _ProductImagesUploaderState extends State<ProductImagesUploader> {
  final ImagePicker _picker = ImagePicker();
  bool _showTips = false;

  bool get _hasCover => widget.images.isNotEmpty;
  bool get _hasEnoughImages => widget.images.length >= widget.minImages;

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (photo != null) {
          final updated = List<String>.from(widget.images)..add(photo.path);
          widget.onImagesChanged(updated);
        }
      } else {
        final List<XFile> picked = await _picker.pickMultiImage(
          imageQuality: 85,
        );
        if (picked.isNotEmpty) {
          final remaining = widget.maxImages - widget.images.length;
          final toAdd = picked.take(remaining).map((e) => e.path).toList();
          final updated = List<String>.from(widget.images)..addAll(toAdd);
          widget.onImagesChanged(updated);

          if (picked.length > remaining && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã đạt giới hạn tối đa ${widget.maxImages} ảnh.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.camera, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tải lên hình ảnh thực phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hỗ trợ JPG, PNG • Tối đa 10 ảnh',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Option 1: Máy ảnh
              _buildPickerActionCard(
                icon: Iconsax.camera,
                iconColor: AppColors.primary,
                title: 'Chụp ảnh thực phẩm mới',
                subtitle: 'Chụp trực tiếp từ camera, bắt trọn độ tươi ngon',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImages(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),

              // Option 2: Thư viện
              _buildPickerActionCard(
                icon: Iconsax.gallery,
                iconColor: const Color(0xFF0288D1),
                title: 'Chọn ảnh từ thư viện thiết bị',
                subtitle: 'Có thể chọn cùng lúc nhiều ảnh có sẵn',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImages(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  void _setAsCover(int index) {
    if (index <= 0 || index >= widget.images.length) return;
    final updated = List<String>.from(widget.images);
    final selected = updated.removeAt(index);
    updated.insert(0, selected);
    widget.onImagesChanged(updated);
  }

  void _removeImage(int index) {
    if (index < 0 || index >= widget.images.length) return;
    final updated = List<String>.from(widget.images)..removeAt(index);
    widget.onImagesChanged(updated);
  }

  void _openPreviewLightbox(int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => _ImagePreviewLightbox(
        images: widget.images,
        initialIndex: initialIndex,
        onSetCover: (idx) {
          _setAsCover(idx);
          Navigator.of(ctx).pop();
        },
        onDelete: (idx) {
          _removeImage(idx);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(Iconsax.image, color: AppColors.textHint, size: 28),
          ),
        ),
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(Iconsax.image, color: AppColors.textHint, size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Badge & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.gallery_favorite, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hình ảnh sản phẩm *',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tối thiểu 5 ảnh thực tế rõ nét',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _hasEnoughImages
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hasEnoughImages
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasEnoughImages ? Icons.check_circle : Iconsax.gallery,
                      size: 13,
                      color: _hasEnoughImages ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$count/${widget.minImages} ảnh tối thiểu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _hasEnoughImages ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Hero Cover Image Card
          _buildHeroCoverSection(),

          // 3. Secondary Images Section (if cover exists or multi-images)
          if (_hasCover) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ảnh chi tiết & góc chụp',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${count > 1 ? count - 1 : 0} ảnh',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    'Chạm để xem / Đặt làm bìa',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSubImagesGallery(),
          ],

          const SizedBox(height: 14),

          // 4. Expandable Food Photo Tips (Gợi ý góc chụp chuẩn)
          _buildPhotoGuideCard(),
        ],
      ),
    );
  }

  /// Hero Cover Slot: Displays the primary cover image or large empty drop-zone
  Widget _buildHeroCoverSection() {
    if (!_hasCover) {
      // Empty state Hero Card
      return InkWell(
        onTap: _showPickerBottomSheet,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Iconsax.camera, color: AppColors.primary, size: 26),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tải lên ảnh bìa sản phẩm (Bắt buộc)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ấn để chụp hoặc chọn nhiều ảnh từ thiết bị',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuickActionChip(
                    icon: Iconsax.camera,
                    label: 'Chụp ảnh',
                    onTap: () => _pickImages(ImageSource.camera),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    icon: Iconsax.gallery,
                    label: 'Thư viện',
                    onTap: () => _pickImages(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Populated Hero Cover Image
    final coverPath = widget.images.first;

    return Container(
      width: double.infinity,
      height: 195,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            GestureDetector(
              onTap: () => _openPreviewLightbox(0),
              child: _buildImageWidget(coverPath),
            ),

            // Top gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Cover badge (Bottom-Left)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.star5, color: Colors.amber, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Ảnh bìa đại diện',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons (Top-Right)
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  // Fullscreen preview
                  _buildCoverTopButton(
                    icon: Iconsax.maximize_4,
                    tooltip: 'Xem ảnh lớn',
                    onTap: () => _openPreviewLightbox(0),
                  ),
                  const SizedBox(width: 6),
                  // Change cover
                  _buildCoverTopButton(
                    icon: Iconsax.camera,
                    tooltip: 'Thêm/Đổi ảnh',
                    onTap: _showPickerBottomSheet,
                  ),
                  const SizedBox(width: 6),
                  // Delete cover
                  _buildCoverTopButton(
                    icon: Iconsax.trash,
                    tooltip: 'Xóa ảnh bìa',
                    color: AppColors.error,
                    onTap: () => _removeImage(0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverTopButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color ?? Colors.white, size: 15),
        ),
      ),
    );
  }

  /// Secondary Images Gallery: Displays slots for photos #2, #3, ... with + Add Button
  Widget _buildSubImagesGallery() {
    final canAddMore = widget.images.length < widget.maxImages;

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.images.length - 1 + (canAddMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // If this is the "Add More" slot at the end
          if (index == widget.images.length - 1) {
            return _buildAddMoreSlot();
          }

          final realIndex = index + 1; // index 0 is cover
          final imagePath = widget.images[realIndex];

          return _buildSubImageTile(imagePath, realIndex);
        },
      ),
    );
  }

  Widget _buildSubImageTile(String path, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openPreviewLightbox(index),
          child: Container(
            width: 86,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _buildImageWidget(path),
            ),
          ),
        ),

        // Index chip (#2, #3, ...)
        Positioned(
          top: 5,
          left: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '#${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Delete button (Top Right)
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 11),
            ),
          ),
        ),

        // Set as Cover Quick Button (Bottom bar)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _setAsCover(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.star, color: Colors.amber, size: 10),
                  SizedBox(width: 3),
                  Text(
                    'Làm bìa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreSlot() {
    return InkWell(
      onTap: _showPickerBottomSheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 86,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasEnoughImages ? Colors.grey.shade300 : AppColors.primary.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _hasEnoughImages
                    ? Colors.grey.shade200
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.add,
                size: 18,
                color: _hasEnoughImages ? AppColors.textSecondary : AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '+ Thêm ảnh',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _hasEnoughImages ? AppColors.textSecondary : AppColors.primary,
              ),
            ),
            Text(
              '${widget.images.length}/${widget.maxImages}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  /// Collapsible Food Photography Guide
  Widget _buildPhotoGuideCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showTips = !_showTips),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Iconsax.lamp_on, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Gợi ý 4 góc chụp thực phẩm chuẩn duyệt nhanh',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _showTips ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_showTips) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTipItem(
                    number: '1',
                    title: 'Ảnh bìa toàn cảnh',
                    desc: 'Chụp chính diện, ánh sáng tự nhiên, hiển thị rõ nét toàn bộ thực phẩm.',
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem(
                    number: '2',
                    title: 'Cận cảnh chi tiết',
                    desc: 'Chụp gần để thấy vân thịt tươi, độ bóng, màu sắc tự nhiên của món ăn.',
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem(
                    number: '3',
                    title: 'Bao bì & Tem nhãn',
                    desc: 'Chụp rõ nhãn hiệu, tem phụ, hạn sử dụng (HSD) và nguồn gốc xuất xứ.',
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem(
                    number: '4',
                    title: 'Quy cách đóng gói',
                    desc: 'Chụp hộp/khay/túi hút chân không thực tế khi giao tới tay khách hàng.',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required String number,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Fullscreen Image Preview Lightbox
class _ImagePreviewLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ValueChanged<int> onSetCover;
  final ValueChanged<int> onDelete;

  const _ImagePreviewLightbox({
    required this.images,
    required this.initialIndex,
    required this.onSetCover,
    required this.onDelete,
  });

  @override
  State<_ImagePreviewLightbox> createState() => _ImagePreviewLightboxState();
}

class _ImagePreviewLightboxState extends State<_ImagePreviewLightbox> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildFullImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return InteractiveViewer(
        child: Image.network(path, fit: BoxFit.contain),
      );
    }
    return InteractiveViewer(
      child: Image.file(File(path), fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCover = _currentIndex == 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.trash, color: Colors.white),
                    tooltip: 'Xóa ảnh này',
                    onPressed: () => widget.onDelete(_currentIndex),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildFullImage(widget.images[index]),
                    ),
                  );
                },
              ),
            ),

            // Bottom action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                children: [
                  if (isCover)
                    Expanded(
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.star5, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Đang là ảnh bìa chính',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onSetCover(_currentIndex),
                        icon: const Icon(Iconsax.star, color: Colors.amber, size: 18),
                        label: const Text(
                          'Đặt làm ảnh bìa chính',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white38),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
