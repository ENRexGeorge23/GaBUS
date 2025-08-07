import 'package:flutter/material.dart';

class CarouselCard extends StatefulWidget {
  @override
  _CarouselCardState createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  PageController _pageController = PageController(viewportFraction: 0.5);

  int _currentPage = 0;
  final List<String> _cardTitles = [
    'Oslob',
    'Moalboal',
    'Ginatilan',
    'Sibonga',
    'Dalaguete',
  ];
  final List<String> _cardImages = [
    'assets/images/oslob.jpg',
    'assets/images/moalboal.jpg',
    'assets/images/ginatilan.jpg',
    'assets/images/simala.jpg',
    'assets/images/dalaguete.jpg',
  ];
  final List<String> _cardDescriptions = [
    'Oslob is a coastal town in the Philippines known for its whale shark watching activity and explore historic landmarks..',
    'Moalboal is a small town popular for its stunning beaches and world-renowned diving spots.',
    'Ginatilan known for its picturesque waterfalls, historic church, and traditional handicrafts.',
    'Sibonga famous for its centuries-old church, colorful festivals, and scenic rice terraces.',
    'Dalaguete is a scenic town known for its towering mountain peaks, cool climate, and delicious local delicacies.',
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
        initialPage: 0,
        viewportFraction: 1.0); // Set the initial page to the middle page
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _cardTitles.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      height: isActive ? 8 : 6,
      width: isActive ? 12 : 6,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.orange : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _cardTitles.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          _cardImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 135, 0, 0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black26, Colors.black87],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _cardTitles[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _cardDescriptions[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
