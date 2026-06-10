import 'package:flutter/material.dart';
import '../../models/explore_article.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ExploreArticle article;

  const ArticleDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primaryText),
            onPressed: () => _showShareDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero emoji section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              color: AppColors.surfaceDark,
              child: Column(
                children: [
                  Text(
                    article.imageEmoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: AppConstants.paddingSM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSM,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMD),
                    ),
                    child: Text(
                      article.category,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title and metadata
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: AppTextStyles.headingLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMD),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.readTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.author,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.publishDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.dividerColor, height: 1),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              child: Text(
                article.content,
                style: AppTextStyles.bodyLarge.copyWith(
                  height: 1.6,
                ),
              ),
            ),

            // Share button
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showShareDialog(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share This Article'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.paddingMD,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingLG),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (article.category) {
      case 'Tips & Tricks':
        return AppColors.primaryOrange;
      case 'Finance':
        return const Color(0xFF8BC34A);
      case 'Maintenance':
        return const Color(0xFF2196F3);
      case 'Education':
        return const Color(0xFF9C27B0);
      case 'Trends':
        return const Color(0xFF00BCD4);
      case 'Electric Vehicles':
        return const Color(0xFFFF5722);
      default:
        return AppColors.primaryOrange;
    }
  }

  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Article',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: AppConstants.paddingLG),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.mail,
                  label: 'Email',
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.sms,
                  label: 'Message',
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryOrange,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
