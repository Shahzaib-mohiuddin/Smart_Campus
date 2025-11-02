import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_edit_class_screen.dart';
import '../services/schedule_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0; // 0 = Daily, 1 = Weekly

  final ScheduleService _scheduleService = ScheduleService();
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
    
    // Load classes from local storage
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final loadedClasses = await _scheduleService.loadClasses();
    
    // If no saved classes exist, initialize with default mock data
    if (loadedClasses.isEmpty) {
      final now = DateTime.now();
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      final todayDayName = weekdays[now.weekday - 1];
      final isWeekend = now.weekday == 6 || now.weekday == 7;
      
      // Only add default classes on weekdays
      if (!isWeekend) {
        _classes = [
          {
            'id': '1',
            'subject': 'Data Structures',
            'professor': 'Prof. Ahmed Khan',
            'time': '9:00 - 10:30 AM',
            'room': 'Room 401, Block A',
            'color': Colors.blue,
            'day': todayDayName,
            'reminder': true,
          },
          {
            'id': '2',
            'subject': 'Algorithm Design',
            'professor': 'Prof. Sara Ali',
            'time': '11:00 - 12:30 PM',
            'room': 'Room 302, Block B',
            'color': Colors.green,
            'day': todayDayName,
            'reminder': true,
          },
          {
            'id': '3',
            'subject': 'Database Systems',
            'professor': 'Prof. Hassan Raza',
            'time': '2:00 - 3:30 PM',
            'room': 'Lab 5, Block C',
            'color': Colors.orange,
            'day': todayDayName,
            'reminder': true,
          },
        ];
        // Save default classes to storage
        await _scheduleService.saveClasses(_classes);
      }
    } else {
      _classes = loadedClasses;
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveClasses() async {
    await _scheduleService.saveClasses(_classes);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _getWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return 'Week of ${months[startOfWeek.month - 1]} ${startOfWeek.day} - ${months[endOfWeek.month - 1]} ${endOfWeek.day}, ${startOfWeek.year}';
  }

  Future<void> _deleteClass(Map<String, dynamic> classItem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class?'),
        content: Text('Are you sure you want to delete "${classItem['subject']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // NOTE: Backend implementation deferred
      // TODO: Delete from Firestore after frontend completion
      setState(() {
        _classes.removeWhere((c) => c['id'] == classItem['id']);
      });
      
      // Save to local storage
      await _saveClasses();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${classItem['subject']} deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editClass(Map<String, dynamic> classItem) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditClassScreen(classData: classItem),
      ),
    );

    if (result != null && mounted) {
      // NOTE: Backend implementation deferred
      // TODO: Update in Firestore after frontend completion
      setState(() {
        final index = _classes.indexWhere((c) => c['id'] == classItem['id']);
        if (index != -1) {
          _classes[index] = result;
        }
      });
      
      // Save to local storage
      await _saveClasses();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class updated successfully! ✅'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Schedule',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
          : Column(
              children: [
                // Date/Week Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _currentTab == 0 ? _getFormattedDate() : _getWeekRange(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDailyView(colorScheme),
                      _buildWeeklyView(colorScheme),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditClassScreen(),
            ),
          );

          if (result != null && mounted) {
            // NOTE: Backend implementation deferred
            // TODO: Save to Firestore after frontend completion
            setState(() {
              _classes.add(result);
            });
            
            // Save to local storage
            await _saveClasses();
            
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Class added successfully! ✅'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Class',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDailyView(ColorScheme colorScheme) {
    // Get today's day name
    final todayDayName = _getFormattedDate().split(',')[0];
    
    // Filter classes for today's day
    final todayClasses = _classes
        .where((c) => c['day'] == todayDayName)
        .toList();

    // Show message if no classes for today
    if (todayClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes on $todayDayName',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              todayDayName == 'Sunday' 
                  ? 'Enjoy your day off! 😊'
                  : 'Have a great day!',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: todayClasses.length,
      itemBuilder: (context, index) {
        return _buildClassCard(todayClasses[index], colorScheme);
      },
    );
  }

  Widget _buildWeeklyView(ColorScheme colorScheme) {
    // Group classes by day and time
    final weekSchedule = <String, List<Map<String, dynamic>>>{};
    
    for (var classItem in _classes) {
      final day = classItem['day'] as String;
      if (!weekSchedule.containsKey(day)) {
        weekSchedule[day] = [];
      }
      weekSchedule[day]!.add(classItem);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyCalendar(weekSchedule, colorScheme),
          const SizedBox(height: 24),
          Text(
            'Weekly Schedule',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ..._classes.map((classItem) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildClassCard(classItem, colorScheme),
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(
      Map<String, List<Map<String, dynamic>>> weekSchedule,
      ColorScheme colorScheme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final times = ['9:00 AM', '11:00 AM', '2:00 PM'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with days
          Row(
            children: [
              const SizedBox(width: 60), // Space for time column
              ...days.map((day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  )),
            ],
          ),
          const Divider(),
          // Time rows
          ...times.map((time) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    ...days.map((day) => Expanded(
                          child: _buildWeeklyCell(day, time, colorScheme),
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklyCell(String day, String time, ColorScheme colorScheme) {
    final dayFullName = {
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
    }[day];

    final matchingClass = _classes.firstWhere(
      (c) => c['day'] == dayFullName && c['time'].contains(time.split(':')[0]),
      orElse: () => {},
    );

    if (matchingClass.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      );
    }

    final subject = matchingClass['subject'] as String;
    final abbrev = subject.length > 5 ? subject.substring(0, 5) : subject;
    final color = matchingClass['color'] as Color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          abbrev,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classItem, ColorScheme colorScheme) {
    final color = classItem['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  classItem['subject'],
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildClassInfoRow(
            Icons.person_outline,
            classItem['professor'],
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildClassInfoRow(
            Icons.access_time,
            classItem['time'],
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildClassInfoRow(
            Icons.location_on,
            classItem['room'],
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildClassInfoRow(
            Icons.notifications,
            'Reminder: ${classItem['reminder'] ? 'ON' : 'OFF'}',
            colorScheme,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editClass(classItem),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteClass(classItem),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassInfoRow(
      IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

