import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/order_model.dart';
import 'order_tracking_screen.dart';

class UserOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const UserOrderDetailScreen({super.key, required this.order});

  @override
  State<UserOrderDetailScreen> createState() => _UserOrderDetailScreenState();
}

class _UserOrderDetailScreenState extends State<UserOrderDetailScreen> {
  // Using hardcoded colors from HTML request
  static const Color colorPrimary = Color(0xFFD912BB);
  static const Color colorBgLight = Color(0xFFFDF8FB);
  static const Color colorTextMain = Color(0xFF181117);
  static const Color colorTextMuted = Color(0xFF896183);

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    // We can use dateStr if we want to show it in the header, but current design doesn't explicitly ask for it there.
    // However, the tracking stepper uses formatted dates.

    return Scaffold(
      backgroundColor: colorBgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF4F0F4))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: colorTextMain),
                  ),
                  Expanded(
                    child: Text(
                      'Order #${order.id}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorTextMain,
                      ),
                    ),
                  ),
                  const Icon(Icons.help_outline, color: colorTextMain),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stepper Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tracking Status',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorTextMain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStepper(order),
                        ],
                      ),
                    ),

                    Container(height: 8, color: colorBgLight),

                    // Tracking Section (if shipped)
                    if (order.trackingId.isNotEmpty &&
                        order.orderStatus != 'Cancelled') ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: colorPrimary.withValues(alpha: 0.05),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.mail,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'India Post Tracking',
                                  style: GoogleFonts.manrope(
                                    color: colorPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorPrimary.withValues(alpha: 0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CONSIGNMENT NUMBER',
                                        style: GoogleFonts.manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: colorTextMuted,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        order.trackingId,
                                        style: GoogleFonts.manrope(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorTextMain,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderTrackingScreen(order: order),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorPrimary,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      'Track',
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 8, color: colorBgLight),
                    ],

                    // Order Information
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Information',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorTextMain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F0F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: colorTextMain,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Shipping Address',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colorTextMain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.shippingAddress.isNotEmpty
                                          ? order.shippingAddress
                                          : 'Address not provided',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        color: colorTextMuted,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F0F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.payments,
                                  color: colorTextMain,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Method',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colorTextMain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manual UPI${order.transactionId != null ? ' (Txn: ${order.transactionId})' : ''}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        color: colorTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(height: 8, color: colorBgLight),

                    // Price Summary
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Summary',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorTextMain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${item.name} (x${item.quantity})",
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        color: colorTextMuted,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "₹${item.price}",
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colorTextMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Shipping Fee",
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  color: colorTextMuted,
                                ),
                              ),
                              Text(
                                "FREE",
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFFE6DBE4)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Amount",
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorTextMain,
                                ),
                              ),
                              Text(
                                "₹${order.totalAmount}",
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: colorPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF4F0F4))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Help
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE6DBE4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Need Help?',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorTextMain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (order.orderStatus ==
                      'Ordered') // Only allow cancel if ordered
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Cancel logic would go here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel Order',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else if (order.orderStatus == 'Delivered')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Return/Reorder logic would go here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reorder',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(), // Empty if shipped/packed for now
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(OrderModel order) {
    bool isPacked =
        ['Packed', 'Shipped', 'Delivered'].contains(order.orderStatus) ||
        order.deliveryConfirmed;
    bool isShipped =
        ['Shipped', 'Delivered'].contains(order.orderStatus) ||
        order.deliveryConfirmed;
    bool isDelivered =
        ['Delivered'].contains(order.orderStatus) || order.deliveryConfirmed;

    // Format dates
    String placedDate = DateFormat('MMM dd, hh:mm a').format(order.createdAt);
    String delDate = order.deliveredAt != null
        ? DateFormat('MMM dd, hh:mm a').format(order.deliveredAt!)
        : "Expected soon";

    const colorPrimary = Color(0xFFD912BB);

    return Column(
      children: [
        _buildStep("Order Placed", placedDate, true, true, colorPrimary),
        _buildStep("Payment Verified", placedDate, true, true, colorPrimary),
        _buildStep(
          "Packed",
          isPacked ? "Processing complete" : "Pending",
          isPacked,
          true,
          colorPrimary,
        ),
        _buildStep(
          "Shipped",
          isShipped ? "In Transit" : "Pending",
          isShipped,
          true,
          colorPrimary,
        ),
        _buildStep(
          "Delivered",
          isDelivered ? delDate : "Expected soon",
          isDelivered,
          false,
          colorPrimary,
        ),
      ],
    );
  }

  Widget _buildStep(
    String title,
    String subtitle,
    bool isActive,
    bool hasLine,
    Color primaryColor,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  child: Icon(
                    isActive
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isActive ? primaryColor : Colors.grey[300],
                    size: 20,
                  ),
                ),
                if (hasLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isActive ? primaryColor : Colors.grey[200],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                      color: isActive ? const Color(0xFF181117) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF896183),
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
