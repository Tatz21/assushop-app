import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../data/models/outlet_model.dart';
import '../../state/app_state.dart';

class GeofenceCheckInDialog extends StatelessWidget {
  final OutletModel outlet;

  const GeofenceCheckInDialog({
    super.key,
    required this.outlet,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final distance = appState.simulatedGpsDistanceMeters;
    final isWithinGeofence = distance <= outlet.geofenceRadius;
    final isMock = appState.simulatedIsMockLocation;

    final (repLat, repLng) = LocationService.calculateSimulatedCoordinate(
      originLat: outlet.latitude,
      originLng: outlet.longitude,
      distanceMeters: distance,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWithinGeofence
                  ? AppColors.green.withAlpha(25)
                  : AppColors.primaryRed.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWithinGeofence
                  ? Icons.location_on_rounded
                  : Icons.location_off_rounded,
              color: isWithinGeofence ? AppColors.green : AppColors.primaryRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPS Geofence Verification',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  outlet.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radar Visual Indicator
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isWithinGeofence
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                border: Border.all(
                  color: isWithinGeofence
                      ? AppColors.green
                      : AppColors.primaryRed,
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isWithinGeofence
                          ? Icons.check_circle_rounded
                          : Icons.do_not_disturb_on_rounded,
                      color: isWithinGeofence
                          ? AppColors.green
                          : AppColors.primaryRed,
                      size: 30,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${distance.toStringAsFixed(0)}m',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isWithinGeofence
                            ? const Color(0xFF166534)
                            : AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Coordinates Readout Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Store Geotag:',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${outlet.latitude.toStringAsFixed(4)}° N, ${outlet.longitude.toStringAsFixed(4)}° E',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Salesman GPS:',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${repLat.toStringAsFixed(4)}° N, ${repLng.toStringAsFixed(4)}° E',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Anti-Mock Hardware:',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isMock
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isMock ? 'MOCK FLAGGED' : 'CLEAN HARDWARE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isMock
                                ? AppColors.primaryRed
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Status Banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isWithinGeofence
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isWithinGeofence
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFECDD3),
                ),
              ),
              child: Text(
                isWithinGeofence
                    ? '✅ Within 100m geofence radius. Haversine check verified. Store unlocked.'
                    : '⛔ Outside geofence (${distance.toStringAsFixed(0)}m away). AUPL Rule 4 requires physical presence within 100m to check in.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isWithinGeofence
                      ? const Color(0xFF15803D)
                      : AppColors.primaryRed,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Test Simulation Buttons (Quick toggle for testing in Chrome)
            Text(
              'Simulate Field Distance (Chrome Testing)',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      appState.setSimulatedGpsDistance(35.0);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                        color: isWithinGeofence
                            ? AppColors.green
                            : AppColors.grayBorder,
                      ),
                    ),
                    child: Text(
                      'Inside (35m)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isWithinGeofence
                            ? AppColors.green
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      appState.setSimulatedGpsDistance(240.0);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                        color: !isWithinGeofence
                            ? AppColors.primaryRed
                            : AppColors.grayBorder,
                      ),
                    ),
                    child: Text(
                      'Outside (240m)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: !isWithinGeofence
                            ? AppColors.primaryRed
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isWithinGeofence
              ? () {
                  final success = appState.checkInOutlet(outlet.id);
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'GPS Check-In Verified for ${outlet.name}! Active visit started.'),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Verify & Check-In'),
        ),
      ],
    );
  }
}
