import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditClassScreen extends StatefulWidget {
  final Map<String, dynamic>? classData; // If provided, we're editing

  const AddEditClassScreen({super.key, this.classData});

  @override
  State<AddEditClassScreen> createState() => _AddEditClassScreenState();
}

class _AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _professorController = TextEditingController();
  final _roomController = TextEditingController();
  final _sectionController = TextEditingController();

  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Color _selectedColor = Colors.blue;
  String? _selectedSemester;
  bool _reminderEnabled = true;
  bool _isLoading = false;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.classData != null) {
      // Editing existing class - populate fields
      _subjectController.text = widget.classData!['subject'] ?? '';
      _professorController.text = widget.classData!['professor'] ?? '';
      _roomController.text = widget.classData!['room'] ?? '';
      _selectedDay = widget.classData!['day'];
      _selectedColor = widget.classData!['color'] ?? Colors.blue;
      _reminderEnabled = widget.classData!['reminder'] ?? true;
      
      // Parse time from string like "9:00 - 10:30 AM"
      final timeStr = widget.classData!['time'] ?? '';
      if (timeStr.isNotEmpty) {
        final parts = timeStr.split(' - ');
        if (parts.length == 2) {
          _startTime = _parseTimeString(parts[0]);
          _endTime = _parseTimeString(parts[1]);
        }
      }
      
      _selectedSemester = widget.classData!['semester'] ?? '5';
      _sectionController.text = widget.classData!['section'] ?? 'A';
    } else {
      // New class - set defaults
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 30);
      _selectedSemester = '5';
      _sectionController.text = 'A';
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final cleaned = timeStr.replaceAll(' AM', '').replaceAll(' PM', '');
      final parts = cleaned.split(':');
      if (parts.length == 2) {
        var hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        if (timeStr.contains('PM') && hour != 12) hour += 12;
        if (timeStr.contains('AM') && hour == 12) hour = 0;
        
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _professorController.dispose();
    _roomController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 10, minute: 30)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day')),
      );
      return;
    }
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final classData = {
        'id': widget.classData?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'subject': _subjectController.text.trim(),
        'professor': _professorController.text.trim(),
        'time': '${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}',
        'room': _roomController.text.trim(),
        'color': _selectedColor,
        'day': _selectedDay!,
        'reminder': _reminderEnabled,
        'section': _sectionController.text.trim(),
        'semester': _selectedSemester,
      };

      if (!mounted) return;

      Navigator.pop(context, classData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditMode = widget.classData != null;

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
          isEditMode ? 'Edit Class' : 'Add New Class',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subject Name
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Subject name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Teacher Name
                TextFormField(
                  controller: _professorController,
                  decoration: InputDecoration(
                    labelText: 'Teacher Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Teacher name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Room Number
                TextFormField(
                  controller: _roomController,
                  decoration: InputDecoration(
                    labelText: 'Room Number',
                    hintText: 'e.g., Room 401, Block A',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Room number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Select Day
                Text(
                  'Select Day:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ..._days.map((day) => RadioListTile<String>(
                      title: Text(day),
                      value: day,
                      groupValue: _selectedDay,
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    )),
                const SizedBox(height: 24),

                // Start Time
                Text(
                  'Start Time:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _selectTime(true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startTime != null
                              ? _formatTime(_startTime!)
                              : 'Select time',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // End Time
                Text(
                  'End Time:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _selectTime(false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endTime != null
                              ? _formatTime(_endTime!)
                              : 'Select time',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Card Color
                Text(
                  'Card Color:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _colors.map((color) {
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Section
                DropdownButtonFormField<String>(
                  value: _sectionController.text.isEmpty ? null : _sectionController.text,
                  decoration: InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  items: ['A', 'B', 'C', 'D'].map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sectionController.text = value ?? 'A';
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Semester
                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  decoration: InputDecoration(
                    labelText: 'Semester',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  items: _semesters.map((sem) {
                    return DropdownMenuItem(
                      value: sem,
                      child: Text('Semester $sem'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSemester = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Enable Reminder
                SwitchListTile(
                  title: const Text('Enable Reminder'),
                  subtitle: const Text('Get notified before class starts'),
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _reminderEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditMode ? 'UPDATE CLASS' : 'SAVE CLASS',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

