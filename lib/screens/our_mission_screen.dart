import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';

class OurMissionScreen extends StatelessWidget {
  const OurMissionScreen({Key? key});
  static const routeName = '/our-mission';

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Mission, Vision, and Goals',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.all(9.0),
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade50,
                          Colors.orange.shade200,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: const [
                          Icon(Icons.explore, color: Colors.orange),
                          SizedBox(width: 60.0),
                          Text(
                            'Our Mission',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        const SizedBox(height: 5.0),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                          child: const Text(
                            'To provide a seamless and hassle-free online bus booking experience for our customers.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade50,
                          Colors.orange.shade200,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: const [
                          Icon(Icons.visibility, color: Colors.orange),
                          SizedBox(width: 60.0),
                          Text(
                            'Our Vision',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        const SizedBox(height: 10.0),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                          child: const Text(
                            'To become the go-to platform for bus booking, by offering the widest range of options and exceptional customer service.',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade50,
                          Colors.orange.shade200,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: const [
                          Icon(Icons.check_circle_outline,
                              color: Colors.orange),
                          SizedBox(width: 60.0),
                          Text(
                            'Our Goals',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        const SizedBox(height: 10.0),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                          child: const Text(
                            '1. To partner with the largest network of bus operators in the country.\n\n'
                            '2. To provide a user-friendly interface that is easy to navigate.\n\n'
                            '3. To offer competitive pricing and discounts to our customers.\n\n'
                            '4. To ensure customer satisfaction by providing prompt and reliable service.\n\n'
                            '5. To continuously innovate and improve our platform to meet the changing needs of our customers.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
