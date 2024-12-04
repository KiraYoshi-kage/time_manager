class CourseTime {
  static const List<TimeSlot> timeSlots = [
    TimeSlot(start: "8:00", end: "8:45", section: 1),
    TimeSlot(start: "8:55", end: "9:40", section: 2),
    TimeSlot(start: "10:00", end: "10:45", section: 3),
    TimeSlot(start: "10:55", end: "11:40", section: 4),
    TimeSlot(start: "14:10", end: "14:55", section: 5),
    TimeSlot(start: "15:05", end: "15:50", section: 6),
    TimeSlot(start: "16:00", end: "16:45", section: 7),
    TimeSlot(start: "16:55", end: "17:40", section: 8),
    TimeSlot(start: "18:40", end: "19:25", section: 9),
    TimeSlot(start: "19:35", end: "20:20", section: 10),
    TimeSlot(start: "20:30", end: "21:15", section: 11),
    TimeSlot(start: "21:25", end: "22:10", section: 12),
  ];

  static TimeSlot? getTimeSlotBySection(int section) {
    try {
      return timeSlots.firstWhere((slot) => slot.section == section);
    } catch (e) {
      return null;
    }
  }
}

class TimeSlot {
  final String start;
  final String end;
  final int section;

  const TimeSlot({
    required this.start,
    required this.end,
    required this.section,
  });
}
