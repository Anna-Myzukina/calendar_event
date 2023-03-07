import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceCalenderPage extends StatefulWidget {
  const DeviceCalenderPage({Key? key}) : super(key: key);

  @override
  State<DeviceCalenderPage> createState() => _DeviceCalenderPageState();
}

class _DeviceCalenderPageState extends State<DeviceCalenderPage> {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  Calendar? _defaultCalendar;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _getDefaultCalender(),
          builder: (BuildContext context, AsyncSnapshot<Calendar> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                snapshot.error.toString(),
                style: TextStyle(fontSize: 32),
              );
            }

            if (snapshot.hasData) {
              return Column(
                children: [
                  Text(
                    "DefaultCalendar: ${snapshot.data!.name}",
                    style: TextStyle(fontSize: 32),
                  )
                ],
              );
            } else {
              return const Text(
                "data does not exist",
                style: TextStyle(fontSize: 32),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressedAddButton,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Get default calendar
  Future<Calendar> _getDefaultCalender() async {
    // Check if the calendar has permission, get it if not
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        throw Exception("Not granted access to your calendar");
      }
    }

    // Get calendar list in smartphone
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data;
    if (calendars == null || calendars.isEmpty) {
      throw Exception("Can't get calendars.\n"
          "Emulator If you're using , and you've never used a calendar before, the fetch will fail.\n"
          "Emulator Please open the calendar app from , log in, and then run the code.");
    }

    // Get the default calendar from the calendar list
    _defaultCalendar =
        calendars.firstWhere((element) => element.isDefault ?? false);
    return _defaultCalendar!;
  }

  void _onPressedAddButton() {
    if (_defaultCalendar == null || _defaultCalendar!.id == null) {
      return;
    }

    // Transition to the event addition page
    context.goNamed(
      "addEventPage",
      params: {'defaultCalendarId': _defaultCalendar!.id!},
    );
  }
}
