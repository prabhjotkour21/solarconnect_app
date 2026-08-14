import 'package:flutter/material.dart';
import '../../models/explore_article.dart';
import '../../routes/app_routes.dart';
import '../../screens/explore/article_detail_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../widgets/explore/article_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedCategory = 0;
  final _categories = ['All', 'Tips & Tricks', 'Finance', 'Maintenance', 'Education'];

  List<ExploreArticle> get _filtered {
    if (_selectedCategory == 0) return ExploreArticle.demoArticles;
    final cat = _categories[_selectedCategory];
    return ExploreArticle.demoArticles.where((a) => a.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        top: true,
        bottom: true,
        child: CustomScrollView(
          slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.backgroundDark,
            title: Text('Explore', style: AppTextStyles.headingMedium),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _CategoryChips(
                categories: _categories,
                selected: _selectedCategory,
                onSelected: (i) => setState(() => _selectedCategory = i),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMD,
              AppConstants.paddingMD,
              AppConstants.paddingMD,
              AppConstants.paddingXL,
            ),
            sliver: SliverList.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(
                        article: _filtered[i],
                      ),
                    ),
                  );
                },
                child: ArticleCard(article: _filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selected;
  final ValueChanged<int> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.divider,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: AppTextStyles.labelLarge.copyWith(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
