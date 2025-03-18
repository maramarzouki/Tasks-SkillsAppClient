import 'package:flutter/material.dart';

class SearchbarWidget extends StatelessWidget {
  const SearchbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          color: Color(0xff2A3143),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10))),
      child: TextField(
        // controller: _searchController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Optionally trigger the callback again when icon is pressed
              // widget.onSearchChanged(_searchController.text.trim());
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ),
    );
  }
}
