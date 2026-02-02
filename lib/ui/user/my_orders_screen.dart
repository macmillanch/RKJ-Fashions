import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/order_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import 'order_tracking_screen.dart';
import 'user_order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final int initialTab;
  const MyOrdersScreen({super.key, this.initialTab = 0});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view orders.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F4), // background-light
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: const Color(0xFFFDF8F4).withValues(alpha: 0.8),
              floating: true,
              pinned: true,
              elevation: 0,
              centerTitle: true,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF181117),
                    size: 20,
                  ),
                ),
              ),
              title: Text(
                'My Orders',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF181117),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE6DBE4)),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFD912BB), // primary
                    unselectedLabelColor: const Color(0xFF896183),
                    indicatorColor: const Color(0xFFD912BB),
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2, // 0.015em
                    ),
                    tabs: const [
                      Tab(text: "Ongoing"),
                      Tab(text: "Completed"),
                      Tab(text: "Cancelled"),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: StreamBuilder<List<OrderModel>>(
          stream: context.read<DatabaseService>().getUserOrders(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No orders found',
                  style: GoogleFonts.manrope(color: Colors.grey),
                ),
              );
            }

            final allOrders = snapshot.data!;
            // Filter Orders
            final ongoing = allOrders
                .where(
                  (o) =>
                      [
                        'Ordered',
                        'Packed',
                        'Shipped',
                      ].contains(o.orderStatus) &&
                      !o.deliveryConfirmed,
                )
                .toList();
            final completed = allOrders
                .where(
                  (o) => o.orderStatus == 'Delivered' || o.deliveryConfirmed,
                )
                .toList();
            final cancelled = allOrders
                .where((o) => o.orderStatus == 'Cancelled')
                .toList();

            // Sort by date (newest first)
            ongoing.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            completed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            cancelled.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(ongoing, context),
                _buildOrderList(completed, context),
                _buildOrderList(cancelled, context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No orders in this tab",
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], context);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, BuildContext context) {
    final isShipped = order.orderStatus == 'Shipped';
    final isDelivered =
        order.orderStatus == 'Delivered' || order.deliveryConfirmed;

    Color statusDotColor = Colors.blue;
    if (isShipped) {
      statusDotColor = Colors.blue;
    } else if (order.orderStatus == 'Ordered') {
      statusDotColor = Colors.orange;
    } else if (isDelivered) {
      statusDotColor = Colors.green;
    } else if (order.orderStatus == 'Cancelled') {
      statusDotColor = Colors.red;
    }

    final dateStr = DateFormat('MMM dd, yyyy').format(order.createdAt);
    final primaryImg = order.items.isNotEmpty ? order.items.first.image : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3E9F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.orderStatus.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF896183),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #${order.id}',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF181117),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placed on $dateStr',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: const Color(0xFF896183),
                  ),
                ),
                const SizedBox(height: 16),
                if (isShipped)
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 40,
                        constraints: const BoxConstraints(maxWidth: 160),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD912BB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderTrackingScreen(order: order),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Track Order',
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Stack(
                    children: [
                      Container(
                        height: 40,
                        constraints: const BoxConstraints(maxWidth: 160),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F0F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserOrderDetailScreen(order: order),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: Text(
                                isDelivered ? 'Reorder' : 'View Details',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFF181117),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(
                  primaryImg.isNotEmpty
                      ? primaryImg
                      : 'https://via.placeholder.com/100',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
