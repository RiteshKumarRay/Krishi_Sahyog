import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({Key? key}) : super(key: key);

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  List<ForumPost> posts = [
    ForumPost(
      username: "राम कुमार शर्मा",
      avatarColor: AppTheme.lightTheme.colorScheme.primary,
      title: "मिरची की फसल में रोग नियंत्रण के उपाय",
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      description:
      "मेरी मिर्ची की फसल में पत्ती पीली पड़ रही है, क्या कोई सुझाव है?",
      repliesCount: 4,
    ),
    ForumPost(
      username: "गीता देवी",
      avatarColor: AppTheme.lightTheme.colorScheme.secondary,
      title: "धान की सही कटाई का समय",
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      description:
      "मुझे अपने धान की फसल के लिए कटाई के सही समय की जानकारी चाहिए।",
      repliesCount: 2,
    ),
    ForumPost(
      username: "अजय वर्मा",
      avatarColor: AppTheme.lightTheme.colorScheme.tertiary,
      title: "किसान सब्सिडी योजनाओं के बारे में जानकारी",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      description:
      "सरकार द्वारा जारी किसान सब्सिडी योजनाओं के लाभ कैसे प्राप्त करें?",
      repliesCount: 6,
    ),
  ];

  String formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return "अभी";
    if (diff.inMinutes < 60) return "${diff.inMinutes} मिनट पहले";
    if (diff.inHours < 24) return "${diff.inHours} घंटे पहले";
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("समुदाय"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12.0),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            color: AppTheme.lightTheme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username and avatar
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: post.avatarColor,
                        child: Text(
                          post.username.substring(0, 1),
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          post.username,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        formatTimestamp(post.timestamp),
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Post title
                  Text(
                    post.title,
                    style: AppTheme.lightTheme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Post description
                  Text(
                    post.description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Reply button and count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomIconWidget(
                        iconName: 'comment',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${post.repliesCount} जवाब",
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Add new post creation logic here
        },
      ),
    );
  }
}

class ForumPost {
  final String username;
  final Color avatarColor;
  final String title;
  final String description;
  final DateTime timestamp;
  final int repliesCount;

  ForumPost({
    required this.username,
    required this.avatarColor,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.repliesCount,
  });
}
