import 'dart:convert';

import 'package:informasigedungserbaguna/services/post_services.dart';
import 'package:informasigedungserbaguna/models/post.dart';
import 'package:informasigedungserbaguna/screens/detail_screen.dart';
import 'package:informasigedungserbaguna/screens/add_post_screen.dart';
import 'package:flutter/material.dart';

class PostListItem extends StatelessWidget {
  final Post post;
  final bool isOwner;

  const PostListItem({super.key, required this.post, required this.isOwner});

  Future<void> _deletePost(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await PostService.deletePost(post);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => DetailScreen(post: post)));
        },
        leading: post.image != null && post.image!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(post.image!),
                  width: 135,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 56),
                ),
              )
            : const Icon(Icons.article, size: 56),
        title: Text(
          post.name ?? post.category ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.category ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              post.userFullName ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner) ...[
              IconButton(
                onPressed: () async {
                  // Navigate to AddPostScreen in admin mode passing the post for editing
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddPostScreen(isAdmin: true, gedungSerbaguna: post),
                    ),
                  );
                  // If edited, optional: StreamBuilder in parent akan otomatis refresh jika data berubah.
                },
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _deletePost(context),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
