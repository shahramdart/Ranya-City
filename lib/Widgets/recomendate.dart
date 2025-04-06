import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:ranyacity/Models/travels_model.dart';

class Recomendate extends StatelessWidget {
  final TravelDestination destination;
  const Recomendate({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Row(
        children: [
          Container(
            height: 95,
            width: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  destination.imageUrls![0],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  destination.category,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 16,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        destination.namePlace,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Ensures that the text doesn't overflow
                        maxLines:
                            1, // Makes sure the text stays on a single line
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconlyLight.arrow_left_2,
                size: 30,
                color: Colors.grey.shade400,
              ),
            ],
          )
        ],
      ),
    );
  }
}
