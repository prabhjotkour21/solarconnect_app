class ExploreArticle {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final String imageEmoji;

  const ExploreArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.imageEmoji,
  });

  static const List<ExploreArticle> demoArticles = [
    ExploreArticle(
      id: '1',
      title: 'Maximizing Solar Output in Winter Months',
      subtitle: 'Learn how to optimize panel angles and keep your system running efficiently when sunlight is scarce.',
      category: 'Tips & Tricks',
      readTime: '4 min read',
      imageEmoji: '☀️',
    ),
    ExploreArticle(
      id: '2',
      title: 'Understanding Your Battery Storage',
      subtitle: 'A deep dive into how lithium batteries store energy and how to extend their lifespan.',
      category: 'Education',
      readTime: '6 min read',
      imageEmoji: '🔋',
    ),
    ExploreArticle(
      id: '3',
      title: 'Grid Export: Are You Getting Paid Fairly?',
      subtitle: 'How feed-in tariffs work and tips to negotiate better rates with your energy provider.',
      category: 'Finance',
      readTime: '5 min read',
      imageEmoji: '⚡',
    ),
    ExploreArticle(
      id: '4',
      title: 'Solar Panel Cleaning Guide',
      subtitle: 'Dirty panels can reduce output by up to 30%. Here is how to safely clean them.',
      category: 'Maintenance',
      readTime: '3 min read',
      imageEmoji: '🧹',
    ),
    ExploreArticle(
      id: '5',
      title: 'Net Zero Homes: The Future of Energy',
      subtitle: 'How homeowners around the world are achieving energy independence with solar + storage.',
      category: 'Trends',
      readTime: '7 min read',
      imageEmoji: '🏡',
    ),
    ExploreArticle(
      id: '6',
      title: 'EV Charging with Solar: A Complete Guide',
      subtitle: 'Charge your electric vehicle directly from your panels and never pay for fuel again.',
      category: 'Electric Vehicles',
      readTime: '8 min read',
      imageEmoji: '🚗',
    ),
    ExploreArticle(
      id: '7',
      title: 'When to Replace Your Inverter',
      subtitle: 'Signs your inverter is underperforming and what to look for when buying a replacement.',
      category: 'Maintenance',
      readTime: '4 min read',
      imageEmoji: '🔧',
    ),
    ExploreArticle(
      id: '8',
      title: 'Government Solar Rebates 2025',
      subtitle: 'Updated guide to all available rebates, incentives, and tax credits for solar installations.',
      category: 'Finance',
      readTime: '5 min read',
      imageEmoji: '💰',
    ),
  ];
}
