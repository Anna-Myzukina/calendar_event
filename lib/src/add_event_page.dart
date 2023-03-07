import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

class AddEventPage extends StatefulWidget {
  final String defaultCalenderId;
  const AddEventPage({Key? key, required this.defaultCalenderId})
      : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  /// title text controller
  final TextEditingController _titleController = TextEditingController();

  /// Whether all day (true: all day false: not all day)
  bool _isAllDay = false;

  /// the date of the event
  DateTime _date = DateTime.now();

  /// Start date and time of the event
  TimeOfDay _startTime = TimeOfDay.now().getEventStartTime();

  /// End date and time of the event
  TimeOfDay _endTime = TimeOfDay.now().getEventStartTime().addHour(1);

  /// Whether the start date/time of the event is after the end date/time (true: the start date/time is after the end date/time, false: not after the end date/time)
  bool _isStartTimeAfterEndTime = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              await _save(context);
            },
            child: Text(
              "Save",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Add title",
                ),
              ),
              // All day setting
              Row(
                children: [
                  const Text("All-day"),
                  Switch(
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      }),
                ],
              ),
              // start date
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: Text(
                      DateFormat.yMMMd().format(_date),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _isStartTimeAfterEndTime
                              ? Colors.red
                              : Colors.black),
                    ),
                  ),
                  if (!_isAllDay)
                    TextButton(
                      onPressed: () async {
                        _selectStartTime(context);
                      },
                      child: Text(
                        _startTime.format(context),
                        style: _isStartTimeAfterEndTime
                            ? Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.red)
                            : Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                ],
              ),
              // End date and time
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: Text(
                      DateFormat.yMMMd().format(_date),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (!_isAllDay)
                    TextButton(
                      onPressed: () {
                        _selectEndTime(context);
                      },
                      child: Text(
                        _endTime.format(context),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// add event
  Future<void> _save(BuildContext context) async {
    // Error if the start time is later than the end time and not all day
    if (_isStartTimeAfterEndTime && !_isAllDay) {
      showAlertDialog(context, "Start time cannot be after end time.");
      return;
    }

    // add event
    try {
      await _addEvent();
    } catch (e) {
      showAlertDialog(context, e.toString());
      return;
    }

    // Return to previous page if no errors
    if (!mounted) return;
    context.pop();
  }

  /// add event
  Future<void> _addEvent() async {
    // Create Event with input contents
    final event = Event(
      widget.defaultCalenderId,
      title: _titleController.text,
      start: TZDateTime.local(_date.year, _date.month, _date.day,
          _startTime.hour, _startTime.minute),
      end: TZDateTime.local(
          _date.year, _date.month, _date.day, _endTime.hour, _endTime.minute),
    );

    // add event
    final result = await DeviceCalendarPlugin().createOrUpdateEvent(event);

    if (result == null || !result.isSuccess) {
      throw Exception("Failed to add event.");
    }

    if (result.hasErrors) {
      throw Exception(result.errors.join());
    }

    return;
  }

  /// Choose a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(_date.year),
        lastDate: DateTime(_date.year + 10));
    if (datePicked != null && datePicked != _date) {
      setState(() {
        _date = datePicked;
      });
    }
  }

  /// Choose a start time
  Future<void> _selectStartTime(BuildContext context) async {
    final selectedTime = await _selectTime(context, _startTime);
    if (selectedTime == null || selectedTime == _startTime) {
      return;
    }

    setState(() {
      _startTime = selectedTime;
      if (_startTime.isAfter(_endTime)) {
        _endTime = _startTime.addHour(1);
      }

      _isStartTimeAfterEndTime = _startTime.isAfter(_endTime);
    });
  }

  /// Choose an end time
  Future<void> _selectEndTime(BuildContext context) async {
    final selectedTime = await _selectTime(context, _endTime);
    if (selectedTime == null || selectedTime == _endTime) {
      return;
    }

    setState(() {
      _endTime = selectedTime;
      _isStartTimeAfterEndTime = _startTime.isAfter(_endTime);
    });
  }

  /// select time
  Future<TimeOfDay?> _selectTime(
      BuildContext context, TimeOfDay initialTime) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    return timePicked;
  }

  Future<void> showAlertDialog(
      BuildContext context, String errorMessage) async {
    await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  /// Extension method that adds the time of the argument
  TimeOfDay addHour(int hour) {
    return replacing(hour: this.hour + hour, minute: minute);
  }

  /// Extension method to get event start time
  TimeOfDay getEventStartTime() {
    return replacing(hour: hour, minute: 0);
  }

  /// Returns true if the time is later than the argument time
  bool isAfter(TimeOfDay timeOfDay) {
    double thisTime = hour.toDouble() + minute.toDouble() / 60;
    double time = timeOfDay.hour.toDouble() + minute.toDouble() / 60;
    return thisTime - time > 0;
  }
}
