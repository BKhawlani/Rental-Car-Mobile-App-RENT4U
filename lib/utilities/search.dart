import 'package:flutter/material.dart';
import 'package:rental_car_project/screen/home_page.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  final List<Car> carList;
  final String query;
  const SearchScreen({required this.query, required this.carList});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<Car> filteredCars; // قائمة السيارات بعد الفلترة

  @override
  void initState() {
    super.initState();
    filteredCars = widget.carList; // بدايةً نعرض كل السيارات
    filterCars(); // نفلتر السيارات عند تحميل الصفحة
  }

  void filterCars() {
    final regex = RegExp(
      widget.query,
      caseSensitive: false,
    ); // نستخدم تعبير عادي للبحث
    setState(() {
      filteredCars =
          widget.carList.where((car) {
            // الفلترة بناءً على نص البحث
            return regex.hasMatch(car.brand) || regex.hasMatch(car.model);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double paddingHorizontal = screenWidth * 0.05;
    double verticalSpacing = screenHeight * 0.025;
    double ButtonField = screenHeight * 0.06;
    double fontSizeTitle = screenWidth * 0.06;
    double fontSizeSubtitle = screenWidth * 0.04;
    return Container(
      child: Column(
        children: [
          if (widget.query.isEmpty) ...[
            HomePage(),
          ] else ...[
            Text('Search Results for: ${widget.query}'),
            for (int i = 0; i < filteredCars.length; i++)
              MaterialButton(
                onPressed: () {},
                child: Container(
                  width: screenWidth * 0.9,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color.fromARGB(255, 36, 14, 144),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        filteredCars[i].image,
                        fit: BoxFit.cover,
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.1,
                      ),
                    ),
                    title: Text(
                      "${filteredCars[i].brand} ${filteredCars[i].model}",
                      style: GoogleFonts.outfit(
                        fontSize: fontSizeSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "\$${filteredCars[i].price} / day",
                      style: GoogleFonts.outfit(
                        fontSize: fontSizeSubtitle - 2,
                        color: Color.fromARGB(255, 36, 14, 144),
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      print("Car ID: ${filteredCars[i].id}");
                    }, // Add your onTap action here
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
