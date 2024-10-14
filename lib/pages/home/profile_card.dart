import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  _ProfileCardState();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(SideDrawerKeys.PROFILE),
      onTap: () {
        context.go('/profile');
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return UserAccountsDrawerHeader(
              accountName: Text(state.profile.name),
              accountEmail: Text(state.profile.email),
              otherAccountsPictures: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.info,
                      color: Colors.white,
                      size: 36.0,
                    ),
                    onPressed: () async {
                      context.go('/about');
                    })
              ],
              currentAccountPicture: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: _buildAvatarWidget(state.profile.avatarUrl),
              ),
            );
          }

          return UserAccountsDrawerHeader(
            accountName: Text("Agnimon Frontier"),
            accountEmail: Text("AgnimonFrontier@gmail.com"),
            otherAccountsPictures: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    context.go('/about');
                  })
            ],
            currentAccountPicture: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: AssetImage("assets/Agnimon.jpg"),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildAvatarWidget(String avatarUrl) {
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(avatarUrl),
          ),
        ),
      );
    } else if (avatarUrl.startsWith("assets/")) {
      return CircleAvatar(
        radius: 75,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: AssetImage(avatarUrl),
      );
    } else {
      var file = File(avatarUrl);
      var fileImage = FileImage(file);
      return CircleAvatar(
        radius: 75,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: fileImage,
      );
    }
  }
}
