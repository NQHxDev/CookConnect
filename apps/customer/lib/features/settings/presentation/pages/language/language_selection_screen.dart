import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = ApiI18n.currentLanguage;
  }

  void _onLanguageSelected(String code) {
    setState(() {
      _selectedLanguageCode = code;
    });
    ApiI18n.currentLanguage = code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ApiI18n.text(UiI18nKeys.settingsLanguage),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Category header 1: Khả dụng / Available
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                ApiI18n.text(UiI18nKeys.settingsLanguageAvailable),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Selectable languages container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildLanguageItem(
                    name: ApiI18n.text(UiI18nKeys.settingsLanguageVietnamese),
                    nativeName: ApiI18n.text(UiI18nKeys.settingsLanguageVietnameseSubtitle),
                    code: ApiI18n.vi,
                    isSelected: _selectedLanguageCode == ApiI18n.vi,
                    isEnabled: true,
                    onTap: () => _onLanguageSelected(ApiI18n.vi),
                  ),
                  _buildDivider(),
                  _buildLanguageItem(
                    name: ApiI18n.text(UiI18nKeys.settingsLanguageEnglish),
                    nativeName: ApiI18n.text(UiI18nKeys.settingsLanguageEnglishSubtitle),
                    code: ApiI18n.en,
                    isSelected: _selectedLanguageCode == ApiI18n.en,
                    isEnabled: true,
                    onTap: () => _onLanguageSelected(ApiI18n.en),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category header 2: Sắp ra mắt / Coming soon
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                ApiI18n.text(UiI18nKeys.settingsLanguageComingSoon),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Disabled languages container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildLanguageItem(
                    name: ApiI18n.text(UiI18nKeys.settingsLanguageChinese),
                    nativeName: ApiI18n.text(UiI18nKeys.settingsLanguageChineseSubtitle),
                    code: 'zh',
                    isSelected: false,
                    isEnabled: false,
                  ),
                  _buildDivider(),
                  _buildLanguageItem(
                    name: ApiI18n.text(UiI18nKeys.settingsLanguageJapanese),
                    nativeName: ApiI18n.text(UiI18nKeys.settingsLanguageJapaneseSubtitle),
                    code: 'ja',
                    isSelected: false,
                    isEnabled: false,
                  ),
                  _buildDivider(),
                  _buildLanguageItem(
                    name: ApiI18n.text(UiI18nKeys.settingsLanguageKorean),
                    nativeName: ApiI18n.text(UiI18nKeys.settingsLanguageKoreanSubtitle),
                    code: 'ko',
                    isSelected: false,
                    isEnabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildLanguageItem({
    required String name,
    required String nativeName,
    required String code,
    required bool isSelected,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? Colors.black87 : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nativeName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.normal,
                        color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (isEnabled && isSelected)
                Icon(
                  Iconsax.tick_circle,
                  color: primaryColor,
                  size: 20,
                )
              else if (!isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ApiI18n.text(UiI18nKeys.settingsLanguageSoonBadge),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
