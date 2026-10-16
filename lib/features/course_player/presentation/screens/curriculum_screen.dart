import 'package:flutter/material.dart';

/// Full-screen curriculum view
class CurriculumScreen extends StatelessWidget {
  final String courseId;

  const CurriculumScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculum'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Use CurriculumSheet for bottom sheet view'),
      ),
    );
  }
}
