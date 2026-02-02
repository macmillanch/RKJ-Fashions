import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/storage_service.dart';

class OrderDetailAdminScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailAdminScreen({super.key, required this.order});

  @override
  State<OrderDetailAdminScreen> createState() => _OrderDetailAdminScreenState();
}

class _OrderDetailAdminScreenState extends State<OrderDetailAdminScreen> {
  bool _isLoading = false;

  Future<void> _markPacked() async {
    setState(() => _isLoading = true);
    await context.read<DatabaseService>().markOrderPacked(widget.order.id);
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  Future<void> _markShipped() async {
    final courierCtrl = TextEditingController(
      text: 'India Post – Dak Seva Jan Seva',
    );
    final trackingCtrl = TextEditingController();
    String? slipUrl;

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool localLoading = false;
        return StatefulBuilder(
          builder: (sbContext, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Mark Shipped',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: courierCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Courier Name',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: trackingCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tracking ID',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setStateSB(() => localLoading = true);
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          try {
                            // ignore: use_build_context_synchronously
                            final url = await StorageService().uploadImage(
                              image,
                              'tracking_slips',
                            );
                            setStateSB(() {
                              slipUrl = url;
                              localLoading = false;
                            });
                          } catch (e) {
                            setStateSB(() => localLoading = false);
                          }
                        } else {
                          setStateSB(() => localLoading = false);
                        }
                      },
                      icon: Icon(
                        slipUrl == null ? Icons.upload_file : Icons.check,
                      ),
                      label: Text(
                        slipUrl == null
                            ? 'Upload Tracking Slip'
                            : 'Slip Uploaded',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slipUrl == null
                            ? AppColors.primaryUser
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (localLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (trackingCtrl.text.isEmpty || slipUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter Tracking ID and upload Slip',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext); // Close dialog
                    setState(() => _isLoading = true);
                    await context.read<DatabaseService>().markOrderShipped(
                      widget.order.id,
                      courierCtrl.text,
                      trackingCtrl.text,
                      slipUrl!,
                    );
                    if (mounted) {
                      setState(() => _isLoading = false);
                      Navigator.pop(context); // Close screen
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryUser,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Shipped'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not make call: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    const Color primaryColor = Color(0xFF8E5D87);
    const Color bgColor = Color(0xFFF7F7F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Custom TopAppBar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, color: Color(0xFF151415)),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151415),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF151415)),
                  onPressed: _editTracking,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Info Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer Information",
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151415),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: const NetworkImage(
                                      "https://lh3.googleusercontent.com/aida-public/AB6AXuBfuP2Urzr9XwAIDjUEi0d-xXZiv_KX90ufHf60C8P2xC191nwJcNh2Uk5F-ALflxd7kFUoNxMUHdIh1XCPPDIe9fvYZbKxoWrFljAj1XV5wCc8XBTn6Zex_NOLeXMsAmaHXaALKST62X9qlEWaFUvFELdL7g1HAPctyUGqzagjGM3JMB63gcG6MbB6vOLhbR81z4QNtQng-BGtjopIbmWmyDNkpsOSE92zpKaKiAA8fiTZilfdm21qaBAFD_H98FXuzKnL1hWch3E",
                                    ),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.beneficiaryName ?? "Customer",
                                          style: GoogleFonts.manrope(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF151415),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          order.userPhone,
                                          style: GoogleFonts.manrope(
                                            fontSize: 14,
                                            color: const Color(0xFF7A7179),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _makePhoneCall(order.userPhone),
                                    icon: const Icon(
                                      Icons.call,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "CALL",
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Shipping Address
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F2F3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.map,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Shipping Address",
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF151415),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.shippingAddress.isNotEmpty
                                          ? order.shippingAddress
                                          : "No Address Provided",
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        color: const Color(0xFF7A7179),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Order Items
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order Items",
                                    style: GoogleFonts.manrope(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF151415),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "${order.items.length} Items",
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...order.items.map(
                                (item) => Container(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFF3F2F3),
                                      ),
                                    ),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              item.image.isNotEmpty
                                                  ? item.image
                                                  : "https://via.placeholder.com/80",
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: GoogleFonts.manrope(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF151415),
                                              ),
                                            ),
                                            Text(
                                              "Size: ${item.selectedSize} | Color: ${item.selectedColor}",
                                              style: GoogleFonts.manrope(
                                                fontSize: 14,
                                                color: const Color(0xFF7A7179),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "₹${item.price}",
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  "Qty: ${item.quantity}",
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                      0xFF151415,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Summary
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 2),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Subtotal",
                                    style: GoogleFonts.manrope(
                                      color: const Color(0xFF7A7179),
                                    ),
                                  ),
                                  Text(
                                    "₹${order.totalAmount}",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF151415),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Shipping",
                                    style: GoogleFonts.manrope(
                                      color: const Color(0xFF7A7179),
                                    ),
                                  ),
                                  Text(
                                    "FREE",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Color(0xFFEEEEEE)),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Amount",
                                    style: GoogleFonts.manrope(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF151415),
                                    ),
                                  ),
                                  Text(
                                    "₹${order.totalAmount}",
                                    style: GoogleFonts.manrope(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF151415),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
          // Sticky Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: _buildFooterButton(order, primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(OrderModel order, Color primaryColor) {
    if (order.orderStatus == 'Ordered') {
      return ElevatedButton(
        onPressed: _isLoading ? null : _markPacked,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'MARK AS PACKED',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    } else if (order.orderStatus == 'Packed') {
      return ElevatedButton(
        onPressed: _isLoading ? null : _markShipped,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryUser,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'MARK AS SHIPPED',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    } else if (order.orderStatus == 'Shipped') {
      return ElevatedButton(
        onPressed: _isLoading ? null : _markDelivered,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'MARK AS DELIVERED',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _editTracking() async {
    final TextEditingController trackingController = TextEditingController(
      text: widget.order.trackingId,
    );
    // Courier name is not available in OrderModel to prefill, so user must enter it again or we just ask for ID?
    // markOrderShipped requires courier.
    final TextEditingController courierController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Tracking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courierController,
              decoration: const InputDecoration(
                labelText: 'Courier Name (e.g. BlueDart)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: trackingController,
              decoration: const InputDecoration(
                labelText: 'Tracking ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (trackingController.text.isEmpty ||
                  courierController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter all details')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                await context.read<DatabaseService>().markOrderShipped(
                  widget.order.id,
                  courierController.text,
                  trackingController.text,
                  '', // No slip URL update supported here yet, or pass existing?
                  // markOrderShipped signature: id, courier, trackingId, slipUrl.
                  // If we pass empty slipUrl, does backend erase it?
                  // Backend markOrderShipped: status='Shipped', tracking_id=...
                  // It DOES NOT touch slip_url if not provided?
                  // Wait, Step 3143: body: {status: 'Shipped', tracking_id: trackingId}.
                  // It does NOT include slip_url in body construction!
                  // It takes slipUrl as argument but ignores it in body construction!
                  // Wait. Line 123 in Step 3143: body: jsonEncode({'status': 'Shipped', 'tracking_id': trackingId})
                  // Params: String slipUrl (line 118).
                  // So slipUrl IS IGNORED. So passing empty string is safe.
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tracking Updated')),
                  );
                  Navigator.pop(context); // Go back to refresh? Or stay?
                  // Usually StreamBuilder updates automatically.
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  Future<void> _markDelivered() async {
    setState(() => _isLoading = true);
    try {
      await context.read<DatabaseService>().confirmDelivery(widget.order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order marked as Delivered')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
