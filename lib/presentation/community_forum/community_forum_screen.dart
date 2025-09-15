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
      username: "Ram Kumar Sharma",
      avatarColor: AppTheme.lightTheme.colorScheme.primary,
      title: "Measures for Disease Control in Chili Crop",
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      description:
      "In my chili crop, the leaves are turning yellow, any suggestions?",
      repliesCount: 4,
    ),
    ForumPost(
      username: "Geeta Devi",
      avatarColor: AppTheme.lightTheme.colorScheme.secondary,
      title: "Right Time for Rice Harvesting",
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      description:
      "I need information on the right harvesting time for my rice crop.",
      repliesCount: 2,
    ),
    ForumPost(
      username: "Ajay Verma",
      avatarColor: AppTheme.lightTheme.colorScheme.tertiary,
      title: "Information about Farmer Subsidy Schemes",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      description:
      "How to avail benefits of farmer subsidy schemes issued by the government?",
      repliesCount: 6,
    ),
    ForumPost(
      username: "Sita Patel",
      avatarColor: AppTheme.lightTheme.colorScheme.primary,
      title: "Best Fertilizers for Wheat",
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      description:
      "What are the best fertilizers for wheat crop?",
      repliesCount: 3,
    ),
    ForumPost(
      username: "Vikram Singh",
      avatarColor: AppTheme.lightTheme.colorScheme.secondary,
      title: "Irrigation Techniques",
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      description:
      "Sharing some irrigation techniques for dry areas.",
      repliesCount: 1,
    ),
    ForumPost(
      username: "Priya Mehta",
      avatarColor: AppTheme.lightTheme.colorScheme.tertiary,
      title: "Pest Management in Vegetables",
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      description:
      "Tips for managing pests in vegetable gardens.",
      repliesCount: 5,
    ),
  ];

  String formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return "Now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _showAddPostDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Enter title"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: "Enter description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () {
                if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  setState(() {
                    posts.insert(0, ForumPost(
                      username: "Current User",
                      avatarColor: AppTheme.lightTheme.colorScheme.primary,
                      title: titleController.text,
                      description: descriptionController.text,
                      timestamp: DateTime.now(),
                      repliesCount: 0,
                    ));
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post created successfully!')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community"),
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
                              ?.copyWith(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          post.username,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Text(
                        formatTimestamp(post.timestamp),
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Post title
                  Text(
                    post.title,
                    style: AppTheme.lightTheme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  // Post description
                  Text(
                    post.description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium
                        ?.copyWith(fontSize: 12),
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
                        "${post.repliesCount} replies",
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 10,
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
        onPressed: _showAddPostDialog,
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