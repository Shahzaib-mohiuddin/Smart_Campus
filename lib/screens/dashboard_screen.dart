import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'schedule_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _notificationCount = 3;

  // Mock user data
  final String _userName = 'Ali';
  
  // Get greeting based on time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Get formatted date
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // Mock classes data - will be filtered based on today
  List<Map<String, dynamic>> get _todayClasses {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    
    // No classes on weekends (Saturday = 6, Sunday = 7)
    if (weekday == 6 || weekday == 7) {
      return [];
    }
    
    // Show classes on weekdays (Monday-Friday: weekday 1-5)
    return [
      {
        'title': 'Data Structures',
        'professor': 'Prof. Ahmed',
        'time': '9:00-10:30 AM',
        'room': 'Room 401',
        'color': Colors.blue,
      },
      {
        'title': 'Algorithm Design',
        'professor': 'Prof. Sara',
        'time': '11:00-12:30 PM',
        'room': 'Room 302',
        'color': Colors.green,
      },
      {
        'title': 'Database Systems',
        'professor': 'Prof. Khan',
        'time': '2:00-3:30 PM',
        'room': 'Room 205',
        'color': Colors.orange,
      },
    ];
  }

  // Mock events data
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Tech Workshop',
      'date': 'Oct 5, 2:00 PM',
      'image': Icons.computer,
      'color': Colors.purple,
    },
    {
      'title': 'Career Fair',
      'date': 'Oct 8, 10:00 AM',
      'image': Icons.business,
      'color': Colors.amber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: _buildDrawer(colorScheme),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: Refresh data from backend
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              // Refresh data here
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(colorScheme),
                const SizedBox(height: 20),

                // Greeting Section
                _buildGreetingSection(colorScheme),
                const SizedBox(height: 32),

                // Quick Actions
                _buildQuickActions(colorScheme),
                const SizedBox(height: 32),

                // Today's Classes
                _buildTodayClasses(colorScheme),
                const SizedBox(height: 32),

                // Upcoming Events
                _buildUpcomingEvents(colorScheme),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(colorScheme),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Icon - Opens drawer
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              color: colorScheme.onSurface,
            ),
          ),

          // Right side: Notifications and Profile
          Row(
            children: [
              // Notifications
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Navigate to notifications screen
                    },
                    color: colorScheme.onSurface,
                  ),
                  if (_notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              
              // Profile Picture
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to profile screen
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    _userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(ColorScheme colorScheme) {
    final greeting = _getGreeting();
    final date = _getFormattedDate();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $_userName! 👋',
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    final actions = [
      {'icon': Icons.calendar_today, 'title': 'My\nSchedule', 'color': Colors.blue},
      {'icon': Icons.library_books, 'title': 'Library', 'color': Colors.green},
      {'icon': Icons.event, 'title': 'Events', 'color': Colors.orange},
      {'icon': Icons.search, 'title': 'Lost\n& Found', 'color': Colors.purple},
      {'icon': Icons.groups, 'title': 'Study\nGroup', 'color': Colors.teal},
      {'icon': Icons.restaurant, 'title': 'Cafeteria', 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildQuickActionCard(
                action['icon'] as IconData,
                action['title'] as String,
                action['color'] as Color,
                colorScheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    String title,
    Color color,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective screen
        if (title.contains('Schedule')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScheduleScreen()),
          );
        } else {
          // TODO: Navigate to other screens (Library, Events, etc.)
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayClasses(ColorScheme colorScheme) {
    final classes = _todayClasses;
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final isWeekend = weekday == 6 || weekday == 7;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Classes${classes.isNotEmpty ? ' (${classes.length})' : ''}",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (classes.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full schedule
                  },
                  child: const Text('View All →'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isWeekend)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      weekday == 6 
                          ? 'No classes on Saturday' 
                          : 'No classes on Sunday',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weekday == 6
                          ? 'Enjoy your weekend! 😊'
                          : 'Enjoy your day off! 😊',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...classes.map((classItem) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildClassCard(classItem, colorScheme),
                )),
        ],
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classItem, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to class details
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (classItem['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (classItem['color'] as Color).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: classItem['color'] as Color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        classItem['professor'],
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        classItem['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        classItem['room'],
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Events (${_upcomingEvents.length})',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all events
                },
                child: const Text('View All →'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._upcomingEvents.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventCard(event, colorScheme),
              )),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to event details
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (event['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                event['image'] as IconData,
                color: event['color'] as Color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Register for event
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Register',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(ColorScheme colorScheme) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        
        // Navigate to respective screen based on index
        switch (index) {
          case 0: // Home - already on dashboard
            break;
          case 1: // Schedule
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScheduleScreen()),
            ).then((_) {
              // Reset to home when coming back
              setState(() {
                _selectedIndex = 0;
              });
            });
            break;
          case 2: // Library
            // TODO: Navigate to library screen
            break;
          case 3: // Events
            // TODO: Navigate to events screen
            break;
          case 4: // More
            // TODO: Navigate to more screen
            break;
        }
      },
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.5),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }

  Widget _buildDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    _userName[0].toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ali@university.edu.pk',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('My Schedule'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to schedule screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Library'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to library screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to events screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final authService = AuthService();
              await authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

