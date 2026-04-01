import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherSafetypage extends StatefulWidget {
  const WeatherSafetypage({super.key});

  @override
  State<WeatherSafetypage> createState() => _WeatherSafetyState();
}

class _WeatherSafetyState extends State<WeatherSafetypage> {
  double? _temp;
  double? _wind;
  double? _visibility;
  double? _waveHeight;
  String? _highTide, _lowTide, _sunrise, _sunset, _lastUpdated = "";
  bool _weatherLoaded = false;

  Future<void> _getWeather() async {
    Position position = await Geolocator.getCurrentPosition();
    final response = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=00267594af2060e6f2b24e9db3d63478&units=metric",
      ),
    );
    final response1 = await http.get(
      Uri.parse(
        "https://marine-api.open-meteo.com/v1/marine?latitude=${position.latitude}&longitude=${position.longitude}&current=wave_height",
      ),
    );
    final response2 = await http.get(
      Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&daily=sunrise,sunset&timezone=auto",
      ),
    );

    final response3 = await http.get(
      Uri.parse(
        "https://api.stormglass.io/v2/tide/extremes/point?lat=${position.latitude}&&lng=${position.longitude}&type=high,low",
      ),
    );


    final data = jsonDecode(response.body);
    final data1 = jsonDecode(response1.body);
    final data2 = jsonDecode(response2.body);
    final data3 = jsonDecode(response3.body);

    setState(() {
      _temp = data["main"]["temp"];
      _wind = data["wind"]["speed"];
      _visibility = data["visibility"] / 1000;
      _waveHeight = data1["current"]["wave_height"];
      _sunrise = data2["daily"]["sunrise"][0];
      _sunset = data2["daily"]["sunset"][0];
      _highTide = data3["data"][0]["high"];
      _lowTide = data3["data"][0]["low"];
      _lastUpdated = DateTime.now().toString();
      bool _weatherLoaded = true;
    });
  }

  String _getUpdatedTime() {
    if (_lastUpdated!.isEmpty) return "...";

    final lastTime = DateTime.parse(_lastUpdated!);
    final difference = DateTime.now().difference(lastTime);

    if (difference.inMinutes < 1) {
      return "Updated just now";
    } else if (difference.inMinutes < 60) {
      return "Updated ${difference.inMinutes}m ago";
    } else {
      return "Updated ${difference.inHours}h ago";
    }
  }

  @override
  void initState() {
    super.initState();
    _getWeather();
    _getUpdatedTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back),
          color: Color(0xFF0F172A),
        ),
        title: Text(
          "Weather & Safety",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.6,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CURRENT WEATHER",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.7,
                  ),
                ),
                Text(
                  _getUpdatedTime(),
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
            Block(),
            Column(
              spacing: 12,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: WeatherInfo(
                        title: "temp",
                        value: "${_temp}°C",
                        icon1: Icons.thermostat,
                      ),
                    ),
                    Expanded(
                      child: WeatherInfo(
                        title: "wind",
                        value: "${_wind}m/s",
                        icon1: Icons.air_outlined,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: WeatherInfo(
                        title: "waves",
                        value: "188m",
                        icon1: Icons.waves,
                      ),
                    ),
                    Expanded(
                      child: WeatherInfo(
                        title: "visibility",
                        value: "${_visibility}km",
                        icon1: Icons.visibility,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Block(),
            Text(
              "Navigation Map",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: -0.55,
              ),
            ),
            Block(),
            SizedBox(height: 336),
            Block(),
            Container(
              padding: EdgeInsetsGeometry.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadiusGeometry.circular(13),
                border: BoxBorder.all(color: Color(0xFFE2E8F0), width: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_gas_station_outlined,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Full level",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          Text(
                            "75",
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "%",
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  LinearPercentIndicator(
                    percent: 0.75,
                    lineHeight: 10,
                    backgroundColor: Color(0xFFF1F5F9),
                    progressColor: Color(0xFF033F78),
                    barRadius: Radius.circular(5),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Block(),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {_getWeather();},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsetsGeometry.all(16),
                        backgroundColor: Color(0xFFDC2626),
                        foregroundColor: Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(13),
                        ),
                        alignment: AlignmentGeometry.center,
                        shadowColor: Color(0xFFDC2626),
                        elevation: 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "SOS",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "EMERGENCY SOS",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    spacing: 10,
                    children: [
                      Container(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsetsGeometry.all(10),
                            backgroundColor: Color(0xFF0F172A),
                            foregroundColor: Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(13),
                            ),
                            alignment: AlignmentGeometry.center,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.navigation_outlined,
                                size: 30,
                                color: Color(0xFF033F78),
                              ),
                              Text(
                                "Navigate to\nPort",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsetsGeometry.all(10),
                            backgroundColor: Color(0xFFFFFFFF),
                            foregroundColor: Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(13),
                            ),
                            alignment: AlignmentGeometry.center,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.bookmark_border_outlined,
                                size: 30,
                                color: Color(0xFF033F78),
                              ),
                              Text(
                                "Save \nLocation",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Block(),
            Row(
              spacing: 5,
              children: [
                Expanded(child: Cardinfo(Color(0xFF033F78),Icons.waves_outlined,"TIDE\nTIME","High","07:30","Low","14:45")),
                Expanded(child: Cardinfo(Color(0xFFF97316),Icons.wb_sunny_outlined,"DAILY\nGHT","RISE","${_sunrise!.substring(11,16)}","SET","${_sunset!.substring(11,16)}")),
              ],
            )

          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 20);
  }
}

class WeatherInfo extends StatelessWidget {
  final String? title;
  final String? value;
  final IconData? icon1;
  const WeatherInfo({super.key, this.title, this.value, this.icon1});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadiusGeometry.circular(13),
        border: BoxBorder.all(color: Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Column(
        spacing: 5,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon1, color: Color(0xFF033F78)),
              SizedBox(width: 5),
              Text(
                "$title",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$value",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Color(0xFFA8A8A8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildBottomNavBar() {
  return Container(
    margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(35),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.home_outlined, color: Colors.grey),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.anchor, color: Colors.grey),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.shopping_basket_outlined, color: Colors.grey),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person, color: Color(0xFF013D73), size: 30),
        ),
      ],
    ),
  );
}

Widget Cardinfo(Color color,IconData icon, String title, String info1, String value1, String info2, String value2,){
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Color(0xFFF8FAFC),
      borderRadius: BorderRadiusGeometry.circular(13),
      border: BoxBorder.all(color: Color(0xFFE2E8F0), width: 0.5),
    ),
    child: Column(
      spacing: 5,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(icon,color: color,size: 15,),
            Text(title,style: TextStyle(
              color: Color(0xFF64748B),
              fontFamily: "Inter",
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),)
          ],
        ),
        Row(
          children: [
            Text(info1,style: TextStyle(
              color: Color(0xFF64748B),
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),),
            Spacer(),
            Text("$value1 AM",style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: "Inter",
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),),
          ],
        ),
        Row(
          children: [
            Text(info2,style: TextStyle(
              color: Color(0xFF64748B),
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),),
            Spacer(),
            Text("$value2 PM",style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: "Inter",
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),),
          ],
        )
      ],
    ),



  );


}




// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class WeatherSafetypage extends StatefulWidget {
//   const WeatherSafetypage({super.key});
//
//   @override
//   State<WeatherSafetypage> createState() => _WeatherSafetyState();
// }
//
// class _WeatherSafetyState extends State<WeatherSafetypage> {
//   double? _temp;
//   double? _wind;
//   double? _visibility;
//   double? _waveHeight;
//   String? _highTide, _lowTide, _sunrise, _sunset, _lastUpdated = "";
//   bool _isLoading = true; // Ajout d'un état de chargement
//
//   @override
//   void initState() {
//     super.initState();
//     _getWeather();
//   }
//
//   Future<void> _getWeather() async {
//     try {
//       setState(() => _isLoading = true);
//
//       // Vérification des permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       Position position = await Geolocator.getCurrentPosition();
//
//       // Appels API
//       final response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=00267594af2060e6f2b24e9db3d63478&units=metric"));
//       final response1 = await http.get(Uri.parse("https://marine-api.open-meteo.com/v1/marine?latitude=${position.latitude}&longitude=${position.longitude}&current=wave_height"));
//       final response2 = await http.get(Uri.parse("https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&daily=sunrise,sunset&timezone=auto"));
//
//       final data = jsonDecode(response.body);
//       final data1 = jsonDecode(response1.body);
//       final data2 = jsonDecode(response2.body);
//
//       setState(() {
//         _temp = data["main"]["temp"];
//         _wind = data["wind"]["speed"];
//         _visibility = (data["visibility"] as int) / 1000;
//         _waveHeight = data1["current"]["wave_height"];
//         _sunrise = data2["daily"]["sunrise"][0];
//         _sunset = data2["daily"]["sunset"][0];
//         _lastUpdated = DateTime.now().toString();
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Error fetching weather: $e");
//       setState(() => _isLoading = false);
//     }
//   }
//
//   String _getUpdatedTime() {
//     if (_lastUpdated == null || _lastUpdated!.isEmpty) return "...";
//     final lastTime = DateTime.parse(_lastUpdated!);
//     final difference = DateTime.now().difference(lastTime);
//     if (difference.inMinutes < 1) return "Updated just now";
//     return "Updated ${difference.inMinutes}m ago";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7F9),
//       appBar: AppBar(
//         leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), color: const Color(0xFF0F172A)),
//         title: const Text("Weather & Safety", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: _isLoading
//         ? const Center(child: CircularProgressIndicator()) // Affiche un loader pendant le chargement
//         : SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text("CURRENT WEATHER", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
//                     Text(_getUpdatedTime(), style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 _buildWeatherGrid(),
//                 const SizedBox(height: 24),
//                 const Text("Fuel level", style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 _buildFuelIndicator(),
//                 const SizedBox(height: 32),
//                 _buildActionButtons(),
//                 const SizedBox(height: 24),
//                 _buildSunInfo(),
//               ],
//             ),
//           ),
//     );
//   }
//
//   Widget _buildWeatherGrid() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(child: WeatherInfo(title: "Temp", value: "${_temp?.toStringAsFixed(1)}°C", icon1: Icons.thermostat)),
//             const SizedBox(width: 12),
//             Expanded(child: WeatherInfo(title: "Wind", value: "${_wind?.toStringAsFixed(1)} m/s", icon1: Icons.air)),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: WeatherInfo(title: "Waves", value: "${_waveHeight?.toStringAsFixed(1)}m", icon1: Icons.waves)),
//             const SizedBox(width: 12),
//             Expanded(child: WeatherInfo(title: "Visibility", value: "${_visibility?.toStringAsFixed(1)}km", icon1: Icons.visibility)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFuelIndicator() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE2E8F0))),
//       child: Column(
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.local_gas_station, color: Color(0xFF94A3B8)),
//               SizedBox(width: 8),
//               Text("Fuel level", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
//               Spacer(),
//               Text("75%", style: TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           LinearPercentIndicator(
//             percent: 0.75,
//             lineHeight: 8,
//             backgroundColor: const Color(0xFFF1F5F9),
//             progressColor: const Color(0xFF033F78),
//             barRadius: const Radius.circular(5),
//             padding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
//             child: const Text("EMERGENCY SOS", style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSunInfo() {
//     return Row(
//       children: [
//         Expanded(child: Cardinfo(Colors.orange, Icons.wb_sunny, "SUNRISE", _sunrise?.substring(11, 16) ?? "--:--")),
//         const SizedBox(width: 12),
//         Expanded(child: Cardinfo(Colors.blueGrey, Icons.nightlight_round, "SUNSET", _sunset?.substring(11, 16) ?? "--:--")),
//       ],
//     );
//   }
// }
//
// class WeatherInfo extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon1;
//   const WeatherInfo({super.key, required this.title, required this.value, required this.icon1});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE2E8F0))),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon1, color: const Color(0xFF033F78)),
//           const SizedBox(height: 8),
//           Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }
//
// class Cardinfo extends StatelessWidget {
//   final Color color;
//   final IconData icon;
//   final String title;
//   final String time;
//   const Cardinfo(this.color, this.icon, this.title, this.time, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE2E8F0))),
//       child: Column(
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(height: 4),
//           Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
//           Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }
