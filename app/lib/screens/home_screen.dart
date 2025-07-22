import 'package:app/models/travel_model.dart';
import 'package:app/screens/travel_plan_screen.dart';
import 'package:app/screens/prompt_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _backgroundAnimation;

  // Sample travel plan with proper JSON structure
  List<TravelPlan> travelPlans = [
    TravelPlan(
      id: '1',
      title: 'Chennai Pop Culture & Street Style',
      destination: 'Chennai, India',
      duration: '2 days',
      summary: '2-day cultural itinerary for Chennai',
      travel_image: 'https://picsum.photos/1200/800?random=768',
      itinerary: TravelItinerary(
        destination: "Chennai",
        duration_days: 2,
        days: [
          TravelDay(
            day_number: 1,
            theme: "Modern Chennai & Pop Culture Buzz",
            activities: [
              Activity(
                time: "09:30",
                location: Location(
                  name: "Namma Veedu Vasanta Bhavan",
                  address:
                      "2nd Floor, Phoenix Market City, S36, Velachery Rd, Indira Gandhi Nagar, Velachery, Chennai, Tamil Nadu 600042, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJN8C5NmJnUjoRYnX2KEB0Tjg",
                ),
                category: "dining",
                description:
                    "Start your day with an authentic yet accessible South Indian breakfast experience. Saravana Bhavan is a globally recognized chain, popular for its consistent quality and a great way to dive into local flavors in a comfortable, modern mall setting.",
                culturalConnection:
                    "A staple of South Indian cuisine, offering a taste of local food loved by all generations, including the youth, in a familiar and convenient environment.",
                category_icon: "🍽️",
              ),
              Activity(
                time: "10:30",
                location: Location(
                  name: "Phoenix Marketcity",
                  address:
                      "Velachery Rd, Indira Gandhi Nagar, Velachery, Chennai, Tamil Nadu 600042, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJ62COtGNnUjoRUcI2kAApOts",
                ),
                category: "fashion",
                description:
                    "Explore Chennai's premier shopping destination. Phoenix Marketcity hosts a wide array of international and Indian brands, perfect for finding casual streetwear and trendy pieces. Look for stores like H&M, Zara, Lifestyle, and Westside for the latest styles.",
                culturalConnection:
                    "A hub for contemporary fashion trends, reflecting global and local youth styles. Ideal for 'casual streetwear' preferences due to its diverse range of modern brands.",
                category_icon: "👗",
              ),
              Activity(
                time: "13:00",
                location: Location(
                  name: "Inox LUXE Phoenix Market City",
                  address:
                      "2nd Floor, Phoenix Market City, No. 142, Velachery Rd, Indira Gandhi Nagar, Velachery, Chennai, Tamil Nadu 600042, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJfZlKS6dnUjoRPpu9BJGcfaI",
                ),
                category: "film",
                description:
                    "Catch a matinee show at one of Chennai's most luxurious multiplexes. PVR Luxe offers a premium cinema experience, perfect for enjoying the latest popular movies, be it Kollywood, Bollywood, or Hollywood blockbusters, in ultimate comfort.",
                culturalConnection:
                    "Chennai has a vibrant film culture deeply ingrained in its identity. This modern cinema experience aligns perfectly with a 'popular movies' preference, offering a comfortable and immersive viewing.",
                category_icon: "🎬",
              ),
              Activity(
                time: "16:00",
                location: Location(
                  name: "Wild Gardencafe",
                  address:
                      "Amethyst, near, Whites Rd, next to Union Bank, Express Estate, Royapettah, Chennai, Tamil Nadu 600014, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJc2w3PbxlBRERbGTUaw6mtXU",
                ),
                category: "music",
                description:
                    "Relax at this beautiful, trendy cafe nestled in a lush garden. Amethyst is known for its serene ambiance, curated boutique, and often plays contemporary, chill-pop music, making it a perfect spot to unwind and soak in a sophisticated, youthful vibe.",
                culturalConnection:
                    "While not a dedicated 'pop music venue', Amethyst's chic atmosphere, popularity with youth, and modern music selection (often chill pop/indie) align with a 'pop music' taste, providing a stylish place to enjoy contemporary sounds.",
                category_icon: "🎵",
              ),
              Activity(
                time: "17:30",
                location: Location(
                  name: "Amethyst",
                  address:
                      "No 239, Whites Rd, next to Corporation BankRoyapettah, Express Estate, Royapettah, Chennai, Tamil Nadu 600014, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJtRcPTT1mUjoRUVgc-CcQgnU",
                ),
                category: "fashion",
                description:
                    "Wander around the stylish streets near Amethyst and Chamiers Road. This area is home to several independent boutiques and design stores offering unique fashion finds that lean towards contemporary and fusion casual wear, distinct from mall brands.",
                culturalConnection:
                    "A discovery zone for unique casual streetwear, reflecting an evolving sense of modern Chennai style beyond mainstream retail and catering to individual expression.",
                category_icon: "👗",
              ),
              Activity(
                time: "19:30",
                location: Location(
                  name: "Drizzle By The Beach",
                  address:
                      "Part Ill 69, 2nd Main Rd, VGP Layout, Palavakkam, Chennai, Tamil Nadu 600041, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJp6lo3D1dUjoRz7x7FuP2tpE",
                ),
                category: "dining",
                description:
                    "Enjoy a relaxed dinner with a trendy, beachside vibe. Drizzle By The Beach offers a multi-cuisine menu in a contemporary setting, popular among younger crowds for its ambiance and 'escape-from-the-city' feel.",
                culturalConnection:
                    "Offers a relaxed, modern dining experience popular with youth, reflecting Chennai's coastal identity and its emerging casual fine dining scene.",
                category_icon: "🍽️",
              ),
              Activity(
                time: "21:00",
                location: Location(
                  name: "Broken Bridge",
                  address:
                      "277G+HFP Broken Bridge Part, Theosophical Society, Adyar, Chennai, Tamil Nadu 600090, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJeeReOwBnUjoRR_bwrO9mWN8",
                ),
                category: "hidden_gem",
                description:
                    "Experience a unique, slightly eerie but captivating spot popular with locals for its picturesque views, especially at sunset or night. The ruins of a bridge over the Adyar Estuary offer a surreal backdrop and are a favorite for photography and quiet reflection.",
                culturalConnection:
                    "A lesser-known, intriguing landmark that provides a unique photo opportunity and a sense of discovery, reflecting Chennai's urban history and natural beauty, particularly appealing to adventurous youth.",
                category_icon: "💎",
              ),
            ],
          ),
          TravelDay(
            day_number: 2,
            theme: "Artsy Enclaves & Coastal Chill",
            activities: [
              Activity(
                time: "09:00",
                location: Location(
                  name: "Madras Coffee House",
                  address:
                      "7, 6th Avenue, GOCHS Colony, Besant Nagar, Chennai, Tamil Nadu 600090, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJKxlIxIVnUjoRujarAv95EsM",
                ),
                category: "dining",
                description:
                    "Start your day with filter coffee and a light breakfast at a lively local chain. This branch, close to the beach, offers a casual setting popular with students and locals, serving traditional South Indian snacks.",
                culturalConnection:
                    "Experience the quintessential Chennai filter coffee culture in a vibrant, youth-friendly setting, blending local tradition with urban energy and a relaxed morning vibe.",
                category_icon: "🍽️",
              ),
              Activity(
                time: "10:00",
                location: Location(
                  name: "Apparao Galleries",
                  address:
                      "No. 7, Wallace Gardens 3rd Street, Nungambakkam, Chennai, Tamil Nadu 600006, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJsZlSNGpmUjoRg84DQbTDSao",
                ),
                category: "film",
                description:
                    "Explore contemporary Indian art at Apparao Galleries, one of Chennai's well-regarded art spaces. They showcase a diverse range of modern artworks, often with themes relevant to current societal narratives and modern expressions.",
                culturalConnection:
                    "While primarily an art gallery, art and film are often intertwined as visual storytelling. Visiting a contemporary art space broadens the 'cultural spots' preference, offering a glimpse into modern Indian artistic expressions relevant to current trends.",
                category_icon: "🎬",
              ),
              Activity(
                time: "12:00",
                location: Location(
                  name: "Elliots Fashions",
                  address:
                      "16, 4th Main Rd, Besant Nagar, Chennai, Tamil Nadu 600090, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJUbboZvtnUjoR9L0O0_jO46Y",
                ),
                category: "fashion",
                description:
                    "Stroll along the lively streets of Besant Nagar, especially around Elliot's Beach. This area is dotted with independent boutiques and quirky stores offering unique, casual, and bohemian streetwear that stands out from mall brands.",
                culturalConnection:
                    "A hotspot for relaxed, individualistic 'casual streetwear' and boutique finds, reflecting a laid-back, artsy side of Chennai's youth culture and a different fashion aesthetic.",
                category_icon: "👗",
              ),
              Activity(
                time: "13:30",
                location: Location(
                  name: "East Coast at Madras Square",
                  address:
                      "2/520, Sandeep Avenue, Sakthimoorthiamman Nagar, Neelankarai, Chennai, Tamil Nadu 600041, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJK_xmSSNdUjoR2_ectfhzvbU",
                ),
                category: "dining",
                description:
                    "Enjoy lunch at this popular cafe and restaurant with a relaxed, artsy vibe. It offers a mix of continental and Indian dishes in a charming setting, making it a popular spot for young crowds.",
                culturalConnection:
                    "A contemporary dining experience that blends diverse culinary tastes with a relaxed, youthful ambiance, perfect for a casual lunch after exploring the area.",
                category_icon: "🍽️",
              ),
              Activity(
                time: "15:00",
                location: Location(
                  name: "Elliot's Promenade",
                  address:
                      "Elliot's Promenade, Besant Nagar, Chennai, Tamil Nadu 600090, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJzzDvfvxnUjoRgtDJb9MsHNQ",
                ),
                category: "music",
                description:
                    "Immerse yourself in the vibrant atmosphere of Elliot's Beach. While not a specific music venue, the promenade is a hub of activity where young people gather. You'll hear ambient music from nearby cafes, buskers, and local tunes from street vendors, creating an impromptu urban soundscape.",
                culturalConnection:
                    "Connects with the 'pop music' preference by offering a place where modern sounds are part of the lively, youthful urban environment, a true cultural spot where local youth hang out and modern culture unfolds.",
                category_icon: "🎵",
              ),
              Activity(
                time: "17:00",
                location: Location(
                  name: "DakshinaChitra Heritage Museum",
                  address:
                      "R6FR+4M4 DakshinaChitra Heritage Museum, SH 49, Muthukadu, Tamil Nadu 603112, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJU6kGOI5aUjoRmbAbB95gFcs",
                ),
                category: "hidden_gem",
                description:
                    "Take a short trip down ECR to DakshinaChitra, an open-air museum showcasing the living traditions, architecture, and crafts of South Indian states. It's a beautifully curated space offering a deeper dive into regional culture in an engaging and accessible way.",
                culturalConnection:
                    "A truly unique cultural experience, providing insight into the diverse heritage of South India in an interactive and visually appealing manner, moving beyond typical tourist spots for a richer cultural understanding.",
                category_icon: "💎",
              ),
              Activity(
                time: "20:00",
                location: Location(
                  name: "Sofa Brown",
                  address:
                      "Ground Floor, Hafiz Court, 19, Kodambakkam High Rd, Tirumurthy Nagar, Nungambakkam, Chennai, Tamil Nadu 600034, India",
                  maps_link:
                      "https://www.google.com/maps/place/?q=place_id:ChIJyc8aiXVnUjoRZOMZZEsnCDE",
                ),
                category: "dining",
                description:
                    "Conclude your trip with dinner at Sofa Brown, a chic and modern lounge-restaurant known for its good food, relaxed ambiance, and often lively music. It's a favorite among Chennai's younger crowd for a sophisticated yet casual night out.",
                culturalConnection:
                    "A trendy spot that resonates with youth, offering a modern dining experience that combines good food with a cool, contemporary vibe, aligning with a 'pop culture' sensibility and a great way to end your trip.",
                category_icon: "🍽️",
              ),
            ],
          ),
        ],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _particleController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _backgroundAnimation =
        ColorTween(begin: Color(0xFFF8FAFC), end: Color(0xFFF1F5F9)).animate(
          CurvedAnimation(
            parent: _backgroundController,
            curve: Curves.easeInOut,
          ),
        );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final showPermanentDrawer = screenWidth > 1000;

    return Scaffold(
      body: Row(
        children: [
          // Permanent Sidebar for larger screens
          if (showPermanentDrawer) _buildPermanentSidebar(),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopAppBar(showPermanentDrawer),

                // Main Content
                Expanded(
                  child: AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: _backgroundAnimation.value,
                        ),
                        child: Stack(
                          children: [
                            // Animated background particles
                            ...List.generate(
                              8,
                              (index) => AnimatedBuilder(
                                animation: _particleController,
                                builder: (context, child) {
                                  final progress =
                                      (_particleController.value +
                                          index * 0.15) %
                                      1.0;
                                  final size = 3.0 + (index % 2) * 1.5;
                                  final opacity = (0.03 + (index % 3) * 0.02);

                                  return Positioned(
                                    left:
                                        (screenWidth *
                                            (0.1 + (index % 6) * 0.15)) +
                                        math.sin(
                                              progress * 2 * math.pi + index,
                                            ) *
                                            30,
                                    top:
                                        MediaQuery.of(context).size.height *
                                        progress,
                                    child: Container(
                                      width: size,
                                      height: size,
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF3B82F6,
                                        ).withOpacity(opacity),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: EdgeInsets.all(
                                  isLargeScreen ? 32 : 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Welcome Section
                                    _buildWelcomeSection(isLargeScreen),
                                    SizedBox(height: 32),

                                    // Travel Plans Section
                                    Expanded(
                                      child: travelPlans.isEmpty
                                          ? _buildEmptyState(isLargeScreen)
                                          : _buildTravelPlansGrid(
                                              isLargeScreen,
                                              isMediumScreen,
                                            ),
                                    ),
                                  ],
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
        ],
      ),
      // Mobile drawer for smaller screens
      drawer: !showPermanentDrawer ? _buildMobileDrawer(context) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToPromptPage,
        backgroundColor: Color(0xFF3B82F6),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create Plan',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildTopAppBar(bool showPermanentDrawer) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            if (!showPermanentDrawer) ...[
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Color(0xFF1E40AF)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              SizedBox(width: 16),
            ],
            Text(
              showPermanentDrawer ? 'Dashboard' : 'BluVoyage',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E40AF),
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Color(0xFF1E40AF),
              ),
              onPressed: () {},
            ),
            SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: Color(0xFF3B82F6),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermanentSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Sidebar Header
            Container(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.sailing,
                      size: 40,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'BluVoyage',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'AI Travel Planner',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.3), thickness: 1),

            // Navigation Menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                children: [
                  _buildSidebarItem(
                    Icons.dashboard_outlined,
                    'Dashboard',
                    true,
                    () {},
                  ),
                  _buildSidebarItem(
                    Icons.map_outlined,
                    'My Plans',
                    false,
                    () {},
                  ),
                  _buildSidebarItem(
                    Icons.favorite_outline,
                    'Favorites',
                    false,
                    () {},
                  ),
                  _buildSidebarItem(Icons.history, 'History', false, () {}),
                  _buildSidebarItem(
                    Icons.explore_outlined,
                    'Discover',
                    false,
                    () {},
                  ),
                  SizedBox(height: 40),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.2),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  SizedBox(height: 20),
                  _buildSidebarItem(
                    Icons.settings_outlined,
                    'Settings',
                    false,
                    () {},
                  ),
                  _buildSidebarItem(
                    Icons.help_outline,
                    'Help & Support',
                    false,
                    () {},
                  ),
                  _buildSidebarItem(Icons.logout, 'Sign Out', false, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.sailing,
                        size: 40,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'BluVoyage',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Travel Planner',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.white.withOpacity(0.3)),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildDrawerItem(
                      Icons.home_outlined,
                      'Home',
                      true,
                      () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      Icons.map_outlined,
                      'My Plans',
                      false,
                      () {},
                    ),
                    _buildDrawerItem(
                      Icons.favorite_outline,
                      'Favorites',
                      false,
                      () {},
                    ),
                    _buildDrawerItem(Icons.history, 'History', false, () {}),
                    _buildDrawerItem(
                      Icons.settings_outlined,
                      'Settings',
                      false,
                      () {},
                    ),
                    SizedBox(height: 32),
                    _buildDrawerItem(
                      Icons.help_outline,
                      'Help & Support',
                      false,
                      () {},
                    ),
                    _buildDrawerItem(Icons.logout, 'Sign Out', false, () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: GoogleFonts.inter(
                    fontSize: isLargeScreen ? 32 : 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ready to plan your next adventure?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.explore, size: 40, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isLargeScreen) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.map_outlined,
                size: 60,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No travel plans yet',
              style: GoogleFonts.inter(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Start planning your dream vacation with AI assistance',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToPromptPage,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Create Your First Plan',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelPlansGrid(bool isLargeScreen, bool isMediumScreen) {
    int crossAxisCount = isLargeScreen ? 3 : (isMediumScreen ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Travel Plans',
          style: GoogleFonts.inter(
            fontSize: isLargeScreen ? 24 : 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E40AF),
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: travelPlans.length,
            itemBuilder: (context, index) {
              return _buildTravelPlanCard(travelPlans[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTravelPlanCard(TravelPlan plan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelPlanScreen(travelPlan: plan),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    plan.travel_image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 48,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      plan.destination,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      plan.duration,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPromptPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PromptScreen()),
    );
  }
}
