import 'package:flutter/material.dart';

// Model đơn giản để chứa thông tin mỗi bài học
class VideoLesson {
  final String title;
  final String duration;

  VideoLesson({required this.title, required this.duration});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Details UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // Bạn có thể thay đổi font chữ ở đây
      ),
      home: const CourseDetailsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key});

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  // Trạng thái để quản lý tab nào đang được chọn
  bool _isVideosTabSelected = true;

  // Dữ liệu giả cho danh sách video
  final List<VideoLesson> videoLessons = [
    VideoLesson(title: 'Introduction to Flutter', duration: '20 min 50 sec'),
    VideoLesson(title: 'Installing Flutter on Windows', duration: '20 min 50 sec'),
    VideoLesson(title: 'Setup Emulator on Windows', duration: '20 min 50 sec'),
    VideoLesson(title: 'Creating Our First App', duration: '20 min 50 sec'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black54),
        title: const Text(
          'Flutter',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildThumbnail(),
              const SizedBox(height: 24),
              _buildCourseInfo(),
              const SizedBox(height: 24),
              _buildTabButtons(),
              const SizedBox(height: 24),
              // Hiển thị danh sách video hoặc mô tả tùy thuộc vào tab được chọn
              if (_isVideosTabSelected) _buildVideoList() else _buildDescription(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho ảnh thumbnail
  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thay 'assets/images/flutter_thumbnail.png' bằng đường dẫn ảnh của bạn
          Image.asset('assets/images/flutter-clouds.jpg'),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Color(0xFF6C63FF), size: 40),
          ),
        ],
      ),
    );
  }

  // Widget cho thông tin khóa học
  Widget _buildCourseInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flutter Complete Course',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Created by Dear Programmer',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 4),
        Text(
          '55 Videos',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Widget cho 2 nút tab
  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isVideosTabSelected = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _isVideosTabSelected ? const Color(0xFF6C63FF) : const Color(0xFFE0DFFE),
              foregroundColor: _isVideosTabSelected ? Colors.white : const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Videos'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isVideosTabSelected = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              !_isVideosTabSelected ? const Color(0xFF6C63FF) : const Color(0xFFE0DFFE),
              foregroundColor: !_isVideosTabSelected ? Colors.white : const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Description'),
          ),
        ),
      ],
    );
  }

  // Widget cho danh sách video
  Widget _buildVideoList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của ListView con
      itemCount: videoLessons.length,
      itemBuilder: (context, index) {
        final lesson = videoLessons[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(lesson.duration, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget cho phần mô tả (hiển thị khi tab Description được chọn)
  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Text(
        'Đây là phần mô tả chi tiết của khóa học Flutter. Bạn sẽ học được tất cả các kiến thức từ cơ bản đến nâng cao để xây dựng một ứng dụng hoàn chỉnh.',
        style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
      ),
    );
  }
}