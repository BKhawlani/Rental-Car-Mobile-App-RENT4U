import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:better_player/better_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class Aboutus extends StatefulWidget {
  final bool fromsetting;
  const Aboutus({required this.fromsetting, Key? key}) : super(key: key);

  @override
  State<Aboutus> createState() => _AboutusState();
}

class _AboutusState extends State<Aboutus> {
  final String videoAsset = 'assets/videos/output_compatible.mp4';
  late BetterPlayerController _betterPlayerController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  final Completer<GoogleMapController> _mapController = Completer();

  static const CameraPosition _kCompanyLocation = CameraPosition(
    target: LatLng(41.3765, 33.7765),
    zoom: 14.4746,
  );

  final Marker _companyMarker = const Marker(
    markerId: MarkerId('company_location'),
    position: LatLng(41.3765, 33.7765),
    infoWindow: InfoWindow(title: 'Rent4U Headquarters'),
  );

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<String> loadAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/temp_video.mp4');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  Future<void> _initializeVideo() async {
    final filePath = await loadAssetToFile("assets/videos/about_us.mp4");

    try {
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        filePath,
      );

      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          fit: BoxFit.cover,
          autoPlay: true,
          looping: true,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            enableSkips: false,
            enableFullscreen: false,
            enableMute: false,
            enablePlaybackSpeed: false,
            showControlsOnInitialize: false,
          ),
          errorBuilder: (context, errorMessage) {
            return _buildVideoErrorWidget(errorMessage ?? "");
          },
        ),
        betterPlayerDataSource: dataSource,
      );

      // Listen for player events
      _betterPlayerController.addEventsListener((event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
          setState(() {
            _isVideoError = true;
          });
        } else if (event.betterPlayerEventType ==
            BetterPlayerEventType.initialized) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      });

      await _betterPlayerController.setupDataSource(dataSource);
    } catch (e) {
      setState(() {
        _isVideoError = true;
      });
      debugPrint('Video initialization error: $e');
    }
  }

  Widget _buildVideoErrorWidget(String errorMessage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 50, color: Colors.white),
        const SizedBox(height: 10),
        Text(
          'Failed to load video'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _initializeVideo,
          child: Text('Retry'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSizeTitle = screenWidth * 0.06;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.fromsetting
          ? AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              backgroundColor: const Color.fromARGB(255, 36, 14, 144),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.fromsetting) SizedBox(height: screenHeight * 0.03),

            // Video Player Section
            Container(
              height: screenHeight * 0.4,
              width: double.infinity,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(8),
              //   color: Colors.black,
              // ),
              child: ClipRRect(
                child: _isVideoInitialized
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child:
                            BetterPlayer(controller: _betterPlayerController),
                      )
                    : _isVideoError
                        ? _buildVideoErrorWidget('')
                        : const Center(child: CircularProgressIndicator()),
              ),
            ),

            // About Us Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About App:".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: fontSizeTitle - 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rent4U is a simple and smart app that helps users rent cars quickly and easily. Whether you need a car for travel or daily use, Rent4U makes the process fast and smooth."
                        .tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          height: 1.6,
                        ),
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
                      fontSize: fontSizeTitle - 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(
                    icon: Icons.phone,
                    text: "+90 531 945 34 71",
                    onTap: () => _launchUrl('tel:+905319453471'),
                  ),
                  _buildContactInfo(
                    icon: Icons.email,
                    text: "info@rent4u.com",
                    onTap: () => _launchUrl('mailto:info@rent4u.com'),
                  ),
                  _buildContactInfo(
                    icon: Icons.location_on,
                    text: "Turkey, Kastamonu",
                    onTap: () => _launchUrl(
                        'https://maps.google.com/?q=41.3765,33.7765'),
                  ),
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
                      fontSize: fontSizeTitle - 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _kCompanyLocation,
                        markers: {_companyMarker},
                        onMapCreated: (controller) =>
                            _mapController.complete(controller),
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        myLocationEnabled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About Project Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About This Project:".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: fontSizeTitle - 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            height: 1.6,
                          ),
                      children: [
                        TextSpan(
                          text:
                              'This application was developed as a final project for the Mobile Programming course by student '
                                  .tr(),
                        ),
                        if (Localizations.localeOf(context).languageCode !=
                            'tr')
                          TextSpan(
                            text: 'Bashar Alkhawlani',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (Localizations.localeOf(context).languageCode !=
                            'tr') ...[
                          TextSpan(text: ' under the supervision of\n '.tr()),
                          TextSpan(
                            text: 'Dr. Öğr. Üyesi Atilla SUNCAK\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '.'),
                        ]
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      debugPrint('Could not launch URL: $e');
    }
  }
}
