class ExploreArticle {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final String imageEmoji;
  final String content;
  final String author;
  final String publishDate;

  const ExploreArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.imageEmoji,
    required this.content,
    required this.author,
    required this.publishDate,
  });

  static const List<ExploreArticle> demoArticles = [
    ExploreArticle(
      id: '1',
      title: 'Maximizing Solar Output in Winter Months',
      subtitle: 'Learn how to optimize panel angles and keep your system running efficiently when sunlight is scarce.',
      category: 'Tips & Tricks',
      readTime: '4 min read',
      imageEmoji: '☀️',
      author: 'Solar Expert Team',
      publishDate: 'June 5, 2026',
      content: 'Winter months present unique challenges for solar panel efficiency. With reduced daylight hours and lower sun angles, it is crucial to understand how to maximize your system performance.\n\n'
          'Key strategies include:\n'
          '• Adjusting panel angles seasonally (typically steeper in winter)\n'
          '• Ensuring panels are clear of snow and debris\n'
          '• Monitoring system performance regularly\n'
          '• Considering micro-inverters for shaded areas\n\n'
          'By implementing these techniques, many users report maintaining 70-80% of their summer output even in winter conditions.',
    ),
    ExploreArticle(
      id: '2',
      title: 'Understanding Your Battery Storage',
      subtitle: 'A deep dive into how lithium batteries store energy and how to extend their lifespan.',
      category: 'Education',
      readTime: '6 min read',
      imageEmoji: '🔋',
      author: 'Energy Storage Specialist',
      publishDate: 'June 3, 2026',
      content: 'Battery storage is the cornerstone of energy independence. Understanding how your battery system works helps you optimize its lifespan and performance.\n\n'
          'Battery Basics:\n'
          '• Lithium batteries offer superior performance and longevity\n'
          '• Typical lifespan: 10-15 years\n'
          '• Depth of discharge affects battery health\n'
          '• Temperature management is critical\n\n'
          'Maintenance Tips:\n'
          '• Keep batteries between 20-80% charge for daily use\n'
          '• Maintain proper ventilation around the system\n'
          '• Monitor battery health metrics regularly\n\n'
          'With proper care, your battery investment will provide reliable power for over a decade.',
    ),
    ExploreArticle(
      id: '3',
      title: 'Grid Export: Are You Getting Paid Fairly?',
      subtitle: 'How feed-in tariffs work and tips to negotiate better rates with your energy provider.',
      category: 'Finance',
      readTime: '5 min read',
      imageEmoji: '⚡',
      author: 'Financial Advisor',
      publishDate: 'June 1, 2026',
      content: 'When your solar system generates more energy than you use, you can export the excess to the grid and earn money. But are you getting the best rate?\n\n'
          'Understanding Feed-in Tariffs:\n'
          '• Rates typically range from \$0.05 to \$0.15 per kWh\n'
          '• Some regions offer time-of-use rates (higher during peak hours)\n'
          '• Contracts usually last 10-20 years\n\n'
          'Maximizing Your Export Income:\n'
          '• Compare offers from multiple providers\n'
          '• Consider time-of-use optimization\n'
          '• Track export data to verify payments\n'
          '• Negotiate better rates as contracts renew\n\n'
          'Smart monitoring can increase your income by 20-30%.',
    ),
    ExploreArticle(
      id: '4',
      title: 'Solar Panel Cleaning Guide',
      subtitle: 'Dirty panels can reduce output by up to 30%. Here is how to safely clean them.',
      category: 'Maintenance',
      readTime: '3 min read',
      imageEmoji: '🧹',
      author: 'Maintenance Expert',
      publishDate: 'May 28, 2026',
      content: 'Panel cleanliness directly impacts energy production. A layer of dust, bird droppings, or leaves can significantly reduce efficiency.\n\n'
          'Cleaning Schedule:\n'
          '• Clean every 3-6 months in normal conditions\n'
          '• More frequently in dusty or coastal areas\n'
          '• After storms or heavy wind events\n\n'
          'Safe Cleaning Process:\n'
          '1. Turn off your system at the inverter\n'
          '2. Wait for panels to cool (early morning or evening)\n'
          '3. Use soft-bristled brush and distilled water\n'
          '4. Avoid pressure washers (can damage seals)\n'
          '5. Check for damage while cleaning\n\n'
          'Regular cleaning can boost output by 15-30%, paying for itself quickly.',
    ),
    ExploreArticle(
      id: '5',
      title: 'Net Zero Homes: The Future of Energy',
      subtitle: 'How homeowners around the world are achieving energy independence with solar + storage.',
      category: 'Trends',
      readTime: '7 min read',
      imageEmoji: '🏡',
      author: 'Sustainability Correspondent',
      publishDate: 'May 25, 2026',
      content: 'Net zero homes produce as much energy as they consume annually, achieving true energy independence. This trend is accelerating globally.\n\n'
          'What Makes a Home Net Zero:\n'
          '• Solar panels sized to meet annual consumption\n'
          '• Battery storage for daily and seasonal needs\n'
          '• Energy-efficient appliances and insulation\n'
          '• Smart energy management systems\n\n'
          'Global Trends:\n'
          '• 50+ million homes already net zero\n'
          '• Technology costs dropping 50% every 10 years\n'
          '• Government incentives increasing\n'
          '• Community net zero grids emerging\n\n'
          'Your home could be next. With current technology, net zero is achievable for most households within 5-10 years.',
    ),
    ExploreArticle(
      id: '6',
      title: 'EV Charging with Solar: A Complete Guide',
      subtitle: 'Charge your electric vehicle directly from your panels and never pay for fuel again.',
      category: 'Electric Vehicles',
      readTime: '8 min read',
      imageEmoji: '🚗',
      author: 'EV Specialist',
      publishDate: 'May 22, 2026',
      content: 'Solar charging your EV represents the ultimate in energy efficiency and cost savings. Here is everything you need to know.\n\n'
          'System Requirements:\n'
          '• 8-10 kW solar array (typical EV usage)\n'
          '• 10 kWh+ battery storage\n'
          '• Smart charging controller\n'
          '• Level 2 charger recommended\n\n'
          'Cost Savings:\n'
          '• Eliminate fuel costs (\$0.03/mile vs \$0.15/mile)\n'
          '• Payback period: 5-7 years\n'
          '• 25+ year system lifespan\n\n'
          'Optimization Tips:\n'
          '• Charge during peak solar hours\n'
          '• Use smart scheduling features\n'
          '• Monitor efficiency metrics\n\n'
          'Combined solar + EV can reduce transportation costs by 80%.',
    ),
    ExploreArticle(
      id: '7',
      title: 'When to Replace Your Inverter',
      subtitle: 'Signs your inverter is underperforming and what to look for when buying a replacement.',
      category: 'Maintenance',
      readTime: '4 min read',
      imageEmoji: '🔧',
      author: 'Technical Support',
      publishDate: 'May 20, 2026',
      content: 'Your inverter is the heart of your solar system. Knowing when to replace it ensures continuous performance.\n\n'
          'Typical Inverter Lifespan:\n'
          '• String inverters: 10-15 years\n'
          '• Micro-inverters: 15-20 years\n'
          '• Hybrid inverters: 12-18 years\n\n'
          'Warning Signs:\n'
          '• Error codes on display\n'
          '• Sudden output drop (>20%)\n'
          '• Frequent shut-downs\n'
          '• Loud humming or cooling noise\n'
          '• No output despite sunny weather\n\n'
          'What to Look For:\n'
          '• Higher efficiency ratings (95%+)\n'
          '• Extended warranty (10+ years)\n'
          '• Smart monitoring features\n'
          '• Better thermal management\n\n'
          'Prompt replacement prevents extended downtime and ensures optimal system performance.',
    ),
    ExploreArticle(
      id: '8',
      title: 'Government Solar Rebates 2025',
      subtitle: 'Updated guide to all available rebates, incentives, and tax credits for solar installations.',
      category: 'Finance',
      readTime: '5 min read',
      imageEmoji: '💰',
      author: 'Government Programs Guide',
      publishDate: 'May 18, 2026',
      content: 'Government incentives make solar more affordable than ever. Learn what rebates and credits you may qualify for.\n\n'
          'Federal Tax Credit:\n'
          '• 30% of installation costs\n'
          '• No upper limit\n'
          '• Available through 2033\n'
          '• Can be carried forward if unused\n\n'
          'State & Local Rebates:\n'
          '• Vary by location (check your local utility)\n'
          '• Some states offer additional tax credits\n'
          '• Performance-based incentives available\n'
          '• Rebates can cover 20-50% of costs\n\n'
          'Available Programs:\n'
          '• Solar Energy Equipment Sales Tax Exemption\n'
          '• Property Tax Exemptions\n'
          '• Utility Rebates\n'
          '• SRECs (Solar Renewable Energy Credits)\n\n'
          'Combined incentives can reduce your effective cost by 50-70%, making solar the best investment available.',
    ),
  ];
}
