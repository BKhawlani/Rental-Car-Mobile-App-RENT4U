import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Aboutus extends StatefulWidget {
  bool fromsetting;
  Aboutus({required this.fromsetting});

  @override
  State<Aboutus> createState() => _AboutusState();
}

class _AboutusState extends State<Aboutus> {
  final asset = 'assets/videos/about_us.mp4';
  late VideoPlayerController controller;
  bool _showPlayPauseButton = false;

  Timer? _playPauseTimer;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  String _videoErrorMsg = '';
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  // Actual coordinates for your location in Kastamonu, Turkey
  static const CameraPosition _kCompanyLocation = CameraPosition(
    target: LatLng(41.3765, 33.7765), // Kastamonu coordinates
    zoom: 14.4746,
  );

  final Marker _companyMarker = const Marker(
    markerId: MarkerId('company_location'),
    position: LatLng(41.3765, 33.7765), // Kastamonu coordinates
    infoWindow: InfoWindow(title: 'Rent4U Headquarters'),
  );

  void _togglePlayPause() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      _showPlayPauseButton = true;
      _playPauseTimer?.cancel();
      _playPauseTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showPlayPauseButton = false);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      controller = VideoPlayerController.asset(asset)
        ..setLooping(true)
        ..addListener(_videoListener);

      await controller.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        controller.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoError = true;
          _videoErrorMsg = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_videoListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double fontSizeTitle = screenWidth * 0.06;
    double ButtonField = screenHeight * 0.06;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.fromsetting
          ? AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              backgroundColor: Color.fromARGB(255, 36, 14, 144),
              title: Text(
                "About Us".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeTitle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),

            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isVideoInitialized)
                      VideoPlayer(controller)
                    else if (_isVideoError)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _videoErrorMsg,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      const Center(child: CircularProgressIndicator()),
                    Positioned.fill(
                      child: InkWell(
                        onTap: _togglePlayPause,
                        child: AnimatedOpacity(
                          opacity: _showPlayPauseButton ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // About Us Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About App:".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rent4U is a simple and smart app that helps users rent cars quickly and easily. Whether you need a car for travel or daily use, Rent4U makes the process fast and smooth."
                        .tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Information:".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(Icons.phone, "+90 531 945 34 71"),
                  _buildContactInfo(Icons.email, "info@rent4u.com"),
                  _buildContactInfo(Icons.location_on, "Turkey, Kastamonu"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Map Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Location:".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _kCompanyLocation,
                            markers: {_companyMarker},
                            onMapCreated: (GoogleMapController controller) {
                              _mapController.complete(controller);
                            },
                            gestureRecognizers: <Factory<
                                OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                            zoomControlsEnabled: true,
                            zoomGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            tiltGesturesEnabled: true,
                            rotateGesturesEnabled: true,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          ),
                          // يمكن إضافة عناصر واجهة مستخدم إضافية هنا
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "  About This Project:".tr(),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text.rich(
              TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.6),
                children: [
                  TextSpan(
                    text:
                        'This application was developed as a final project for the Mobile Programming course by student '
                            .tr(),
                  ),
                  TextSpan(
                    text: 'Bashar Alkhawlani',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' under the supervision of\n '.tr()),
                  TextSpan(
                    text: 'Dr. Öğr. Üyesi Atilla SUNCAK\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
