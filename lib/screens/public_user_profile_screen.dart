import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/user.dart';
import '../models/user_seal.dart';
import '../models/trail_record.dart';
import '../providers/auth_provider.dart';
import '../utils/translations.dart';

class PublicUserProfileScreen extends StatefulWidget {
  final String userId;

  const PublicUserProfileScreen({super.key, required this.userId});

  @override
  State<PublicUserProfileScreen> createState() => _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen> {
  bool _isFollowing = false;
  bool _isLoadingFollow = false;
  bool _initializedFollow = false;

  Future<void> _ensureFollowState(User profileUser) async {
    if (_initializedFollow || !mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    if (currentUser == null || currentUser.id == profileUser.id) {
      setState(() {
        _initializedFollow = true;
      });
      return;
    }

    try {
      final isFollowing = await FirebaseService.isFollowing(currentUser.id, profileUser.id);
      if (!mounted) return;
      setState(() {
        _isFollowing = isFollowing;
        _initializedFollow = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializedFollow = true;
      });
    }
  }

  Future<void> _toggleFollow(User profileUser) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    if (currentUser == null || currentUser.id == profileUser.id) {
      return;
    }
    if (_isLoadingFollow) return;

    setState(() {
      _isLoadingFollow = true;
    });

    final wasFollowing = _isFollowing;
    try {
      if (wasFollowing) {
        await FirebaseService.unfollowUser(
          currentUserId: currentUser.id,
          targetUserId: profileUser.id,
        );
      } else {
        await FirebaseService.followUser(
          currentUserId: currentUser.id,
          targetUserId: profileUser.id,
        );
      }

      if (!mounted) return;
      setState(() {
        _isFollowing = !wasFollowing;
        _isLoadingFollow = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingFollow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.getText(context, 'profile')), // Reaproveita chave existente
      ),
      body: FutureBuilder<User?>(
        future: FirebaseService.getUserData(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  Translations.getText(context, 'leaderboardError'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  Translations.getText(context, 'noUserLoggedIn'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (user != null) {
              _ensureFollowState(user);
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.green.shade100,
                          backgroundImage:
                              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null
                              ? Text(
                                  _getInitials(user.name ?? user.email),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.group,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.followersCount} ${Translations.getText(context, 'followers')} • ${user.followingCount} ${Translations.getText(context, 'following')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildFollowButton(context, user),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translations.getText(context, 'statistics'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              Icons.star,
                              Translations.getText(context, 'reviews'),
                              user.totalReviews.toString(),
                            ),
                            _buildStatItem(
                              context,
                              Icons.group,
                              Translations.getText(context, 'followers'),
                              user.followersCount.toString(),
                            ),
                            _buildStatItem(
                              context,
                              Icons.person_add,
                              Translations.getText(context, 'following'),
                              user.followingCount.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translations.getText(context, 'trailHistoryTitle'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<TrailRecord>>(
                          future: FirebaseService.getUserTrailRecords(user.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Text(
                                Translations.getText(context, 'trailHistoryEmpty'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            }

                            final trails = snapshot.data ?? [];
                            if (trails.isEmpty) {
                              return Text(
                                Translations.getText(context, 'trailHistoryEmpty'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            }

                            return Column(
                              children: trails.take(5).map((trail) {
                                final dateText = DateFormat('dd/MM/yyyy HH:mm').format(trail.createdAt);
                                final subtitle = trail.address?.isNotEmpty == true
                                    ? '${trail.address} · $dateText'
                                    : dateText;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade50,
                                    child: Icon(
                                      Icons.directions_walk,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  title: Text(
                                    trail.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.green.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(BuildContext context, User profileUser) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    if (currentUser == null || currentUser.id == profileUser.id) {
      return const SizedBox.shrink();
    }

    final labelKey = _isFollowing ? 'followingVerb' : 'follow';

    return OutlinedButton.icon(
      onPressed: _isLoadingFollow ? null : () => _toggleFollow(profileUser),
      icon: _isLoadingFollow
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isFollowing ? Icons.person : Icons.person_add,
              size: 16,
            ),
      label: Text(
        Translations.getText(context, labelKey),
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide(color: Colors.green.shade400),
        foregroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  String _getInitials(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
