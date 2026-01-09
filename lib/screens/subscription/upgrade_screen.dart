import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  bool _isYearlySelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textMuted,
                ),
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Headline
                      Text(
                        'Ghi âm & Tóm tắt không giới hạn với Pro',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        'Nâng cao hiệu suất cuộc họp của bạn, không bỏ lỡ bất kỳ chi tiết quan trọng nào.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Benefits list
                      _buildBenefit(
                        icon: Icons.timer,
                        text: 'Ghi âm không giới hạn thời gian',
                      ),
                      _buildBenefit(
                        icon: Icons.auto_awesome,
                        text: 'Tóm tắt AI nâng cao & chính xác hơn',
                      ),
                      _buildBenefit(
                        icon: Icons.cloud_upload,
                        text: 'Lưu trữ trên cloud không giới hạn',
                      ),
                      _buildBenefit(
                        icon: Icons.description,
                        text: 'Xuất file với nhiều định dạng',
                      ),
                      _buildBenefit(
                        icon: Icons.support_agent,
                        text: 'Hỗ trợ ưu tiên',
                      ),
                      const SizedBox(height: 32),
                      // Pricing cards
                      _buildPricingCard(
                        title: 'Gói Tháng',
                        price: '129.000đ/tháng',
                        isSelected: !_isYearlySelected,
                        onTap: () => setState(() => _isYearlySelected = false),
                      ),
                      const SizedBox(height: 12),
                      _buildPricingCard(
                        title: 'Gói Năm',
                        price: '1.099.000đ/năm',
                        subtitle: 'Chỉ 91.500đ/tháng',
                        badge: 'TIẾT KIỆM 30%',
                        isSelected: _isYearlySelected,
                        onTap: () => setState(() => _isYearlySelected = true),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Sticky footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border(
                  top: BorderSide(
                    color: AppColors.dividerDark,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement purchase
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      child: const Text(
                        'Nâng cấp ngay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment info text
                  Text(
                    'Giao dịch sẽ tự động gia hạn. Hủy bất cứ lúc nào.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Restore transaction link
                  TextButton(
                    onPressed: () {
                      // TODO: Implement restore
                    },
                    child: Text(
                      'Khôi phục giao dịch',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
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

  Widget _buildBenefit({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    String? subtitle,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.dividerDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // Radio indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                  ],
                ),
              ],
            ),
            // Badge
            if (badge != null)
              Positioned(
                top: -16,
                right: -16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
