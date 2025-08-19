import 'package:ecoroute/notificationPage.dart';
import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final String logoPath;
  final Color iconColor;
  final Color searchBgColor;
  final bool showSearch;

  const SearchHeader({
    super.key,
    this.logoPath = 'images/logo-green.png',
    this.iconColor = Colors.white,
    this.searchBgColor = const Color(0xFF143D15),
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 0,
          top: 15,
        ),
        child: Row(
          children: [
            Image.asset(logoPath, height: 45),
            const SizedBox(width: 10),
            if (showSearch)
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color:
                        ThemeData.estimateBrightnessForColor(searchBgColor) ==
                            Brightness.dark
                        ? Colors.white
                        : Color(0xFF011901),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Find A Tourist Spot',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 111, 143, 112),
                      fontSize: 14,
                      fontWeight: FontWeight.w100,
                    ),
                    filled: true,
                    fillColor: searchBgColor,
                    prefixIcon: Icon(Icons.search, color: iconColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              )
            else
              Spacer(),
            const SizedBox(width: 10),

            IconButton(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: iconColor,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
