import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  final Map<DateTime, List> events;
  final ValueChanged<DateTime> onDaySelected;
  const Calendar(
      {super.key, required this.onDaySelected, required this.events});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  _onDaySelected(selectedDay, focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      widget.onDaySelected(selectedDay);
    }
  }

  _onFormatChanged(format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Normalize the day to remove time portion
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return widget.events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: Color(0xfff1f2f6), // set a background color if needed
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.2),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: const Offset(0, 1), // changes position of shadow
        //   ),
        // ],
      ),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2001, 1, 1),
        lastDay: DateTime.utc(2050, 12, 31),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        calendarFormat: _calendarFormat,
        onFormatChanged: _onFormatChanged,
        headerVisible: true,
        headerStyle:
            const HeaderStyle(titleCentered: true, formatButtonVisible: false),
        daysOfWeekStyle: const DaysOfWeekStyle(
            weekendStyle: TextStyle(color: Color(0xff2A3143)),
            weekdayStyle: TextStyle(color: Color(0xff2A3143))),
        calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
                color: Color(0xFFFF6F61), shape: BoxShape.circle)),
        eventLoader: _getEventsForDay,
        rowHeight: 40,
      ),
    );
  }
}
