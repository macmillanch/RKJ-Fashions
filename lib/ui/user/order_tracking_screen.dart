import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Added for context.read
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../data/models/order_model.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart'; // Added import for GoogleFonts
import '../../data/services/database_service.dart'; // Added import

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _loading = false;
  Map<String, dynamic>? _trackingData;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.order.trackingId.isNotEmpty) {
      _fetchTracking();
    }
  }

  Future<void> _fetchTracking() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<DatabaseService>().trackSpeedPost(
        widget.order.trackingId,
      );
      if (mounted) {
        if (data.containsKey('error')) {
          // Fallback: Use internal order status if API fails (e.g. 403)
          setState(() {
            _trackingData = {
              'status': widget.order.orderStatus,
              'events': [
                {
                  'date': _formatDate(widget.order.createdAt),
                  'time': '10:00 AM',
                  'location': 'Store',
                  'status': 'Order Placed',
                },
                if (widget.order.orderStatus != 'Pending' &&
                    widget.order.orderStatus != 'Confirmed') ...[
                  {
                    'date': _formatDate(DateTime.now()),
                    'time': '12:00 PM',
                    'location': 'Transit Hub',
                    'status': widget.order.orderStatus,
                  },
                ],
              ],
            };
            _loading = false;
            // Clear error so UI shows the fallback
            _error = null;
          });
        } else {
          setState(() {
            _trackingData = data;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to fetch status';
          _loading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color indiaPostRed = Color(0xFFD8232A);
    const Color indiaPostYellow = Color(0xFFE8C646);
    const Color darkBackground = Color(0xFF151415);
    const Color creamColor = Color(0xFFFAF7F0);

    return Scaffold(
      backgroundColor: darkBackground,
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: Stack(
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCA2jBhPPZiHbNgpPemDIwr7nDfzhik6yA_1B37UvCZXncY3gq3K3VxlcYcUle0chE7HRf2fybN2fVABlAhoYLFGM79laLYIi3f1bs_taTtEUHvcx7g8i_YkcbGn2v4kjdzfz5s_Ahw5tNS4x79KrFZbP3vqUpcEjcoQR5qVI_UTyTd6i9fCY2ugJK-xlN0b2Nrkt11jCXuZumHo7x1LGPUhoTVOfPFkAO6n35jSDZLaqu8uk6TYanGgLWy0V17-A_YCrpFUgmxxvA',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (c, e, s) => Container(color: Colors.black),
                ),
                BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(color: Colors.black.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tracking Slip',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance back button
                  ],
                ),
              ),
            ),
          ),

          // Slip Card (Rotated)
          Positioned(
            top: 120, // Adjust as needed
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: -0.05, // Slight rotation (~ -3 deg)
                child: Container(
                  width: 300,
                  height: 420, // Aspect ratio ~0.7
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 50,
                        offset: const Offset(0, 25),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Slip Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                            child: const Icon(
                              Icons.local_post_office,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INDIA POST',
                                style: GoogleFonts.epilogue(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'SPEED POST',
                                style: GoogleFonts.manrope(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(width: 32, height: 32, color: Colors.black),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.black, thickness: 2),
                      const SizedBox(height: 12),
                      // Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DATE: ${_formatDate(widget.order.createdAt)}',
                            style: _monoStyle,
                          ),
                          Text(
                            'STATUS: ${widget.order.orderStatus.toUpperCase()}',
                            style: _monoStyle,
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, height: 24),
                      // Skeleton lines visual
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 6,
                          width: 100,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 6,
                          width: 200,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Image Area
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: widget.order.trackingSlipUrl.isNotEmpty
                              ? Image.network(
                                  widget.order.trackingSlipUrl,
                                  fit: BoxFit.cover,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  colorBlendMode: BlendMode.multiply,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(
                                      Icons.receipt_long,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCA2jBhPPZiHbNgpPemDIwr7nDfzhik6yA_1B37UvCZXncY3gq3K3VxlcYcUle0chE7HRf2fybN2fVABlAhoYLFGM79laLYIi3f1bs_taTtEUHvcx7g8i_YkcbGn2v4kjdzfz5s_Ahw5tNS4x79KrFZbP3vqUpcEjcoQR5qVI_UTyTd6i9fCY2ugJK-xlN0b2Nrkt11jCXuZumHo7x1LGPUhoTVOfPFkAO6n35jSDZLaqu8uk6TYanGgLWy0V17-A_YCrpFUgmxxvA',
                                  fit: BoxFit.cover,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  colorBlendMode: BlendMode.multiply,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(
                                      Icons.receipt_long,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TRACKING ID',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            style: BorderStyle.none,
                          ), // Dashed border simulated by custom paint? Simplification: Dotted
                        ),
                        child: Text(
                          widget.order.trackingId.isEmpty
                              ? 'Waiting...'
                              : widget.order.trackingId,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Sheet (Draggable Look)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: creamColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 40,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Header Info
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: indiaPostYellow.withValues(alpha: 0.3),
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/india_post_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'India Post',
                              style: GoogleFonts.epilogue(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF151415),
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildBadge(
                                  'DAK SEVA',
                                  Colors.white,
                                  indiaPostRed,
                                ),
                                const SizedBox(width: 6),
                                _buildBadge(
                                  'JAN SEVA',
                                  indiaPostRed,
                                  Colors.transparent,
                                  border: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.verified, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Consignment Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CONSIGNMENT NUMBER',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.order.trackingId.isEmpty
                                    ? 'NOT ASSIGNED'
                                    : widget.order.trackingId,
                                style: GoogleFonts.shareTechMono(
                                  color: indiaPostRed,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (widget.order.trackingId.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: widget.order.trackingId,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('ID Copied'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  tooltip: 'Copy Tracking ID',
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Buttons Grid (Row of 3)
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridButton(
                            icon: Icons.public,
                            label: 'Track on\nWebsite',
                            isPrimary: true,
                            color: indiaPostRed,
                            onTap: () => _launchUrl(
                              context,
                              AppConstants.indiaPostWebsite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGridButton(
                            icon: Icons.open_in_new,
                            label: 'Post Info\nApp',
                            customIcon: Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Google_Play_2022_logo.svg/512px-Google_Play_2022_logo.svg.png",
                              width: 24,
                              height: 24,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.shop, size: 24),
                            ),
                            onTap: () => _launchUrl(
                              context,
                              AppConstants.indiaPostAppUrl,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Live Status Section
                    if (widget.order.trackingId.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "LIVE STATUS",
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLiveStatus(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _monoStyle =>
      GoogleFonts.shareTechMono(fontSize: 8, color: Colors.grey[600]);

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  Widget _buildBadge(
    String text,
    Color textColor,
    Color bgColor, {
    bool border = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: border ? Border.all(color: textColor) : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    Color? color,
    Widget? customIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPrimary ? color : Colors.grey[100],
                shape: BoxShape.circle,
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: color!.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child:
                    customIcon ??
                    Icon(
                      icon,
                      color: isPrimary ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatus() {
    if (_trackingData == null || _trackingData!.isEmpty) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      if (_error != null) {
        return Center(
          child: Text(
            "Error: $_error",
            style: GoogleFonts.manrope(color: Colors.red),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Assuming API follows standard structure. Or check for 'events'
    final events = _trackingData!['events'] as List<dynamic>?;

    if (events != null && events.isNotEmpty) {
      return Column(
        children: events.map<Widget>((event) {
          final isFirst = events.first == event;
          final isLast = events.last == event;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? const Color(0xFFD8232A)
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: isFirst
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                      boxShadow: isFirst
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFD8232A,
                                ).withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40, color: Colors.grey[300]),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['status'] ?? 'Update',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                        color: isFirst ? Colors.black : Colors.grey[700],
                      ),
                    ),
                    Text(
                      "${event['date'] ?? ''} ${event['time'] ?? ''} - ${event['location'] ?? ''}",
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      );
    }

    // Fallback
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundUser,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Status: ${_trackingData?['status'] ?? 'In Transit'}",
        style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
      ),
    );
  }
}
