import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I monitor my solar system?',
      'answer':
          'The Overview screen displays real-time data from your solar system including generation, consumption, battery status, and grid interaction. Data updates every 5 seconds for accurate monitoring.',
    },
    {
      'question': 'What does the energy flow diagram show?',
      'answer':
          'The flow diagram shows how energy moves through your system: solar panels → inverter → home/battery/grid. Color-coded lines indicate different energy paths (green for solar, blue for grid, amber for battery).',
    },
    {
      'question': 'How can I reduce my electricity costs?',
      'answer':
          'Check the Explore section for articles on energy optimization. Key strategies include: maximize solar generation, reduce consumption during peak hours, use battery wisely, and export excess energy to the grid.',
    },
    {
      'question': 'What should I do if my system is not generating power?',
      'answer':
          'First check: panels are clean and unshaded, inverter is on, weather is favorable. If issues persist, contact support through the Help & Support menu.',
    },
    {
      'question': 'How often should I service my system?',
      'answer':
          'Professional inspections are recommended annually. Regular maintenance includes cleaning panels every 3-6 months and checking battery health quarterly.',
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'Yes! All energy data is encrypted and stored securely. We never share your information with third parties without explicit consent. See Privacy Policy for details.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text('Help & Support', style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        children: [
          // Contact Section
          _ContactCard(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@solarconnect.app',
            onTap: () =>
                _showContactDialog('Email', 'support@solarconnect.app'),
          ),
          const SizedBox(height: AppConstants.paddingMD),
          _ContactCard(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+1 (555) 123-4567',
            onTap: () => _showContactDialog('Call', '+1 (555) 123-4567'),
          ),
          const SizedBox(height: AppConstants.paddingMD),
          _ContactCard(
            icon: Icons.chat,
            title: 'Live Chat',
            subtitle: 'Available 9 AM - 6 PM EST',
            onTap: () => _showChatDialog(),
          ),
          const SizedBox(height: AppConstants.paddingXL),

          // FAQ Section
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: AppConstants.paddingMD),
          ..._faqItems.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> item = entry.value;
            return _FAQItem(
              question: item['question']!,
              answer: item['answer']!,
              isExpanded: _expandedIndex == index,
              onTap: () {
                setState(() {
                  _expandedIndex = _expandedIndex == index ? null : index;
                });
              },
            );
          }).toList(),

          const SizedBox(height: AppConstants.paddingXL),

          // Quick Links
          Text('Quick Links', style: AppTextStyles.headingMedium),
          const SizedBox(height: AppConstants.paddingMD),
          _QuickLinkTile(
            icon: Icons.description,
            title: 'User Guide',
            onTap: () => _showDocumentDialog('User Guide'),
          ),
          const SizedBox(height: 8),
          _QuickLinkTile(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            onTap: () => _showBugReportDialog(),
          ),
          const SizedBox(height: 8),
          _QuickLinkTile(
            icon: Icons.lightbulb,
            title: 'Feature Request',
            onTap: () => _showFeatureRequestDialog(),
          ),
          const SizedBox(height: 8),
          _QuickLinkTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: () => _showFeedbackDialog(),
          ),

          const SizedBox(height: AppConstants.paddingXL),

          // Version Info
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Column(
              children: [
                Text('SolarConnect', style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0 (Build 2026.06.10)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  void _showContactDialog(String type, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(type, style: AppTextStyles.headingMedium),
        content: Text(value, style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Use'),
          ),
        ],
      ),
    );
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Live Chat', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Text(
                'Support Agent: Hi! How can I help you today?',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMD),
            TextField(
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.dividerColor),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDocumentDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(title, style: AppTextStyles.headingMedium),
        content: SingleChildScrollView(
          child: Text(
            'Complete guide to using SolarConnect:\n\n'
            '1. Overview Screen: Monitor real-time system performance\n'
            '2. Explore Screen: Read articles and tips\n'
            '3. Settings: Customize your preferences\n'
            '4. Menu: Access help and profile\n\n'
            'For detailed steps, visit our website.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Report a Bug', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Describe the issue',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug report submitted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFeatureRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Feature Request', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Describe the feature',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature request submitted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Send Feedback', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you rate SolarConnect?',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppConstants.paddingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.star,
                    color: index < 4
                        ? AppColors.primaryOrange
                        : AppColors.secondaryText,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Icon(icon, color: AppColors.primaryOrange, size: 24),
            ),
            const SizedBox(width: AppConstants.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.secondaryText),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMD),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMD),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(question, style: AppTextStyles.bodyLarge),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.dividerColor),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppConstants.paddingMD),
                  child: Text(
                    answer,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
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

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMD,
          vertical: AppConstants.paddingSM,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryOrange),
            const SizedBox(width: AppConstants.paddingMD),
            Text(title, style: AppTextStyles.bodyLarge),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppColors.secondaryText),
          ],
        ),
      ),
    );
  }
}
