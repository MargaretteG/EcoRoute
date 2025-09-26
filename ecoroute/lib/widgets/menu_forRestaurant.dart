import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool _isExpanded = false;
  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Grilled Salmon",
      "image": "images/promo-delicacy.png",
      "price": 250.00,
    },
    {
      "name": "Cheese Burger",
      "image": "images/promo-delicacy.png",
      "price": 180.00,
    },
    {
      "name": "Spaghetti Bolognese with Parmesan Cheese",
      "image": "images/promo-delicacy.png",
      "price": 200.00,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final item = menuItems[index];

          return Container(
            width: 180,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dish image inside a circle
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(item["image"]),
                  ),
                ),
                const SizedBox(height: 12),

                // Dish name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish name (scrollable if too long)
                    if (item["name"].length > 2)
                      Column(
                        children: [
                          SizedBox(
                            height: 28,
                            child: SingleChildScrollView(
                              child: Text(
                                item["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.8,
                                  color: Colors.black87,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                        ],
                      )
                    else
                      SizedBox(
                        height: 17,
                        child: Text(
                          item["name"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                      ),

                    // Price
                    Text(
                      "₱${item["price"].toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
