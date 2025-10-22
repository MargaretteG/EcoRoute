import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/bottomPopup.dart';
import 'package:ecoroute/widgets/feedback.dart';
import 'package:ecoroute/widgets/menu_forRestaurant.dart';
import 'package:ecoroute/widgets/packages_forHotel.dart';
import 'package:ecoroute/widgets/reviews.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DestinationInfoPage extends StatefulWidget {
  final String imagePath;
  final String name;
  final String location;
  final String description;
  final String openingHoursWeekdays;
  final String openingHoursWeekends;
  final String contact;
  final String email;
  final String highlights;
  final String category;
  final int ecoRating;
  final double starRating;
  final int establishmentId;
  final int userId;
  final bool isFavorite;

  const DestinationInfoPage({
    super.key,
    this.imagePath = '',
    this.name = '',
    this.location = '',
    this.description = '',
    this.openingHoursWeekdays = '',
    this.openingHoursWeekends = '',
    this.contact = '',
    this.email = '',
    this.highlights = '',
    this.category = '',
    this.ecoRating = 0,
    this.starRating = 0.0,
    this.establishmentId = 0,
    this.userId = 0,
    this.isFavorite = false,
  });

  @override
  State<DestinationInfoPage> createState() => _DestinationInfoPageState();
}

class _DestinationInfoPageState extends State<DestinationInfoPage> {
  bool isFavorite = false;
  bool _isExpandeddesc = false;
  bool _isExpanded = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  Color _getEcoColor(int ecoRating) {
    switch (ecoRating) {
      case 1:
        return const Color.fromARGB(255, 0, 123, 223);
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      case 4:
        return const Color.fromARGB(255, 216, 195, 0);
      case 5:
        return const Color.fromARGB(255, 0, 215, 7);
      default:
        return const Color.fromARGB(255, 119, 119, 119);
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case "church":
        return Icons.church;
      case "cultural cite":
        return Icons.museum;
      case "restaurant":
        return Icons.restaurant;
      case "hotel":
        return Icons.hotel;
      case "amusement park":
        return Icons.park;
      case "eco parks":
        return Icons.local_activity;
      case "local market":
        return Icons.storefront;
      default:
        return Icons.place; // fallback
    }
  }

  late final List<Map<String, String>> images = [
    {
      "image": widget.imagePath,
      "desc": "This is the main view of the destination.",
    },
    {
      "image": "images/tourist-spot2.jpg",
      "desc": "Another angle showcasing the surrounding nature.",
    },
    {
      "image": "images/tagaytay-bg-1.jpg",
      // No description for this one
    },
  ];

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  //Heart Icon
  Future<void> _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite; // update UI immediately
    });

    try {
      await addOrUpdateFavorite(
        userId: widget.userId,
        establishment_id: widget.establishmentId,
        favoriteStatus: isFavorite ? 1 : 0,
      );
    } catch (e) {
      // revert if API call fails
      setState(() {
        isFavorite = !isFavorite;
      });
      debugPrint("Failed to update favorite: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getEcoColor(widget.ecoRating),

      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            physics: const ClampingScrollPhysics(),
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                backgroundColor: const Color(0xFF011901),
                expandedHeight: 300,
                pinned: true,

                title: Padding(
                  padding: EdgeInsetsGeometry.only(
                    bottom: 5,
                    left: 50,
                    right: 50,
                  ),
                  child: Flexible(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                        height: 1,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // PageView for scrolling images
                        GestureDetector(
                          onHorizontalDragUpdate: (_) {},
                          child: Transform.scale(
                            scale:
                                1 +
                                (_scrollOffset > 0 ? _scrollOffset / 300 : 0),
                            child: Opacity(
                              opacity: (_scrollOffset < 0)
                                  ? 1.0
                                  : (_scrollOffset > 150)
                                  ? 0.0
                                  : 1 - (_scrollOffset / 150),
                              child: PageView.builder(
                                controller: _pageController,
                                physics: const PageScrollPhysics(),
                                onPageChanged: (index) {
                                  setState(() => _currentPage = index);
                                },
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  final imagePath = images[index]["image"]!;

                                  // Only the first image comes from network, rest are local assets
                                  if (index == 0) {
                                    return Image.network(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    );
                                  } else {
                                    return Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                end: Alignment.topCenter,
                                begin: Alignment.bottomCenter,
                                colors: [
                                  _getEcoColor(widget.ecoRating),
                                  _getEcoColor(
                                    widget.ecoRating,
                                  ).withOpacity(0.0),
                                ],

                                stops: [0.03, 0.15],
                              ),
                            ),
                          ),
                        ),

                        // Dots indicator
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentPage == index ? 10 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Contents
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_scrollOffset < 20 ? 30 : 0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                          ),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 8,
                                        child: Text(
                                          widget.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                            fontSize: 20,
                                            height: 1,
                                          ),
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2, // 20%
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[200],
                                            ),
                                            child: Icon(
                                              _getCategoryIcon(widget.category),
                                              color: _getEcoColor(
                                                widget.ecoRating,
                                              ),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsetsGeometry.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        widget.location,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(207, 0, 0, 0),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsetsGeometry.symmetric(
                                            horizontal: 9,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Icon(
                                                Icons.navigate_next_rounded,
                                                color: Colors.black87,
                                                size: 27,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Divider(
                                color: Colors.grey,
                                thickness: 0.7,
                                indent: 0,
                                endIndent: 0,
                              ),
                              SizedBox(height: 5),
                              //Ratings
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        width: 1,
                                        color: _getEcoColor(
                                          widget.ecoRating,
                                        ).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsGeometry.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            widget.starRating.toString(),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color.fromARGB(
                                                155,
                                                0,
                                                0,
                                                0,
                                              ),
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          if (widget.ecoRating > 0)
                                            Icon(
                                              Icons.star,
                                              size: 15,
                                              color: Colors.amber,
                                            ),
                                          if (widget.ecoRating == 0)
                                            Row(
                                              children: List.generate(5, (
                                                index,
                                              ) {
                                                if (index <
                                                    widget.starRating.floor()) {
                                                  return const Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: Colors.amber,
                                                  );
                                                } else if (index <
                                                        widget.starRating &&
                                                    widget.starRating % 1 !=
                                                        0) {
                                                  return const Icon(
                                                    Icons.star_half,
                                                    size: 14,
                                                    color: Colors.amber,
                                                  );
                                                } else {
                                                  return const Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  );
                                                }
                                              }),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (widget.ecoRating > 0)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: _getEcoColor(
                                          widget.ecoRating,
                                        ).withOpacity(0.25),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsGeometry.symmetric(
                                          horizontal: 11,
                                          vertical: 6,
                                        ),

                                        child: Row(
                                          children: [
                                            Text(
                                              widget.ecoRating.toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                  155,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(width: 2),

                                            Row(
                                              children: List.generate(
                                                5,
                                                (index) => Icon(
                                                  Icons.eco,
                                                  size: 15,
                                                  color:
                                                      index < widget.ecoRating
                                                      ? const Color.fromARGB(
                                                          255,
                                                          1,
                                                          142,
                                                          24,
                                                        )
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Spacer(),
                                  GestureDetector(
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        Icons.info_outline,
                                        color: _getEcoColor(widget.ecoRating),
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Contact Info
                              SizedBox(height: 9),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_rounded,
                                        size: 15,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          widget.contact,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                            height: 1,
                                          ),
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget.email != null &&
                                      widget.email!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email_rounded,
                                          size: 15,
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            widget.email!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                              height: 1,
                                            ),
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 27),

                              // Description
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Vertical line
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Color(0xFF64F67A),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                  ),

                                  // Subtitle text
                                  Text(
                                    "Description",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF011901),
                                    ),
                                  ),
                                ],
                              ),

                              // Description
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      242,
                                      224,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 0.3,
                                        blurRadius: 6,
                                        offset: const Offset(2, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.description,
                                          maxLines: _isExpandeddesc ? null : 5,
                                          overflow: _isExpandeddesc
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),

                                        // "See more / See less"
                                        if (widget.description
                                                    .split('\n')
                                                    .length >
                                                5 ||
                                            widget.description.length >
                                                150) // simple check for overflow
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isExpandeddesc =
                                                    !_isExpandeddesc;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Text(
                                                _isExpandeddesc
                                                    ? "See less"
                                                    : "See more",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              // Opening Hours
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Vertical line
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Color(0xFF64F67A),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                  ),

                                  // Subtitle text
                                  Text(
                                    "Opening Hours",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF011901),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // border: Border.all(
                                        //   width: 1.5,
                                        //   color: Color.fromARGB(53, 6, 166, 0),
                                        // ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            spreadRadius: 0.3,
                                            blurRadius: 6,
                                            offset: const Offset(2, 3),
                                          ),
                                        ],
                                        color: Color.fromARGB(
                                          255,
                                          230,
                                          255,
                                          229,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Weekdays",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              widget.openingHoursWeekdays,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                                height: 1,
                                              ),
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            spreadRadius: 0.3,
                                            blurRadius: 6,
                                            offset: const Offset(2, 3),
                                          ),
                                        ],
                                        color: Color.fromARGB(
                                          255,
                                          230,
                                          255,
                                          229,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Weekends",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              widget.openingHoursWeekends,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                                height: 1,
                                              ),
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        // for Restaurant
                        if (widget.category == 'Restaurant')
                          Column(
                            children: [
                              SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsetsGeometry.only(left: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Vertical line
                                        Container(
                                          width: 4,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            color: Color(0xFF64F67A),
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                        ),

                                        // Subtitle text
                                        Text(
                                          "Menu Preview",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF011901),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ), // remove side padding
                                child: const Menu(),
                              ),
                            ],
                          ),

                        if (widget.category == 'Hotel')
                          Column(
                            children: [
                              SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsetsGeometry.only(left: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Vertical line
                                        Container(
                                          width: 4,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            color: Color(0xFF64F67A),
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                        ),

                                        // Subtitle text
                                        Text(
                                          "Room Types Preview",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF011901),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ), // remove side padding
                                child: const HotelPackage(),
                              ),
                            ],
                          ),

                        //Highlights
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Vertical line
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Color(0xFF64F67A),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                  ),

                                  // Subtitle text
                                  Text(
                                    "Highlights",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF011901),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ), // outer padding
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      242,
                                      224,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 0.3,
                                        blurRadius: 6,
                                        offset: const Offset(2, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.highlights,
                                          maxLines: _isExpanded ? null : 2,
                                          overflow: _isExpanded
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),

                                        // "See more / See less"
                                        if (widget.highlights
                                                    .split('\n')
                                                    .length >
                                                2 ||
                                            widget.highlights.length >
                                                100) // simple check for overflow
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isExpanded = !_isExpanded;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Text(
                                                _isExpanded
                                                    ? "See less"
                                                    : "See more",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(images.length, (index) {
                                  final item = images[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image container
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: SizedBox(
                                              height: 150,
                                              width: double.infinity,
                                              child: index == 0
                                                  ? Image.network(
                                                      item["image"]!,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          },
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 50,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                    )
                                                  : Image.asset(
                                                      item["image"]!,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Description container
                                      if (item["desc"] != null &&
                                          item["desc"]!.isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(
                                            bottom: 9,
                                            top: 4,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .keyboard_double_arrow_up_rounded,
                                                size: 20,
                                                color: Color.fromARGB(
                                                  211,
                                                  69,
                                                  69,
                                                  69,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  item["desc"]!,
                                                  textAlign: TextAlign.justify,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color.fromARGB(
                                                      211,
                                                      69,
                                                      69,
                                                      69,
                                                    ),
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),

                              const SizedBox(height: 25),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Vertical line
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Color(0xFF64F67A),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                  ),

                                  // Subtitle text
                                  Flexible(
                                    child: Text(
                                      "${widget.name} FAQ",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF011901),
                                        height: 1,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 7),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors
                                        .transparent, // makes the sheet bg transparent
                                    barrierColor: const Color.fromARGB(
                                      217,
                                      0,
                                      0,
                                      0,
                                    ),
                                    isDismissible: true,

                                    builder: (_) {
                                      return BottomPopup(
                                        name: widget.name,
                                        category: widget.category,
                                        faqs: [
                                          "What are the opening hours?",
                                          "Do you offer guided tours?",
                                          "Is parking available?",
                                          "Are pets allowed?",
                                          "Do you offer guided tours?",
                                        ],
                                        faqsAnswers: [
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ",
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ",
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ",
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ",
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ",
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ",
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ",
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "FAQs about this ${widget.category}.",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w100,
                                          color: Color(0xFF011901),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.help_outline_rounded,
                                        color: Color(0xFF011901),
                                        size: 26,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),
                              //Feedback Section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Vertical line
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Color(0xFF64F67A),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                  ),

                                  // Subtitle text
                                  Text(
                                    "Leave a feedback",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF011901),
                                    ),
                                  ),
                                ],
                              ),

                              LeaveFeedbackSection(
                                accountId: widget.userId,
                                establishmentId: widget.establishmentId,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        //Reviews Section
                        TravelerReviews(
                          establishmentId: widget.establishmentId,
                        ),

                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Back + Heart buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color.fromARGB(145, 230, 230, 230),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                // Heart button
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: isFavorite ? 15 : 0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, glow, child) {
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color.fromARGB(
                          145,
                          230,
                          230,
                          230,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                          shadows: isFavorite
                              ? [
                                  Shadow(
                                    color: Colors.red.withOpacity(0.8),
                                    blurRadius: glow,
                                  ),
                                ]
                              : [],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
