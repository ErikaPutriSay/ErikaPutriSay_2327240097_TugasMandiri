import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:informasigedungserbaguna/models/post.dart';
import 'package:informasigedungserbaguna/providers/app_provider.dart';
import 'package:informasigedungserbaguna/screens/detail_screen.dart';
import 'package:informasigedungserbaguna/services/favorite_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isEnglish = appProvider.locale.languageCode == 'en';
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEnglish
              ? 'Favorite Multipurpose Halls'
              : 'Gedung Serbaguna Favorit',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: currentUser == null
          ? Center(
              child: Text(
                isEnglish
                    ? 'Please sign in first to view favorites.'
                    : 'Silakan login terlebih dahulu untuk melihat favorit.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          : StreamBuilder<List<Post>>(
              stream: FavoriteService.getFavoritePosts(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      isEnglish
                          ? 'An error occurred: ${snapshot.error}'
                          : 'Terjadi kesalahan: ${snapshot.error}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                }

                final favoritePosts = snapshot.data ?? [];
                if (favoritePosts.isEmpty) {
                  return Center(
                    child: Text(
                      isEnglish
                          ? 'No favorite multipurpose halls yet. Add one from the detail page.'
                          : 'Belum ada gedung serbaguna favorit. Tambahkan dari halaman detail.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: favoritePosts.length,
                  itemBuilder: (context, index) {
                    final post = favoritePosts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(post: post),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.image != null && post.image!.isNotEmpty)
                              Image.memory(
                                base64Decode(post.image!),
                                width: double.infinity,
                                height: 170,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 170,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 170,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(
                                    Icons.storefront,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.name ?? 'Gedung Serbaguna',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    post.operationalHours ??
                                        'Jam operasional belum tersedia',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
