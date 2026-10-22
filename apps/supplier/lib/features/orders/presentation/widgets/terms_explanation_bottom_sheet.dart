import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';

class TermsExplanationBottomSheet extends StatelessWidget {
  const TermsExplanationBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const TermsExplanationBottomSheet(),
    );
  }

  final List<Map<String, String>> _terms = const [
    {
      'title': 'Cần vận chuyển trong vòng 24h',
      'desc':
          'Các đơn hàng cần được người bán chuẩn bị, đóng gói và bàn giao cho đơn vị vận chuyển hoặc tài xế trong vòng 24 giờ kể từ thời điểm xác nhận để đảm bảo thời gian giao hàng đúng cam kết.',
    },
    {
      'title': 'Tự động hủy trong 24h trở xuống',
      'desc':
          'Thời gian đếm ngược còn dưới 24 giờ trước khi hệ thống tự động hủy đơn do cửa hàng chưa xác nhận đơn hoặc chưa bàn giao cho đơn vị vận chuyển đúng hạn quy định.',
    },
    {
      'title': 'Quá hạn vận chuyển',
      'desc':
          'Đơn hàng đã vượt quá hạn chót gửi hàng theo quy định của hệ thống. Những đơn này có nguy cơ bị hủy bởi khách hàng hoặc bị trừ điểm hiệu suất vận hành của cửa hàng.',
    },
    {
      'title': 'Đã hủy yêu cầu',
      'desc':
          'Người mua đã từng gửi yêu cầu hủy đơn nhưng sau đó đã rút lại, hoặc yêu cầu hủy đã được người bán phản hồi từ chối.',
    },
    {
      'title': 'Vấn đề gửi hàng',
      'desc':
          'Đơn hàng gặp trở ngại trong quá trình giao nhận hàng ban đầu: ví dụ như đơn vị vận chuyển chưa đến lấy, kiện hàng có sai sót thông tin, hoặc cửa hàng báo hết món.',
    },
    {
      'title': 'Vấn đề vận chuyển hoặc giao không thành công',
      'desc':
          'Tài xế/đơn vị vận chuyển không liên lạc được với người nhận, địa chỉ không chính xác, người mua đổi lịch hẹn nhận hàng hoặc từ chối nhận hàng khi shipper đến.',
    },
    {
      'title': 'Đã yêu cầu trả hàng - Hoàn tiền',
      'desc':
          'Khách hàng gửi yêu cầu trả hàng hoặc khiếu nại hoàn tiền do món ăn/sản phẩm không đúng mô tả, thiếu món, bị hỏng hoặc giao sai. Người bán cần phản hồi xử lý trong vòng 48 giờ.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Giải thích thuật ngữ cần xử lý',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, size: 22, color: AppColors.textHint),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _terms.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final term = _terms[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                term['title']!,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            term['desc']!,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
