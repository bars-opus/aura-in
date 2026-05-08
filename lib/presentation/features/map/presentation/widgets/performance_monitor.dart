import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Debug widget to monitor map performance
class PerformanceMonitor extends StatefulWidget {
  final Widget child;

  const PerformanceMonitor({super.key, required this.child});

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  double _fps = 0;
  int _frameCount = 0;
  int _lastTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _lastTimestamp = DateTime.now().millisecondsSinceEpoch;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _frameCount++;
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = now - _lastTimestamp;
        if (elapsed >= 1000) {
          setState(() {
            _fps = _frameCount / (elapsed / 1000);
            _frameCount = 0;
            _lastTimestamp = now;
          });
        }
        _startMonitoring();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'FPS: ${_fps.toStringAsFixed(0)}',
              style: TextStyle(
                color: _fps > 50 ? Colors.green : Colors.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
