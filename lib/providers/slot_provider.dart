import 'package:flutter/material.dart';

class SlotProvider with ChangeNotifier {
  final double averageRating = 4.7;
  final int bookingFrequency = 19;
  Map<int, int> hourlyCount = {};
  Map<int, int> weekdayCount = {};
  Map<int, int> dayOfMonthCount = {};
  Map<int, int> monthCount = {};

  void processTimestamps(List<String> timestamps) {
    hourlyCount.clear();
    weekdayCount.clear();
    dayOfMonthCount.clear();
    monthCount.clear();

    for (String ts in timestamps) {
      final date = DateTime.parse(ts).toLocal();
      hourlyCount[date.hour] = (hourlyCount[date.hour] ?? 0) + 1;
      weekdayCount[date.weekday] = (weekdayCount[date.weekday] ?? 0) + 1;
      dayOfMonthCount[date.day] = (dayOfMonthCount[date.day] ?? 0) + 1;
      monthCount[date.month] = (monthCount[date.month] ?? 0) + 1;
    }
  }

  SlotProvider(){
    initializeSlotData();
  }
  Future<void> initializeSlotData() async {
    processTimestamps(simulatedTimestamps);
  }

  final List<String> userFeedbacks = [
    "Great experience!",
    "Easy booking process.",
    "Would love more slots.",
    "Amazing",
    "Loved it",
    "Great",
    "Satisfactory",
    "Wow",
    "Cat",
  ];

  final List<String> simulatedTimestamps = [
    // Today (2025-05-26)
    "2025-05-26T08:00:00Z",
    "2025-05-26T09:00:00Z",
    "2025-05-26T10:00:00Z",
    "2025-05-26T14:00:00Z",
    "2025-05-26T18:30:00Z",

    // Yesterday
    "2025-05-25T07:45:00Z",
    "2025-05-25T12:00:00Z",
    "2025-05-25T15:00:00Z",

    // Last few days
    "2025-05-24T08:00:00Z",
    "2025-05-24T13:30:00Z",
    "2025-05-23T08:10:00Z",
    "2025-05-23T09:15:00Z",
    "2025-05-23T14:45:00Z",
    "2025-05-22T14:00:00Z",
    "2025-05-22T17:45:00Z",

    // Week of 20th May
    "2025-05-21T08:00:00Z",
    "2025-05-20T09:30:00Z",
    "2025-05-19T11:00:00Z",
    "2025-05-18T16:00:00Z",
    "2025-05-17T18:30:00Z",
    "2025-05-16T08:30:00Z",

    // Earlier May
    "2025-05-10T12:00:00Z",
    "2025-05-10T17:00:00Z",
    "2025-05-09T09:00:00Z",
    "2025-05-08T14:30:00Z",
    "2025-05-07T10:15:00Z",
    "2025-05-06T08:45:00Z",
    "2025-05-05T13:00:00Z",
    "2025-05-04T12:30:00Z",
    "2025-05-03T15:45:00Z",
    "2025-05-02T11:00:00Z",
    "2025-05-01T09:15:00Z",

    // April
    "2025-04-30T08:00:00Z",
    "2025-04-25T14:45:00Z",
    "2025-04-20T10:00:00Z",
    "2025-04-18T16:30:00Z",
    "2025-04-15T12:00:00Z",
    "2025-04-12T11:45:00Z",
    "2025-04-10T12:00:00Z",
    "2025-04-05T08:30:00Z",
    "2025-04-01T14:15:00Z",

    // March
    "2025-03-31T17:00:00Z",
    "2025-03-25T09:45:00Z",
    "2025-03-20T11:00:00Z",
    "2025-03-15T13:00:00Z",
    "2025-03-12T16:30:00Z",
    "2025-03-11T18:00:00Z",
    "2025-03-05T10:30:00Z",
    "2025-03-01T09:00:00Z",

    // February
    "2025-02-28T08:00:00Z",
    "2025-02-20T12:30:00Z",
    "2025-02-15T11:00:00Z",
    "2025-02-10T17:00:00Z",
    "2025-02-05T14:45:00Z",
    "2025-02-01T10:15:00Z",

    // January
    "2025-01-31T09:30:00Z",
    "2025-01-25T08:00:00Z",
    "2025-01-20T13:00:00Z",
  ];
}
