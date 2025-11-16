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
    
    // Clear any existing classes and load fresh
    _clearAndLoadClasses();
  }
  
  Future<void> _clearAndLoadClasses() async {
    // Load existing classes from storage
    await _loadClasses();
  }

  Future<void> _loadClasses() async {
    // Load any existing classes from storage
    _classes = await _scheduleService.loadClasses();
    
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
    
    // Filter classes for today's day (case-insensitive comparison)
    final todayClasses = _classes
        .where((c) => (c['day'] as String).toLowerCase() == todayDayName.toLowerCase())
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
    // Show 5 time slots per day in the weekly grid
    // Adjust these as needed to match your institute timing
    final times = ['9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM'];

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
    // Helper function to format time for grid comparison
    String formatTimeForGrid(String timeStr) {
      // Remove any leading/trailing whitespace
      timeStr = timeStr.trim();
      
      // Handle case where time might be in 24-hour format
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          var hour = int.tryParse(parts[0]) ?? 0;
          final minutePart = parts[1].split(' ')[0];
          final period = timeStr.contains('PM') ? 'PM' : 'AM';
          
          // Convert to 12-hour format if needed
          if (hour > 12) {
            hour -= 12;
            return '$hour:${minutePart.split(' ')[0]} PM';
          } else if (hour == 0) {
            return '12:${minutePart.split(' ')[0]} AM';
          } else if (hour == 12) {
            return '12:${minutePart.split(' ')[0]} PM';
          } else {
            return '$hour:${minutePart.split(' ')[0]} $period';
          }
        }
      }
      
      // Return as is if we can't parse it
      return timeStr;
    }

    // Map of short day names to full day names
    final dayMap = {
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
      'Sun': 'Sunday',
    };
    
    // Get the full day name from the short name
    final dayFullName = dayMap[day] ?? day;

    // Find all classes that match both day and time
    final matchingClasses = _classes.where(
      (c) {
        // Check if day matches (case-insensitive)
        if ((c['day'] as String).toLowerCase() != dayFullName.toLowerCase()) {
          return false;
        }
        
        // Get the class time string (e.g., '9:00 AM - 10:30 AM')
        final classTimeStr = c['time'] as String;
        
        // Get the start time part (e.g., '9:00 AM')
        final classStartTime = classTimeStr.split(' - ')[0];
        
        // Format the time to match the grid format (e.g., '9:00 AM' -> '9:00 AM')
        final formattedClassTime = formatTimeForGrid(classStartTime);
        
        // Compare with the current grid time
        return formattedClassTime == time;
      },
    ).toList();

    if (matchingClasses.isEmpty) {
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

    // Build the class indicators for all matching classes
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: matchingClasses.map((matchingClass) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            color: (matchingClass['color'] as Color?)?.withOpacity(0.2) ??
                colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: (matchingClass['color'] as Color?) ?? colorScheme.primary,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Center(
            child: Text(
              matchingClass['subject']?.toString().substring(0, 1) ?? '?',
              style: TextStyle(
                color: (matchingClass['color'] as Color?) ?? colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
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

