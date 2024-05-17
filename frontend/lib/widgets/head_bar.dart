import 'package:flutter/material.dart';

class HeadBar extends StatelessWidget implements PreferredSizeWidget {
  final Text title;
  final AppBar appBar;
  final Widget? navPage;

  const HeadBar({super.key, required this.title, required this.appBar, this.navPage});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'headBar',
      child: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _handleNavigation(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed("/setting");
            },
          )
        ],
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: title,
      ),
    );
  }

  void _handleNavigation(BuildContext context) {
    if (navPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => navPage!),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
