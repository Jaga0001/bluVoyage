import 'package:app/models/travel_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class TravelPlanScreen extends StatefulWidget {
  final TravelPlan travelPlan;

  const TravelPlanScreen({super.key, required this.travelPlan});

  @override
  State<TravelPlanScreen> createState() => _TravelPlanScreenState();
}

class _TravelPlanScreenState extends State<TravelPlanScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _backgroundAnimation;

  int selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);
    _particleController = AnimationController(
      duration: const Duration(seconds: 30),
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

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(color: _backgroundAnimation.value),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(
                  6,
                  (index) => AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      final progress =
                          (_particleController.value + index * 0.2) % 1.0;
                      final size = 2.0 + (index % 2) * 1.0;
                      final opacity = (0.02 + (index % 3) * 0.01);

                      return Positioned(
                        left:
                            (screenWidth * (0.1 + (index % 5) * 0.2)) +
                            math.sin(progress * 2 * math.pi + index) * 40,
                        top: MediaQuery.of(context).size.height * progress,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: Color(0xFF3B82F6).withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Top App Bar
                      _buildTopAppBar(),

                      // Main Content
                      Expanded(
                        child: Row(
                          children: [
                            // Sidebar for day selection
                            if (isLargeScreen || isMediumScreen)
                              _buildDaySidebar(),

                            // Main content area
                            Expanded(child: _buildMainContent(isLargeScreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      height: 80,
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
            IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFF1E40AF), size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.travelPlan.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  Text(
                    '${widget.travelPlan.destination} • ${widget.travelPlan.duration}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.share, color: Color(0xFF3B82F6)),
              onPressed: () {},
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.favorite_border, color: Color(0xFF3B82F6)),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itinerary',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${widget.travelPlan.itinerary.duration_days} days in ${widget.travelPlan.destination}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.travelPlan.itinerary.days.length,
              itemBuilder: (context, index) {
                final day = widget.travelPlan.itinerary.days[index];
                final isSelected = selectedDay == index;

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? Color(0xFF3B82F6) : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Color(0xFF3B82F6)
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day_number}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Color(0xFF3B82F6)
                                : Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Day ${day.day_number}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Color(0xFF1E40AF),
                      ),
                    ),
                    subtitle: Text(
                      day.theme,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        selectedDay = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isLargeScreen) {
    final currentDay = widget.travelPlan.itinerary.days[selectedDay];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          _buildDayHeader(currentDay, isLargeScreen),
          SizedBox(height: 32),

          // Activities List
          _buildActivitiesList(currentDay.activities, isLargeScreen),
        ],
      ),
    );
  }

  Widget _buildDayHeader(TravelDay day, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '${day.day_number}',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${day.day_number}',
                  style: GoogleFonts.inter(
                    fontSize: isLargeScreen ? 28 : 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  day.theme,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(List<Activity> activities, bool isLargeScreen) {
    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        final isLast = index == activities.length - 1;

        return _buildActivityCard(activity, isLast, isLargeScreen);
      }).toList(),
    );
  }

  Widget _buildActivityCard(
    Activity activity,
    bool isLast,
    bool isLargeScreen,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity.category),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor(
                        activity.category,
                      ).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(activity.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(vertical: 8),
                ),
            ],
          ),

          SizedBox(width: 20),

          // Activity Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
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
                  // Time and Category
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          activity.time,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            activity.category,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          activity.category.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(activity.category),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Location
                  Text(
                    activity.location.name,
                    style: GoogleFonts.inter(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Description
                  Text(
                    activity.description,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Cultural Connection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF3B82F6).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Why this matches your taste',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          activity.culturalConnection,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Color(0xFF8B5CF6);
      case 'film':
        return Color(0xFFF59E0B);
      case 'fashion':
        return Color(0xFFEC4899);
      case 'dining':
        return Color(0xFF10B981);
      case 'hidden_gem':
        return Color(0xFF3B82F6);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'film':
        return Icons.movie;
      case 'fashion':
        return Icons.shopping_bag;
      case 'dining':
        return Icons.restaurant;
      case 'hidden_gem':
        return Icons.explore;
      default:
        return Icons.place;
    }
  }
}
