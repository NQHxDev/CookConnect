import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';

enum HelpTopicType { recipes, account, privacy, community, troubleshooting }

class _FaqItemData {
  final String id;
  final String questionKey;
  final String answerKey;
  final HelpTopicType topic;

  const _FaqItemData({
    required this.id,
    required this.questionKey,
    required this.answerKey,
    required this.topic,
  });
}

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  HelpTopicType? _selectedTopic;

  // Track expanded state for FAQ items
  final Set<String> _expandedFaqIds = <String>{};

  // Track user helpfulness votes: item id -> true (helpful) / false (not helpful)
  final Map<String, bool> _feedbackVotes = <String, bool>{};

  final List<_FaqItemData> _faqList = const [
    _FaqItemData(
      id: 'faq_post_recipe',
      questionKey: UiI18nKeys.helpCenterFaqPostRecipeQ,
      answerKey: UiI18nKeys.helpCenterFaqPostRecipeA,
      topic: HelpTopicType.recipes,
    ),
    _FaqItemData(
      id: 'faq_save_recipe',
      questionKey: UiI18nKeys.helpCenterFaqSaveRecipeQ,
      answerKey: UiI18nKeys.helpCenterFaqSaveRecipeA,
      topic: HelpTopicType.recipes,
    ),
    _FaqItemData(
      id: 'faq_forgot_password',
      questionKey: UiI18nKeys.helpCenterFaqForgotPasswordQ,
      answerKey: UiI18nKeys.helpCenterFaqForgotPasswordA,
      topic: HelpTopicType.account,
    ),
    _FaqItemData(
      id: 'faq_verified_chef',
      questionKey: UiI18nKeys.helpCenterFaqVerifiedChefQ,
      answerKey: UiI18nKeys.helpCenterFaqVerifiedChefA,
      topic: HelpTopicType.account,
    ),
    _FaqItemData(
      id: 'faq_report_violation',
      questionKey: UiI18nKeys.helpCenterFaqReportViolationQ,
      answerKey: UiI18nKeys.helpCenterFaqReportViolationA,
      topic: HelpTopicType.privacy,
    ),
    _FaqItemData(
      id: 'faq_app_lag',
      questionKey: UiI18nKeys.helpCenterFaqAppLagQ,
      answerKey: UiI18nKeys.helpCenterFaqAppLagA,
      topic: HelpTopicType.troubleshooting,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (_searchQuery != text) {
        setState(() {
          _searchQuery = text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItemData> _getFilteredFaqs() {
    return _faqList.where((item) {
      if (_selectedTopic != null && item.topic != _selectedTopic) {
        return false;
      }
      if (_searchQuery.isEmpty) {
        return true;
      }
      final q = ApiI18n.text(item.questionKey).toLowerCase();
      final a = ApiI18n.text(item.answerKey).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return q.contains(query) || a.contains(query);
    }).toList();
  }

  void _clearSearchAndFilter() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedTopic = null;
    });
  }

  void _showReportSheet(BuildContext context, {required bool isBugReport}) {
    final textController = TextEditingController();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final title = isBugReport
        ? ApiI18n.text(UiI18nKeys.helpCenterReportProblem)
        : ApiI18n.text(UiI18nKeys.helpCenterSendFeedback);
    final desc = isBugReport
        ? ApiI18n.text(UiI18nKeys.helpCenterReportProblemDesc)
        : ApiI18n.text(UiI18nKeys.helpCenterSendFeedbackDesc);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey[600],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: ApiI18n.text(
                        UiI18nKeys.helpCenterReportPlaceholder,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(
                        ApiI18n.text(UiI18nKeys.helpCenterCancel),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                ApiI18n.text(UiI18nKeys.helpCenterReportSent),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      },
                      child: Text(
                        ApiI18n.text(UiI18nKeys.helpCenterSend),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ApiI18n.languageNotifier,
      builder: (context, currentLanguage, child) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final filteredFaqs = _getFilteredFaqs();

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
              ApiI18n.text(UiI18nKeys.settingsHelpCenter),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
          body: SafeArea(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Hero Support Banner Card
                  _buildHeroBanner(primaryColor),

                  const SizedBox(height: 12),

                  // Search bar
                  _buildSearchBar(),

                  const SizedBox(height: 6),

                  // Selected filter indicator chip
                  if (_selectedTopic != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getTopicTitle(_selectedTopic!),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTopic = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _clearSearchAndFilter,
                            child: Text(
                              ApiI18n.text(UiI18nKeys.helpCenterAllTopics),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Topics Section
                  if (_searchQuery.isEmpty && _selectedTopic == null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        ApiI18n.text(UiI18nKeys.helpCenterTopics),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _buildTopicItem(
                            icon: Iconsax.book_1,
                            title: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicRecipes,
                            ),
                            subtitle: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicRecipesSubtitle,
                            ),
                            topic: HelpTopicType.recipes,
                          ),
                          _buildTopicItem(
                            icon: Iconsax.user_octagon,
                            title: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicAccount,
                            ),
                            subtitle: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicAccountSubtitle,
                            ),
                            topic: HelpTopicType.account,
                          ),
                          _buildTopicItem(
                            icon: Iconsax.shield_tick,
                            title: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicPrivacy,
                            ),
                            subtitle: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicPrivacySubtitle,
                            ),
                            topic: HelpTopicType.privacy,
                          ),
                          _buildTopicItem(
                            icon: Iconsax.messages_2,
                            title: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicCommunity,
                            ),
                            subtitle: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicCommunitySubtitle,
                            ),
                            topic: HelpTopicType.community,
                          ),
                          _buildTopicItem(
                            icon: Iconsax.setting_2,
                            title: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicTroubleshooting,
                            ),
                            subtitle: ApiI18n.text(
                              UiI18nKeys.helpCenterTopicTroubleshootingSubtitle,
                            ),
                            topic: HelpTopicType.troubleshooting,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // FAQ Section Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.helpCenterFaq),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  // FAQ Items List
                  if (filteredFaqs.isEmpty)
                    _buildEmptySearchResult()
                  else
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int i = 0; i < filteredFaqs.length; i++)
                            _buildFaqItem(filteredFaqs[i]),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Support & Contact Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.helpCenterNeedHelp),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildActionItem(
                          icon: Iconsax.warning_2,
                          title: ApiI18n.text(
                            UiI18nKeys.helpCenterReportProblem,
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.helpCenterReportProblemSubtitle,
                          ),
                          onTap: () =>
                              _showReportSheet(context, isBugReport: true),
                        ),
                        _buildActionItem(
                          icon: Iconsax.message_edit,
                          title: ApiI18n.text(
                            UiI18nKeys.helpCenterSendFeedback,
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.helpCenterSendFeedbackSubtitle,
                          ),
                          onTap: () =>
                              _showReportSheet(context, isBugReport: false),
                        ),
                        _buildActionItem(
                          icon: Iconsax.sms,
                          title: ApiI18n.text(
                            UiI18nKeys.helpCenterContactEmail,
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.helpCenterContactEmailSubtitle,
                          ),
                          onTap: () {
                            Clipboard.setData(
                              const ClipboardData(
                                text: 'support@cookconnect.app',
                              ),
                            );
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ApiI18n.text(
                                      UiI18nKeys.helpCenterEmailCopied,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.message_question,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ApiI18n.text(UiI18nKeys.helpCenterHeroTitle),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ApiI18n.text(UiI18nKeys.helpCenterHeroSubtitle),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey[700],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.headphone, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        ApiI18n.text(UiI18nKeys.helpCenterHeroBadge),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: ApiI18n.text(UiI18nKeys.helpCenterSearchPlaceholder),
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
            prefixIcon: Icon(
              Iconsax.search_normal,
              size: 16,
              color: Colors.grey[500],
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _getTopicTitle(HelpTopicType topic) {
    switch (topic) {
      case HelpTopicType.recipes:
        return ApiI18n.text(UiI18nKeys.helpCenterTopicRecipes);
      case HelpTopicType.account:
        return ApiI18n.text(UiI18nKeys.helpCenterTopicAccount);
      case HelpTopicType.privacy:
        return ApiI18n.text(UiI18nKeys.helpCenterTopicPrivacy);
      case HelpTopicType.community:
        return ApiI18n.text(UiI18nKeys.helpCenterTopicCommunity);
      case HelpTopicType.troubleshooting:
        return ApiI18n.text(UiI18nKeys.helpCenterTopicTroubleshooting);
    }
  }

  Widget _buildTopicItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required HelpTopicType topic,
  }) {
    final isSelected = _selectedTopic == topic;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: isSelected
          ? primaryColor.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTopic = isSelected ? null : topic;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16.5,
                color: isSelected ? primaryColor : Colors.black87,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: isSelected ? primaryColor : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(_FaqItemData item) {
    final isExpanded = _expandedFaqIds.contains(item.id);
    final vote = _feedbackVotes[item.id];
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedFaqIds.remove(item.id);
                } else {
                  _expandedFaqIds.add(item.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.message_question,
                    size: 16.5,
                    color: isExpanded ? primaryColor : Colors.black87,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      ApiI18n.text(item.questionKey),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isExpanded ? primaryColor : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: isExpanded ? primaryColor : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.fromLTRB(46, 0, 16, 14),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ApiI18n.text(item.answerKey),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Helpful feedback widget
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ApiI18n.text(UiI18nKeys.helpCenterWasHelpful),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      if (vote != null)
                        Text(
                          ApiI18n.text(UiI18nKeys.helpCenterFeedbackThanks),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        )
                      else ...[
                        InkWell(
                          onTap: () {
                            setState(() {
                              _feedbackVotes[item.id] = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.like_1,
                                  size: 13,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ApiI18n.text(UiI18nKeys.helpCenterYes),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _feedbackVotes[item.id] = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.dislike,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ApiI18n.text(UiI18nKeys.helpCenterNo),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 16.5, color: Colors.black87),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Iconsax.search_status, size: 38, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            ApiI18n.text(UiI18nKeys.helpCenterNoResultsTitle),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ApiI18n.text(UiI18nKeys.helpCenterNoResultsDesc),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey[600],
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: _clearSearchAndFilter,
            child: Text(
              ApiI18n.text(UiI18nKeys.helpCenterClearSearch),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
