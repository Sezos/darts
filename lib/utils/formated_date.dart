import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class FormatedDate extends StatefulWidget {
  const FormatedDate({super.key});

  @override
  State<FormatedDate> createState() => _FormatedDateState();
}

class _FormatedDateState extends State<FormatedDate> {
  String formattedDate = '';
  DateTime now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("mn_MN");
    formattedDate = DateFormat("MMM dd, yyyy - EEEE", "mn_MN").format(now);
    updateTime();
  }

  void updateTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          now = DateTime.now();
          formattedDate = DateFormat(
            "MMM dd, yyyy - EEEE",
            "mn_MN",
          ).format(now);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedTimeUnit(DateFormat("HH").format(now)),
              _buildSeparator(),
              _buildAnimatedTimeUnit(DateFormat("mm").format(now)),
              _buildSeparator(),
              _buildAnimatedTimeUnit(DateFormat("ss").format(now)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff6A7D94),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTimeUnit(String timeUnit) {
    return SizedBox(
      height: 70,
      width: 70,
      child: Center(
        child: Text(
          timeUnit,
          key: ValueKey<String>(timeUnit),
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w300,
            color: Color(0xff293646),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w300,
          color: Color(0xff293646),
        ),
      ),
    );
  }
}
