import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';

class PolicySection {
  final String title;
  final String body;
  final List<String>? bulletPoints;

  const PolicySection({
    required this.title,
    required this.body,
    this.bulletPoints,
  });
}

class PolicyContent {
  final String summary;
  final String lastUpdated;
  final List<PolicySection> sections;

  const PolicyContent({
    required this.summary,
    required this.lastUpdated,
    required this.sections,
  });
}

class PolicyItem {
  final String id;
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final PolicyContent Function(String lang) contentBuilder;

  const PolicyItem({
    required this.id,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.contentBuilder,
  });
}

class TermsData {
  TermsData._();

  static const String legalEmail = 'legal@cookconnect.app';
  static const String supportEmail = 'support@cookconnect.app';

  // 1. Terms of Service
  static final PolicyItem termsOfService = PolicyItem(
    id: 'terms_of_service',
    icon: Iconsax.document_text,
    titleKey: UiI18nKeys.termsTermsOfService,
    subtitleKey: UiI18nKeys.termsTermsOfServiceSubtitle,
    contentBuilder: (lang) => lang == 'en'
        ? const PolicyContent(
            summary:
                'These Terms of Service govern your access to and use of CookConnect, including our culinary video feed, recipe sharing tools, and community interactions. By creating an account or browsing content, you agree to these terms.',
            lastUpdated: 'Last updated: October 2026',
            sections: [
              PolicySection(
                title: '1. Acceptance of Terms',
                body:
                    'By downloading, accessing, or using the CookConnect mobile application and related services, you confirm that you are at least 13 years old (or the minimum legal age in your jurisdiction) and agree to be legally bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use CookConnect.',
              ),
              PolicySection(
                title: '2. Account Registration and Security',
                body:
                    'To unlock full culinary features such as uploading video recipes, commenting, and bookmarking favorite dishes, you must register an account.',
                bulletPoints: [
                  'You must provide accurate, current, and complete registration information.',
                  'You are solely responsible for maintaining the confidentiality of your login credentials and password.',
                  'You must immediately notify CookConnect if you suspect any unauthorized access to your account.',
                  'You may not share or transfer your account credentials to third parties without prior written consent.',
                ],
              ),
              PolicySection(
                title: '3. User Content and Cooking Media',
                body:
                    'CookConnect allows chefs, food enthusiasts, and creators to post videos, photos, ingredient lists, preparation steps, and culinary tips.',
                bulletPoints: [
                  'You retain ownership of the original culinary content you create and upload.',
                  'By posting content, you grant CookConnect a worldwide, non-exclusive, royalty-free license to host, display, reproduce, and distribute your content across our services.',
                  'You represent and warrant that your content does not violate any third-party intellectual property or publicity rights.',
                ],
              ),
              PolicySection(
                title: '4. Prohibited Conduct',
                body:
                    'To maintain an enjoyable, safe environment for home cooks and culinary masters alike, the following behaviors are strictly prohibited:',
                bulletPoints: [
                  'Uploading videos promoting hazardous food practices, non-edible chemical consumption, or harmful viral kitchen challenges.',
                  'Engaging in harassment, hate speech, or derogatory remarks directed at other culinary cultures, dietary choices, or creators.',
                  'Posting spam, automated marketing schemes, deceptive dietary supplements, or phishing links.',
                  'Attempting to reverse engineer, scrape, or interfere with the integrity of the CookConnect platform.',
                ],
              ),
              PolicySection(
                title: '5. Account Termination and Suspension',
                body:
                    'CookConnect reserves the right to suspend or permanently terminate accounts that repeatedly breach our Terms of Service, Community Guidelines, or applicable laws. You may deactivate or permanently delete your account at any time via Settings & Privacy > Account.',
              ),
              PolicySection(
                title: '6. Limitation of Liability',
                body:
                    'CookConnect is provided "as is" and "as available". We do not warrant that recipes uploaded by users are allergen-free, nutritionally verified, or free from culinary error. Your preparation and consumption of any food based on user content is undertaken at your own risk.',
              ),
            ],
          )
        : const PolicyContent(
            summary:
                'Điều khoản Dịch vụ này quy định quyền hạn và trách nhiệm khi bạn truy cập, sử dụng mạng xã hội video nấu ăn và chia sẻ công thức CookConnect. Bằng việc đăng ký hoặc tiếp tục sử dụng ứng dụng, bạn đồng ý với các điều khoản dưới đây.',
            lastUpdated: 'Cập nhật lần cuối: Tháng 10, 2026',
            sections: [
              PolicySection(
                title: '1. Chấp thuận Điều khoản',
                body:
                    'Bằng việc tải về, đăng ký hoặc sử dụng ứng dụng CookConnect, bạn xác nhận rằng mình từ đủ 13 tuổi trở lên (hoặc độ tuổi theo luật định tại quốc gia sở tại) và đồng ý tuân thủ toàn bộ Điều khoản Dịch vụ này cùng Chính sách Quyền riêng tư của chúng tôi. Nếu bạn không đồng ý với bất kỳ nội dung nào, vui lòng ngừng sử dụng dịch vụ.',
              ),
              PolicySection(
                title: '2. Đăng ký & Bảo mật Tài khoản',
                body:
                    'Để trải nghiệm đầy đủ các tính năng như đăng tải video nấu ăn, lưu công thức yêu thích, bình luận và theo dõi các đầu bếp, bạn cần tạo tài khoản cá nhân.',
                bulletPoints: [
                  'Cung cấp thông tin chính xác, đầy đủ và cập nhật khi đăng ký tài khoản.',
                  'Có trách nhiệm bảo mật mật khẩu, passkey và thông tin xác thực tài khoản cá nhân.',
                  'Thông báo ngay lập tức cho CookConnect nếu phát hiện bất kỳ dấu hiệu truy cập trái phép nào.',
                  'Không chuyển nhượng hoặc cho phép người khác sử dụng tài khoản khi chưa có sự đồng ý.',
                ],
              ),
              PolicySection(
                title: '3. Quyền sở hữu & Nội dung Ẩm thực',
                body:
                    'CookConnect là sân chơi dành cho cộng đồng yêu bếp chia sẻ video ngắn, hình ảnh món ăn, danh sách nguyên liệu và các bước chế biến.',
                bulletPoints: [
                  'Bạn giữ quyền sở hữu đối với các công thức, hình ảnh và video ẩm thực do chính mình tạo ra và đăng tải.',
                  'Khi đăng nội dung lên CookConnect, bạn cấp cho chúng tôi quyền miễn phí bản quyền trên phạm vi toàn cầu để lưu trữ, hiển thị, phân phối và quảng bá nội dung đó trên hệ thống của CookConnect.',
                  'Bạn cam kết rằng nội dung đăng tải không vi phạm bản quyền, nhãn hiệu hoặc quyền riêng tư của bất kỳ cá nhân hay tổ chức nào.',
                ],
              ),
              PolicySection(
                title: '4. Các hành vi bị nghiêm cấm',
                body:
                    'Nhằm giữ gìn không gian bếp văn minh, tích cực và an toàn cho tất cả mọi người, các hành vi sau đây bị nghiêm cấm:',
                bulletPoints: [
                  'Chia sẻ nội dung hướng dẫn chế biến thực phẩm cực độc, nuốt hóa chất nguy hiểm hoặc các thử thách ẩm thực gây hại đến tính mạng.',
                  'Quấy rối, kích động thù địch, miệt thị văn hóa ẩm thực vùng miền, tôn giáo hoặc công kích cá nhân đầu bếp khác.',
                  'Spam bình luận quảng cáo thuốc đông y giả mạo, thực phẩm chức năng không rõ nguồn gốc hoặc gửi liên kết lừa đảo.',
                  'Sử dụng công cụ tự động (bot, scraper) để thu thập dữ liệu trái phép hoặc phá hoại hệ thống CookConnect.',
                ],
              ),
              PolicySection(
                title: '5. Chấm dứt & Khóa tài khoản',
                body:
                    'CookConnect có quyền tạm đình chỉ hoặc xóa vĩnh viễn các tài khoản vi phạm nghiêm trọng hoặc tái phạm nhiều lần các Điều khoản Dịch vụ. Bạn cũng có thể chủ động hủy kích hoạt hoặc yêu cầu xóa vĩnh viễn tài khoản của mình bất kỳ lúc nào trong mục Cài đặt & Quyền riêng tư > Tài khoản.',
              ),
              PolicySection(
                title: '6. Giới hạn Trách nhiệm',
                body:
                    'CookConnect được cung cấp theo nguyên tắc "nguyên trạng". Chúng tôi không cam đoan các công thức do người dùng đăng tải hoàn toàn chính xác về định lượng dinh dưỡng hoặc miễn nhiễm dị ứng. Việc chuẩn bị nguyên liệu, kiểm tra độ an toàn và chế biến món ăn hoàn toàn thuộc về sự thận trọng của chính bạn.',
              ),
            ],
          ),
  );

  // 2. Privacy Policy
  static final PolicyItem privacyPolicy = PolicyItem(
    id: 'privacy_policy',
    icon: Iconsax.shield_tick,
    titleKey: UiI18nKeys.termsPrivacyPolicy,
    subtitleKey: UiI18nKeys.termsPrivacyPolicySubtitle,
    contentBuilder: (lang) => lang == 'en'
        ? const PolicyContent(
            summary:
                'Your privacy is essential to us. This policy outlines what personal culinary preferences, interaction logs, and device data CookConnect collects, how we use it to recommend recipes, and how you retain complete control over your data.',
            lastUpdated: 'Last updated: October 2026',
            sections: [
              PolicySection(
                title: '1. Information We Collect',
                body:
                    'We collect information to deliver a personalized cooking experience, keep our community safe, and improve app performance.',
                bulletPoints: [
                  'Account Data: Name, username, email address, date of birth, and profile bio.',
                  'Culinary Interests: Recipe bookmarks, liked videos, search queries, and dietary preferences.',
                  'Content: Photos, cooking videos, ingredient checklists, comments, and messages.',
                  'Device & Technical: Device model, operating system, IP address, and network performance indicators.',
                ],
              ),
              PolicySection(
                title: '2. How We Use Your Information',
                body:
                    'Your data allows CookConnect to power personalized recommendations and improve community engagement:',
                bulletPoints: [
                  'Tailoring the "For You" feed with recipes and videos matched to your taste.',
                  'Enabling social interactions: following creators, comments, and direct messaging.',
                  'Protecting account integrity, preventing fraud, and enforcing community safety.',
                  'Analyzing trends to enhance video playback efficiency and app features.',
                ],
              ),
              PolicySection(
                title: '3. Data Sharing & Disclosure',
                body:
                    'We respect your personal privacy. CookConnect never sells your personal identifiable information to third parties. Data is only shared in restricted circumstances, such as with trusted cloud service providers bound by strict confidentiality, or when legally compelled by law enforcement.',
              ),
              PolicySection(
                title: '4. Data Security and Retention',
                body:
                    'We employ industry-standard encryption, firewalls, and secure tokenized authentication to safeguard your information against unauthorized access. We retain your data only for as long as your account remains active or as required by law.',
              ),
              PolicySection(
                title: '5. Your Rights and Choices',
                body:
                    'You maintain complete control over your data on CookConnect. Through Settings & Privacy, you may update your profile, adjust recipe visibility, disable personalized ads, export a copy of your personal data, or delete your account entirely.',
              ),
            ],
          )
        : const PolicyContent(
            summary:
                'Quyền riêng tư của bạn là ưu tiên hàng đầu của chúng tôi. Chính sách này minh bạch cách CookConnect thu thập, xử lý sở thích ẩm thực, dữ liệu tài khoản và bảo vệ bạn trong suốt quá trình đồng hành cùng gian bếp CookConnect.',
            lastUpdated: 'Cập nhật lần cuối: Tháng 10, 2026',
            sections: [
              PolicySection(
                title: '1. Dữ liệu chúng tôi thu thập',
                body:
                    'Chúng tôi thu thập dữ liệu nhằm cung cấp cho bạn những gợi ý món ăn ngon nhất và cải thiện chất lượng dịch vụ:',
                bulletPoints: [
                  'Thông tin tài khoản: Tên hiển thị, email, số điện thoại, ngày sinh và ảnh đại diện.',
                  'Sở thích ẩm thực: Món ăn đã lưu, video đã thích, lịch sử tìm kiếm công thức và thói quen ăn uống.',
                  'Nội dung chia sẻ: Video nấu nướng, hình ảnh món ăn, công thức chế biến và bình luận thảo luận.',
                  'Dữ liệu thiết bị & kỹ thuật: Kiểu máy, phiên bản hệ điều hành, địa chỉ IP và nhật ký tương tác.',
                ],
              ),
              PolicySection(
                title: '2. Cách chúng tôi sử dụng dữ liệu',
                body:
                    'Thông tin của bạn được sử dụng vào các mục đích hợp pháp và minh bạch:',
                bulletPoints: [
                  'Gợi ý các video món ăn và công thức phù hợp với khẩu vị của bạn trên trang "Dành cho bạn".',
                  'Hỗ trợ kết nối bạn bè, tương tác với các đầu bếp yêu thích và nhận thông báo công thức mới.',
                  'Phát hiện sớm các hành vi gian lận, spam hoặc đe dọa an toàn tài khoản.',
                  'Tối ưu hóa băng thông truyền tải video và nâng cấp trải nghiệm ứng dụng mượt mà hơn.',
                ],
              ),
              PolicySection(
                title: '3. Chia sẻ thông tin với bên thứ ba',
                body:
                    'CookConnect cam kết không bán hoặc cho thuê dữ liệu cá nhân của bạn. Dữ liệu chỉ được chia sẻ trong phạm vi cần thiết với các đối tác hạ tầng đám mây uy tín (chịu ràng buộc bảo mật tuyệt đối) hoặc khi có yêu cầu pháp lý bắt buộc từ cơ quan có thẩm quyền.',
              ),
              PolicySection(
                title: '4. Lưu trữ và Bảo vệ Dữ liệu',
                body:
                    'Dữ liệu tài khoản của bạn được bảo vệ bằng các tiêu chuẩn mã hóa tiên tiến nhất (TLS/SSL, Token bảo mật, Hash mật khẩu). Chúng tôi chỉ lưu giữ dữ liệu khi tài khoản của bạn còn hoạt động hoặc theo yêu cầu lưu trữ hồ sơ theo luật định.',
              ),
              PolicySection(
                title: '5. Quyền của bạn đối với Dữ liệu cá nhân',
                body:
                    'Bạn có toàn quyền kiểm soát thông tin của mình: chỉnh sửa thông tin trong hồ sơ cá nhân, chuyển đổi tài khoản sang chế độ Riêng tư, tải về bản sao dữ liệu cá nhân hoặc yêu cầu xóa vĩnh viễn toàn bộ dữ liệu trong phần Cài đặt.',
              ),
            ],
          ),
  );

  // 3. Community Guidelines
  static final PolicyItem communityGuidelines = PolicyItem(
    id: 'community_guidelines',
    icon: Iconsax.people,
    titleKey: UiI18nKeys.termsCommunityGuidelines,
    subtitleKey: UiI18nKeys.termsCommunityGuidelinesSubtitle,
    contentBuilder: (lang) => lang == 'en'
        ? const PolicyContent(
            summary:
                'Our Community Guidelines define what is and is not permitted on CookConnect. We want every home cook and professional chef to feel welcome, inspired, and safe.',
            lastUpdated: 'Last updated: October 2026',
            sections: [
              PolicySection(
                title: '1. Respect and Mutual Encouragement',
                body:
                    'Cooking is an art and a personal journey. We celebrate culinary traditions from all cultures and backgrounds.',
                bulletPoints: [
                  'Be kind and constructive in comment sections.',
                  'Never shame or disparage fellow cooks for their skill level, budget, or heritage cuisine.',
                  'Zero tolerance for hate speech, discrimination, harassment, or cyberbullying.',
                ],
              ),
              PolicySection(
                title: '2. Food Safety & Public Health',
                body:
                    'We strictly forbid content that promotes hazardous kitchen behavior or endangers human health:',
                bulletPoints: [
                  'No recipes featuring known toxic plants, dangerous wild mushrooms without clear expert verification, or poisonous chemicals.',
                  'No promoting unsafe raw poultry or spoiled meat consumption challenges.',
                  'Clearly label potential cross-contamination hazards when handling raw meats and seafood.',
                ],
              ),
              PolicySection(
                title: '3. Authenticity & Originality',
                body:
                    'We encourage creators to share their own culinary experiments. When recreating or adapting another creator\'s signature recipe, give proper credit and mention their channel.',
              ),
              PolicySection(
                title: '4. Commercial Integrity',
                body:
                    'Do not post unverified health miracle cures, exaggerated weight loss powders, deceptive affiliate schemes, or repetitive spam in recipe comments.',
              ),
              PolicySection(
                title: '5. Reporting Violations',
                body:
                    'If you encounter a post, recipe, or comment that breaches these guidelines, please use the in-app "Report" button. Our moderation team reviews flagged content 24/7.',
              ),
            ],
          )
        : const PolicyContent(
            summary:
                'Tiêu chuẩn Cộng đồng là kim chỉ nam giúp gian bếp CookConnect luôn văn minh, tôn trọng, an toàn và tràn đầy cảm hứng sáng tạo cho tất cả những người yêu ẩm thực.',
            lastUpdated: 'Cập nhật lần cuối: Tháng 10, 2026',
            sections: [
              PolicySection(
                title: '1. Tôn trọng và Khích lệ lẫn nhau',
                body:
                    'Nấu ăn là đam mê và trải nghiệm cá nhân của mỗi người. CookConnect chào đón và tôn vinh mọi nền ẩm thực, phong cách nấu nướng từ mâm cơm bình dân đến món ăn chuyên nghiệp.',
                bulletPoints: [
                  'Bình luận lịch sự, mang tính xây dựng và động viên tinh thần đầu bếp.',
                  'Không chế giễu, miệt thị kỹ năng nấu nướng, điều kiện gia đình hay văn hóa ăn uống vùng miền.',
                  'Tuyệt đối không dung thứ cho ngôn từ kích động thù địch, xúc phạm danh dự hoặc quấy rối thành viên khác.',
                ],
              ),
              PolicySection(
                title: '2. An toàn Thực phẩm & Sức khỏe Cộng đồng',
                body:
                    'Nghiêm cấm chia sẻ các nội dung tiềm ẩn nguy cơ gây ngộ độc hoặc đe dọa sức khỏe người xem:',
                bulletPoints: [
                  'Không chia sẻ công thức sử dụng thực vật có độc tính cao, nấm dại không rõ nguồn gốc hoặc hóa chất nguy hiểm.',
                  'Không cổ xúy các thử thách ăn thực phẩm sống nhiễm khuẩn nguy cơ cao (như gia cầm sống, ôi thiu).',
                  'Khuyến khích ghi rõ lưu ý về vệ sinh dao thớt và rửa tay khi xử lý nguyên liệu tươi sống.',
                ],
              ),
              PolicySection(
                title: '3. Tính nguyên bản & Tôn trọng bản quyền',
                body:
                    'Khuyến khích các đầu bếp chia sẻ công thức tự sáng chế hoặc bí quyết gia đình. Nếu bạn làm lại (remix) công thức từ đầu bếp khác, hãy gắn thẻ hoặc ghi rõ nguồn cảm hứng để thể hiện sự tôn trọng.',
              ),
              PolicySection(
                title: '4. Chống Spam & Lừa đảo Thương mại',
                body:
                    'Không lợi dụng phần bình luận để chèn link lừa đảo, quảng cáo thực phẩm chức năng thổi phồng công dụng chữa bệnh hoặc bán hàng đa cấp không phép.',
              ),
              PolicySection(
                title: '5. Báo cáo & Cơ chế Xử lý Vi phạm',
                body:
                    'Nếu phát hiện nội dung độc hại hoặc nguy hiểm, bạn có thể nhấn vào nút "Báo cáo" ngay tại bài đăng. Đội ngũ kiểm duyệt của CookConnect sẽ xem xét và xử lý nhanh chóng.',
              ),
            ],
          ),
  );

  // 4. Copyright Policy
  static final PolicyItem copyrightPolicy = PolicyItem(
    id: 'copyright_policy',
    icon: Iconsax.copyright,
    titleKey: UiI18nKeys.termsCopyrightPolicy,
    subtitleKey: UiI18nKeys.termsCopyrightPolicySubtitle,
    contentBuilder: (lang) => lang == 'en'
        ? const PolicyContent(
            summary:
                'We respect intellectual property rights and expect CookConnect creators to do the same. This policy describes our response to copyright infringement and DMCA takedown requests.',
            lastUpdated: 'Last updated: October 2026',
            sections: [
              PolicySection(
                title: '1. Intellectual Property Ownership',
                body:
                    'Creators retain full copyright ownership of the original video footage, voiceovers, photographs, and written culinary steps they produce and post on CookConnect.',
              ),
              PolicySection(
                title: '2. Fair Use and Culinary Inspirations',
                body:
                    'While individual recipe ingredient lists themselves are generally not copyrightable under many legal jurisdictions, the artistic expression—including the unique video presentation, culinary narration, stylized filming, and edited instructions—is protected by copyright law.',
              ),
              PolicySection(
                title: '3. Submitting a Copyright Infringement Notice',
                body:
                    'If you believe your copyrighted work has been copied and posted on CookConnect without authorization, please notify our legal team at legal@cookconnect.app with the following details:',
                bulletPoints: [
                  'Your legal name, contact information, and physical/digital signature.',
                  'Identification of the copyrighted work claimed to have been infringed.',
                  'The exact URL or CookConnect recipe ID of the infringing material.',
                  'A statement made in good faith that the disputed use is not authorized by the copyright owner.',
                ],
              ),
              PolicySection(
                title: '4. Repeat Infringer Policy',
                body:
                    'CookConnect maintains a strict policy regarding repeated copyright violations. Accounts identified as repeat infringers will face video removal and eventual permanent account termination.',
              ),
            ],
          )
        : const PolicyContent(
            summary:
                'CookConnect tôn trọng quyền sở hữu trí tuệ của các nhà sáng tạo nội dung ẩm thực. Chính sách này quy định về bản quyền video, hình ảnh món ăn và quy trình tiếp nhận khiếu nại bản quyền.',
            lastUpdated: 'Cập nhật lần cuối: Tháng 10, 2026',
            sections: [
              PolicySection(
                title: '1. Quyền Tác giả đối với Tác phẩm Ẩm thực',
                body:
                    'Các đầu bếp và nhà sáng tạo giữ toàn bộ quyền tác giả đối với video, hình ảnh món ăn, lời bình âm thanh và phần hướng dẫn viết tay do chính mình thực hiện trên ứng dụng CookConnect.',
              ),
              PolicySection(
                title: '2. Tái tạo công thức & Giới hạn Bản quyền',
                body:
                    'Danh sách nguyên liệu định lượng thuần túy có thể được học hỏi và biến tấu, nhưng cách dàn dựng video, góc quay nghệ thuật, lời thuyết minh và bài viết chi tiết được bảo hộ bản quyền. Không được tải lại video của người khác để mạo danh tác giả.',
              ),
              PolicySection(
                title: '3. Quy trình Khiếu nại Vi phạm Bản quyền',
                body:
                    'Nếu bạn phát hiện tác phẩm của mình bị sao chép trái phép trên CookConnect, vui lòng gửi thông báo vi phạm đến email legal@cookconnect.app gồm các nội dung sau:',
                bulletPoints: [
                  'Họ tên, thông tin liên hệ và chữ ký điện tử của chủ sở hữu bản quyền hoặc người đại diện hợp pháp.',
                  'Mô tả chi tiết tác phẩm gốc bị vi phạm.',
                  'Đường dẫn URL hoặc ID video/bài viết vi phạm trên CookConnect.',
                  'Cam kết nội dung khiếu nại là hoàn toàn trung thực và chịu trách nhiệm trước pháp luật.',
                ],
              ),
              PolicySection(
                title: '4. Xử lý Vi phạm Nhiều lần',
                body:
                    'CookConnect áp dụng chính sách xử lý nghiêm khắc đối với các tài khoản cố tình tái phạm bản quyền, bao gồm gỡ bỏ nội dung, tước quyền đăng tải hoặc khóa tài khoản vĩnh viễn.',
              ),
            ],
          ),
  );

  // 5. Health & Culinary Disclaimer
  static final PolicyItem healthDisclaimer = PolicyItem(
    id: 'health_disclaimer',
    icon: Iconsax.heart,
    titleKey: UiI18nKeys.termsHealthDisclaimer,
    subtitleKey: UiI18nKeys.termsHealthDisclaimerSubtitle,
    contentBuilder: (lang) => lang == 'en'
        ? const PolicyContent(
            summary:
                'Cooking involves heat, sharp utensils, and raw ingredients. This disclaimer reminds users of essential kitchen safety, allergy awareness, and the advisory nature of user-submitted recipes.',
            lastUpdated: 'Last updated: October 2026',
            sections: [
              PolicySection(
                title: '1. Food Allergy Warning',
                body:
                    'Recipes shared on CookConnect may contain common allergens such as peanuts, tree nuts, dairy, eggs, shellfish, soy, or gluten.',
                bulletPoints: [
                  'Always inspect ingredients carefully if you or your guests have known food sensitivities.',
                  'CookConnect cannot guarantee that any community-submitted recipe is allergen-free.',
                  'Substitutions may alter taste, texture, and nutritional value.',
                ],
              ),
              PolicySection(
                title: '2. Safe Cooking Temperatures',
                body:
                    'Cooking times and temperatures provided in videos are estimates based on the creator\'s personal kitchen appliances. Always verify that meats and poultry are cooked to safe internal temperatures using a reliable food thermometer to prevent foodborne illness.',
              ),
              PolicySection(
                title: '3. Nutritional and Health Claims',
                body:
                    'Nutritional statistics, dietary claims (e.g., "keto", "low-calorie", "diabetic-friendly"), and healthy eating tips published by creators are for general culinary interest only and do not constitute certified medical, nutritional, or healthcare advice.',
              ),
            ],
          )
        : const PolicyContent(
            summary:
                'Nấu nướng liên quan đến nhiệt độ, dao kéo và nguyên liệu tươi sống. Bản miễn trừ này nhắc nhở bạn về các lưu ý an toàn thực phẩm, dị ứng thành phần và tính chất tham khảo của các công thức trên ứng dụng.',
            lastUpdated: 'Cập nhật lần cuối: Tháng 10, 2026',
            sections: [
              PolicySection(
                title: '1. Cảnh báo Dị ứng Thực phẩm',
                body:
                    'Các công thức trên CookConnect do nhiều đầu bếp tự do đăng tải và có thể chứa các chất gây dị ứng phổ biến như hải sản, đậu phộng, hạt dẻ, sữa, trứng, đậu nành hoặc lúa mì.',
                bulletPoints: [
                  'Người dùng cần chủ động kiểm tra kỹ thành phần nếu bản thân hoặc người thân có tiền sử dị ứng thực phẩm.',
                  'CookConnect không chịu trách nhiệm đối với các phản ứng dị ứng do người dùng tự chế biến theo công thức.',
                  'Hãy luôn thận trọng khi thay thế các nguyên liệu lạ.',
                ],
              ),
              PolicySection(
                title: '2. Nhiệt độ Chế biến & An toàn Thực phẩm',
                body:
                    'Thời gian và nhiệt độ nấu nướng trong video chỉ mang tính chất tham khảo do công suất mỗi thiết bị bếp (bếp từ, lò nướng, nồi chiên không dầu) là khác nhau. Hãy đảm bảo các loại thịt gia cầm, thịt heo và hải sản được nấu chín kỹ trước khi thưởng thức để tránh ngộ độc thực phẩm.',
              ),
              PolicySection(
                title: '3. Tính chất Tham khảo của Mẹo Dinh dưỡng',
                body:
                    'Các thông tin dinh dưỡng, chế độ ăn (như Eat Clean, Keto, ăn kiêng) do người dùng chia sẻ chỉ nhằm mục đích tham khảo kiến thức ẩm thực và không thay thế cho phác đồ điều trị hay lời khuyên từ bác sĩ dinh dưỡng chuyên nghiệp.',
              ),
            ],
          ),
  );

  // 6. Cookie Policy
  static final PolicyItem cookiePolicy = PolicyItem(
    id: 'cookie_policy',
    icon: Iconsax.security_user,
    titleKey: UiI18nKeys.termsCookiePolicy,
    subtitleKey: UiI18nKeys.termsCookiePolicySubtitle,
    contentBuilder: (lang) => lang == 'en'
        ? const PolicyContent(
            summary:
                'We use cookies, cache tokens, and secure local device storage to remember your preferences, keep your session active, and enhance cooking video streaming efficiency.',
            lastUpdated: 'Last updated: October 2026',
            sections: [
              PolicySection(
                title: '1. What Are Cookies and Local Storage?',
                body:
                    'Cookies and local storage are small text tokens stored on your device that allow mobile applications to recognize your session, remember your language choices, and preserve video playback position.',
              ),
              PolicySection(
                title: '2. How CookConnect Uses Local Tokens',
                body:
                    'We utilize storage technologies strictly for functional and optimization purposes:',
                bulletPoints: [
                  'Session & Authentication: Storing encrypted auth tokens so you don\'t have to log in on every app launch.',
                  'Preferences: Remembering your selected language (Vietnamese, English) and video autoplay settings.',
                  'Video Caching: Caching short culinary clips locally to minimize mobile cellular data consumption.',
                ],
              ),
              PolicySection(
                title: '3. Managing Your Storage Preferences',
                body:
                    'You can clear cached videos and temporary files at any time via Settings & Privacy > Cache & Cellular > Free Up Space. Doing so will not affect your saved recipes or bookmarked dishes.',
              ),
            ],
          )
        : const PolicyContent(
            summary:
                'CookConnect sử dụng cookie, mã định danh phiên và bộ nhớ đệm cục bộ nhằm ghi nhớ đăng nhập, tối ưu hóa tốc độ tải video món ăn và tiết kiệm dữ liệu di động cho bạn.',
            lastUpdated: 'Cập nhật lần cuối: Tháng 10, 2026',
            sections: [
              PolicySection(
                title: '1. Cookie và Lưu trữ Cục bộ là gì?',
                body:
                    'Cookie và bộ lưu trữ cục bộ (Local Storage/Cache) là các tệp dữ liệu nhỏ được lưu trữ an toàn trên thiết bị di động của bạn, giúp ứng dụng nhận diện tài khoản, ghi nhớ ngôn ngữ và giữ vị trí phát video.',
              ),
              PolicySection(
                title: '2. CookConnect Sử dụng Bộ nhớ như thế nào?',
                body:
                    'Chúng tôi áp dụng các công nghệ lưu trữ cho các mục đích thiết thực:',
                bulletPoints: [
                  'Xác thực đăng nhập: Lưu trữ mã token bảo mật để bạn không cần đăng nhập lại mỗi khi mở app.',
                  'Tùy chỉnh cá nhân: Ghi nhớ ngôn ngữ đã chọn (Tiếng Việt / English) và các tùy chọn phát video.',
                  'Bộ nhớ đệm video (Cache): Tạm lưu các đoạn video ngắn để tải mượt mà hơn và tiết kiệm dung lượng 4G/5G.',
                ],
              ),
              PolicySection(
                title: '3. Quản lý Bộ nhớ Cục bộ của bạn',
                body:
                    'Bạn có thể xóa sạch bộ nhớ đệm video bất kỳ lúc nào tại mục Cài đặt & Quyền riêng tư > Bộ nhớ đệm & Dữ liệu di động > Giải phóng dung lượng mà không làm ảnh hưởng đến các công thức và món ăn đã lưu trong hồ sơ cá nhân.',
              ),
            ],
          ),
  );

  // Grouped items
  static final List<PolicyItem> legalGroup = [
    termsOfService,
    privacyPolicy,
    copyrightPolicy,
  ];

  static final List<PolicyItem> communityGroup = [
    communityGuidelines,
    healthDisclaimer,
    cookiePolicy,
  ];
}
