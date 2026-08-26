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
    ExploreArticle(
      id: '9',
      title: 'Understanding Your Solar Energy Flow',
      subtitle: 'See how solar energy moves between your panels, home, battery, and the grid.',
      category: 'Energy Insights',
      readTime: '5 min read',
      imageEmoji: '🔄',
      author: 'Solar Education Team',
      publishDate: 'August 26, 2026',
      content: 'Solar energy can be used in several ways depending on your system and current energy demand. During the day, solar production can power your home directly. When production is higher than your home\'s demand, the excess energy may be stored in a battery or exported to the grid. When solar production is not enough, your home can use stored battery energy or draw electricity from the grid. Monitoring these energy flows helps you understand how your solar system is performing and how your energy is being used.',
    ),
    ExploreArticle(
      id: '10',
      title: 'How to Read Your Solar Production Data',
      subtitle: 'Learn how to use daily, monthly, yearly, and lifetime energy data to understand your system performance.',
      category: 'Energy Insights',
      readTime: '4 min read',
      imageEmoji: '📊',
      author: 'Solar Education Team',
      publishDate: 'August 24, 2026',
      content: 'Solar production changes throughout the day based on sunlight, weather, and household energy demand. Reviewing your energy history can help you understand normal production patterns and identify unexpected changes. Daily views can show short-term production, while monthly and yearly views help you identify longer-term trends. Comparing solar production with home consumption can also help you understand how much of your energy demand is being covered by solar.',
    ),
    ExploreArticle(
      id: '11',
      title: 'Solar, Battery and Grid: How They Work Together',
      subtitle: 'Understand how your solar panels, battery storage, home, and utility grid work together.',
      category: 'Education',
      readTime: '5 min read',
      imageEmoji: '⚡',
      author: 'Solar Education Team',
      publishDate: 'August 22, 2026',
      content: 'A solar energy system can combine multiple sources of electricity to meet your home\'s energy needs. Solar production can power your home first, while excess energy may be stored in a battery or exported to the grid. When solar production decreases, stored battery energy can help supply your home. If additional electricity is required, your home can draw energy from the grid. Understanding these energy flows makes it easier to monitor your system and manage your energy usage.',
    ),
    ExploreArticle(
      id: '12',
      title: 'Understanding Battery Charge and Backup Reserve',
      subtitle: 'Learn how battery charge levels and backup reserve help you manage stored solar energy.',
      category: 'Battery',
      readTime: '4 min read',
      imageEmoji: '🔋',
      author: 'Energy Storage Specialist',
      publishDate: 'August 20, 2026',
      content: 'Battery storage allows excess solar energy to be saved and used later. Your battery\'s charge level shows how much stored energy is currently available. A backup reserve allows you to keep a selected amount of battery energy available for a potential power outage. Using more of the battery during normal operation can increase solar self-consumption, while maintaining a higher reserve can provide more stored energy during an outage. The best setting depends on your energy needs and backup priorities.',
    ),
    ExploreArticle(
      id: '13',
      title: 'How to Maximize Your Solar Savings',
      subtitle: 'Use solar production, battery storage, and energy consumption more efficiently to reduce grid dependence.',
      category: 'Savings',
      readTime: '6 min read',
      imageEmoji: '💰',
      author: 'Solar Savings Advisor',
      publishDate: 'August 18, 2026',
      content: 'Maximizing solar savings is not only about producing more electricity. It is also about using that energy efficiently. Using solar energy when production is high can reduce the amount of electricity purchased from the grid. Excess solar can be stored in a compatible battery and used later when solar production is lower. Where supported, energy usage can also be planned around utility rates. Monitoring production, consumption, battery usage, and grid activity helps you make better energy decisions over time.',
    ),
    ExploreArticle(
      id: '14',
      title: 'What Happens During a Power Outage?',
      subtitle: 'Learn how a battery-backed solar system can help keep your home powered during a grid outage.',
      category: 'Backup & Safety',
      readTime: '5 min read',
      imageEmoji: '🛡️',
      author: 'Backup and Safety Team',
      publishDate: 'August 16, 2026',
      content: 'During a power outage, a compatible battery backup system can provide electricity to supported home loads while the system is disconnected from the utility grid. The amount of backup energy available depends on the battery\'s current charge and the configured backup reserve. Monitoring battery levels before and during severe weather can help you understand how much backup energy is available. Energy management features can also help users prepare their system for potential outages.',
    ),
    ExploreArticle(
      id: '15',
      title: 'Charging Your EV With Solar Energy',
      subtitle: 'Learn how excess solar production can be used to charge an electric vehicle.',
      category: 'Electric Vehicles',
      readTime: '5 min read',
      imageEmoji: '🚗',
      author: 'EV Energy Specialist',
      publishDate: 'August 14, 2026',
      content: 'An electric vehicle can use solar energy as part of a home\'s overall energy system. When solar production is higher than the home\'s current demand, available excess energy can be directed toward EV charging when supported by the vehicle and charging system. Smart charging features can help users make better use of available solar production instead of relying entirely on grid electricity. Monitoring solar generation and charging activity can help users understand how much of their vehicle charging is being supported by solar energy.',
    ),
    ExploreArticle(
      id: '16',
      title: 'Understanding Grid Import and Export',
      subtitle: 'Understand when your home uses electricity from the grid and when excess solar energy is sent back.',
      category: 'Energy Insights',
      readTime: '5 min read',
      imageEmoji: '↔️',
      author: 'Solar Education Team',
      publishDate: 'August 12, 2026',
      content: 'Grid import occurs when your home requires more electricity than your solar and battery system can provide. Grid export occurs when your system produces more energy than your home and battery can currently use, where export is supported. Tracking both directions gives you a clearer picture of your energy usage. Utility rules, export limits, and electricity rates can vary by location, so your actual savings and export value depend on your local energy plan.',
    ),
    ExploreArticle(
      id: '17',
      title: 'Using Energy Data to Understand Your Home',
      subtitle: 'Turn your solar and energy data into useful insights about how your home consumes electricity.',
      category: 'Energy Insights',
      readTime: '5 min read',
      imageEmoji: '🏠',
      author: 'Home Energy Analyst',
      publishDate: 'August 10, 2026',
      content: 'Energy monitoring can show how much electricity your home produces, consumes, stores, imports, and exports. Reviewing this information over time can help you identify changes in energy usage and understand when your home relies most on solar, battery, or grid electricity. Historical energy data can also help you compare different periods and make more informed decisions about energy consumption.',
    ),
    ExploreArticle(
      id: '18',
      title: 'Preparing Your Solar System for Severe Weather',
      subtitle: 'Learn how energy monitoring and backup settings can help you prepare for possible power interruptions.',
      category: 'Backup & Safety',
      readTime: '4 min read',
      imageEmoji: '⛈️',
      author: 'Backup and Safety Team',
      publishDate: 'August 8, 2026',
      content: 'Severe weather can increase the risk of grid interruptions. If your solar system includes battery backup, checking the battery charge and backup reserve before a major weather event can help ensure that stored energy is available when needed. Some energy systems also provide weather-related preparation features that can automatically prioritize battery charging when severe weather is expected. Always follow the safety guidance provided for your specific solar and battery system.',
    ),
  ];
}
