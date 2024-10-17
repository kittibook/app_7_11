import 'package:app_7_11/app_router.dart';
import 'package:app_7_11/screen/shoppingcart.dart';
import 'package:app_7_11/utility.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String _currentPosition = 'ไม่พบที่ออยู่ กรุณาเลือกที่อยู่';
  String _saveCurrentPosition = 'ไม่พบที่ออยู่ กรุณาเลือกที่อยู่';
  String _shippingCost = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }


  Future<void> _loadUserData() async {
    var user1 = await Utility.getSharedPreference('USERMARKER');
    var user11 = await Utility.getSharedPreference('USERMARKER1');
    var user12 = await Utility.getSharedPreference('USERMARKER2');
    var map1 = await Utility.getSharedPreference('SEVEN');
    var map11 = await Utility.getSharedPreference('SEVEN1');
    var map12 = await Utility.getSharedPreference('SEVEN2');
    if (user11 != null && user12 != null && map11 != null && map12 != null){
    var _lastDistance = Geolocator.distanceBetween(
      map11,
      map12,
      user11,
      user12,
    );
    setState(() {
      if (user1 != null) {
        _currentPosition = user1;
      } else {
        _currentPosition = 'ไม่พบที่ออยู่ กรุณาเลือกที่อยู่';
      }
      if (map1 != null) {
        _saveCurrentPosition = map1;
      } else {
        _saveCurrentPosition = 'ไม่พบที่ออยู่ กรุณาเลือกที่อยู่';
      }

      if (_lastDistance <= 3000) {
        setState(() {
          _shippingCost = '0';
        });
      } else {
        double additionalCost = (_lastDistance - 3000) *
            0.05; // คิดค่าบริการ 0.05 ต่อเมตรหลังจาก 3 กิโลเมตร
        setState(() {
          _shippingCost = additionalCost.toString();
        });
      }
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 130, 68, 1),
        title: const Text(
          "สั่งซื้อสินค้า ",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddressSevenSection(Seven: _saveCurrentPosition),
            const SizedBox(height: 20),
            AddressSection(currentPosition: _currentPosition),
            const SizedBox(height: 20),
            const Expanded(
                child:
                    ProductList()), // ใช้ Expanded เพื่อป้องกันการเกิด overflow
            const PriceSummary(),
          ],
        ),
      ),
    );
  }
}

class AddressSevenSection extends StatelessWidget {
  final String Seven; // เพิ่มพารามิเตอร์เพื่อรับพิกัด

  const AddressSevenSection({super.key, required this.Seven});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ดึงรายการสินค้าจาก arguments
    final List<Item>? items = arguments?['cartItems'] as List<Item>?;

    // ถ้าไม่มีสินค้าหรือไม่มีข้อมูล ให้แสดงข้อความ "ไม่มีสินค้าในตะกร้า"
    if (items == null || items.isEmpty) {
    }
    return GestureDetector(
      onTap: () async {
        Navigator.pushReplacementNamed(context, AppRouter.sevenmap, arguments: { 'cartItems': items, });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ที่อยู่ 7-11',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(child: Text(Seven)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddressSection extends StatelessWidget {
  final String currentPosition; // เพิ่มพารามิเตอร์เพื่อรับพิกัด

  const AddressSection({super.key, required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ดึงรายการสินค้าจาก arguments
    final List<Item>? items = arguments?['cartItems'] as List<Item>?;

    // ถ้าไม่มีสินค้าหรือไม่มีข้อมูล ให้แสดงข้อความ "ไม่มีสินค้าในตะกร้า"
    if (items == null || items.isEmpty) {
    }
    return GestureDetector(
      onTap: () async {
        Navigator.pushReplacementNamed(context, AppRouter.usermap, arguments: { 'cartItems': items, });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ที่อยู่จัดส่ง',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(child: Text(currentPosition)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ดึงรายการสินค้าจาก arguments
    final List<Item>? items = arguments?['cartItems'] as List<Item>?;

    // ถ้าไม่มีสินค้าหรือไม่มีข้อมูล ให้แสดงข้อความ "ไม่มีสินค้าในตะกร้า"
    if (items == null || items.isEmpty) {
      return const Center(child: Text('ไม่มีสินค้าในตะกร้า'));
    }

    return ListView.builder(
      shrinkWrap: true, // ใช้ shrinkWrap เพื่อให้มันปรับขนาดอัตโนมัติใน Column
      physics: const NeverScrollableScrollPhysics(), // ปิดการเลื่อน
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ProductItem(
          name: item.name,
          price: '${item.price} บาท',
          color: Colors.green.shade50,
        );
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  final String name;
  final String price;
  final Color color;

  const ProductItem(
      {super.key,
      required this.name,
      required this.price,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.shopping_bag, color: Colors.green),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
          Text(price, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class PriceSummary extends StatefulWidget {
  const PriceSummary({super.key});

  @override
  State<PriceSummary> createState() => _PriceSummaryState();
}

class _PriceSummaryState extends State<PriceSummary> {
  String _shippingCost = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var user11 = await Utility.getSharedPreference('USERMARKER1');
    var user12 = await Utility.getSharedPreference('USERMARKER2');
    var map11 = await Utility.getSharedPreference('SEVEN1');
    var map12 = await Utility.getSharedPreference('SEVEN2');
    if (user11 != null && user12 != null && map11 != null && map12 != null){
      var _lastDistance = Geolocator.distanceBetween(
      map11,
      map12,
      user11,
      user12,
    );
    setState(() {
      if (_lastDistance <= 3000) {
        setState(() {
          _shippingCost = '0';
        });
      } else {
        double additionalCost = (_lastDistance - 3000) *
            0.05; // คิดค่าบริการ 0.05 ต่อเมตรหลังจาก 3 กิโลเมตร
        setState(() {
          _shippingCost = additionalCost.toStringAsFixed(2);
        });
      }
    });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล arguments จาก route
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ดึงรายการสินค้าจาก arguments
    final List<Item>? items = arguments?['cartItems'] as List<Item>?;

    // ถ้าไม่มีสินค้า ให้แสดงผลรวมเป็น 0
    if (items == null || items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ค่าส่ง', style: TextStyle(fontSize: 16)),
                Text('$_shippingCost บาท', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ค่าสินค้า', style: TextStyle(fontSize: 16)),
                Text('0 บาท',
                    style:
                        TextStyle(fontSize: 16)), // ลบ const ออกจาก TextStyle
              ],
            ),
            SizedBox(height: 16),
            OrderButton(),
          ],
        ),
      );
    }

    // คำนวณราคารวมของสินค้า
    double totalPrice = items.fold(0.0, (sum, item) => sum + item.price);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ค่าส่ง', style: TextStyle(fontSize: 16)),
              Text('$_shippingCost บาท', style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ราคาสินค้า', style: TextStyle(fontSize: 16)),
              Text('${totalPrice.toStringAsFixed(2)} บาท',
                  style: TextStyle(fontSize: 16)), // ลบ const ออกจาก TextStyle
            ],
          ),
          SizedBox(height: 16),
          OrderButton(),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({super.key});

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  double _scale = 1.0;
  Color _color = Colors.green;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.9;
          _color = Colors.greenAccent;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
          _color = Colors.green;
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
          _color = Colors.green;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scale),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            minimumSize: const Size(150, 50),
            elevation: 0,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('ยืนยันการสั่งซื้อ'),
                  content: const Text('คุณต้องการสั่งซื้อสินค้านี้หรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigator.pushNamed(context, AppRouter.main1);
                      },
                      child: const Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                            context, AppRouter.usersevenmap);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('สั่งซื้อสำเร็จ!')),
                        );
                      },
                      child: const Text('ยืนยัน'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('ถัดไป', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
