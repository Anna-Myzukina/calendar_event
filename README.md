* table of contents
* Packages with access to calendars
* setting
* Get Calendar
* Add event to calendar


#### Package device_calendar with access to calendars
You can easily access the device's calendar using the device_calendar package.
When using it, just add a few lines of settings to AndroidManifest.xml for Android and Info.plist for iOS .


#### setting
Common settings
First device_calendaradd to pubspec.yaml and pub get.

### For Android
Add the following to your AndroidManifest.xml

```
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

The place to add it is OK just below the manifest tag.

```
AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.xxxxxx">
    <uses-permission android:name="android.permission.READ_CALENDAR" />
    <uses-permission android:name="android.permission.WRITE_CALENDAR" />
    ・
    ・
```

For iOS
Add the following to your Info.plist

```
<key>NSCalendarsUsageDescription</key>
<string>Access most functions for calendar viewing and editing.</string>
<key>NSContactsUsageDescription</key>
<string>Access contacts for event attendee editing.</string>
```

Get Calendar
device_calendar By using , you can get all the calendars in your smartphone and you can read and write to each.


The method to get the default calendar is as follows.
(At the end of the method, _defaultCalendarI'm assigning to because I wanted to use it as a variable elsewhere in the class)

```
  Future<Calendar> _getDefaultCalender() async {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          throw Exception("Not granted access to your calendar");
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      final calendars = calendarsResult?.data;
      if(calendars == null || calendars.isEmpty) {
        throw Exception("Can not get calendars");
      }

      _defaultCalendar = calendars!
        .firstWhere((element) => element.isDefault ?? false);
      return _defaultCalendar!;
  }
```


First, the calendar in the smartphone is acquired in the following part.

```
final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
final calendars = calendarsResult?.data;
```

Next,
the calendar can be obtained as above, but before obtaining it, it is necessary to check whether there is permission to access the calendar, and if not, obtain permission.
Here is the code for that:

```
var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
  permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
  if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
    throw Exception("Not granted access to your calendar");
  }
}
```

And the last calendar acquired isDefaulthas a property that determines whether it is a calendar with default settings, so the default calendar is acquired based on that property.

```
_defaultCalendar = calendars!.firstWhere((element) => element.isDefault ?? false);
```

If you fail to get the calendar
If you're using the Emulator and haven't used the calendar before, you'll fail to get it.
Open the Calendar app from the Emulator, log in, then run the code.


Add event to calendar
The method to register an event in the calendar is as follows.
(In my environment, it took some time to actually appear on the calendar (about 1 to 2 minutes?))

```
  Future<void> _addEvent() async{
    final event = Event(
      widget.defaultCalenderId,
      title: _titleController.text,
      start: TZDateTime.local(2022, 9, 28, 2),
      end: TZDateTime.local(2022, 9, 28, 3),
    );
    final result = await DeviceCalendarPlugin().createOrUpdateEvent(event);
    if(result == null) {
      return;
    }
    if(result.isSuccess){
      return;
    }

    if(!result.hasErrors){
      return;
    }

    throw Exception(result.errors.join());
  }
```

In short, just Eventcreate an instance and DeviceCalendarPlugin().createOrUpdateEventpass it as a method argument .
I don't know all of them, but it seems that Eventclasses can also have settings such as location, reminders, all day, attendees, etc.
I think it's easier to understand if you imagine Google Calendar or iOS Calendar.


last
DeviceCalendarPluginIf you look at the method of , it seems that you can also add a calendar, get, edit, and delete events registered in the calendar. It's a very convenient package, so when implementing a calendar, creating a calendar from scratch is one way to do it, but I thought using the default calendar on your smartphone would be an option.

references
Using Device_Calendar Library in Flutter to Communicate with Android/iOS Calendar
