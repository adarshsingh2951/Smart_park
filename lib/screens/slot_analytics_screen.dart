import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/slot_provider.dart';

class SlotAnalyticsScreen extends StatefulWidget {
  const SlotAnalyticsScreen({super.key});

  @override
  State<SlotAnalyticsScreen> createState() => _SlotAnalyticsScreenState();
}

class _SlotAnalyticsScreenState extends State<SlotAnalyticsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> imagePaths = [
    'assets/images/dummylot.jpg',
    'assets/images/dummylot.jpg',
    'assets/images/dummylot.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();

    // Initialize provider data on loa
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % imagePaths.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<FlSpot> toFlSpots(Map<int, int> map) {
    return map.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    final slotData = Provider.of<SlotProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Slot Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(imagePaths[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imagePaths.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Rating and Booking Frequency Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Average Rating', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Booking Frequency', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            slotData.averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${slotData.bookingFrequency}/mo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Slot Statistics Charts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Slot Statistics',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.9),
                    scrollDirection: Axis.horizontal,
                    children: [
                      LineChartWidget(
                        data: toFlSpots(slotData.hourlyCount),
                        title: "Daily Parking",
                      ),
                      LineChartWidget(
                        data: toFlSpots(slotData.weekdayCount),
                        title: "Weekly Parking",
                      ),
                      LineChartWidget(
                        data: toFlSpots(slotData.dayOfMonthCount),
                        title: "Monthly Parking",
                      ),
                      LineChartWidget(
                        data: toFlSpots(slotData.monthCount),
                        title: "Yearly Parking",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),

            // User Feedback Section
            const Text(
              'User Feedback',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),

            ...slotData.userFeedbacks.map(
                  (feedback) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage('assets/images/profile_default.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          feedback,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> data;
  final String title;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  String _bottomTitle(double value) {
    if(title == "Daily Parking"){
      if (value % 2 == 0) return value.toInt().toString();
      return '';
    }
    if (title == "Monthly Parking") {
      if (value % 5 == 0) return value.toInt().toString();
      return '';
    } else if (title == "Yearly Parking") {
      if (value % 2 == 0) return value.toInt().toString();
      return '';
    } else if (title == "Weekly Parking") {
      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      int index = value.toInt() - 1;
      if (index >= 0 && index < days.length) return days[index];
      return '';
    }
    return value.toInt().toString();
  }

  String _leftTitle(double value) {
    if (value % 1 == 0) {
      if (title == "Yearly Parking" && value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toInt().toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    double bottomInterval = 1;
    if (title == "Monthly Parking") {
      bottomInterval = 5;
    } else if (title == "Yearly Parking") {
      bottomInterval = 2;
    } else if (title == "Weekly Parking") {
      bottomInterval = 1;
    }

    double maxY = data.isNotEmpty
        ? data.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: data.isNotEmpty ? data.first.x : 0,
                  maxX: data.isNotEmpty ? data.last.x : 0,
                  minY: 0,
                  maxY: maxY * 1.2,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxY / 5,
                    verticalInterval: bottomInterval,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                      top: BorderSide(color: Colors.transparent),
                      right: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: bottomInterval,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final text = _bottomTitle(value);
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY/2,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final text = _leftTitle(value);
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
