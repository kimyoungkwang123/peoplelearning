import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Purchase history-api.dart';

class BuyPage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  BuyPage({required this.userInfo});

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  List<Payment> purchases = []; // 결제 내역을 저장할 리스트

  @override
  void initState() {
    super.initState();
    _fetchPurchaseHistory(); // 초기화 단계에서 결제 내역을 불러옵니다.
  }

  Future<void> _fetchPurchaseHistory() async {
    try {
      final List<Payment> fetchedPurchases =
          await fetchPurchaseHistory(widget.userInfo?['userEmail']);
      setState(() {
        purchases = fetchedPurchases;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 최신 구매 기록 순으로 정렬
    purchases.sort((a, b) => b.payment_Date.compareTo(a.payment_Date));

    return Scaffold(
      appBar: AppBar(
        title: Text('구매 내역'),
      ),
      body: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          // 첫 번째 구매 기록인 경우 isFirstRecord를 true로 전달
          bool isFirstRecord = index == 0 ||
              purchases[index].payment_Date !=
                  purchases[index - 1].payment_Date;
          return _buildPurchaseItem(purchases[index], isFirstRecord);
        },
      ),
    );
  }

  Widget _buildPurchaseItem(Payment payment, bool isFirstRecord) {
    // 시간 정보를 제거하고 년도, 월, 일만 가져오기
    String formattedDate =
        DateFormat('yy년 MM월 dd일').format(payment.payment_Date);

    return Container(
      margin: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 구매 기간 (첫 번째 기록만 표시)
          if (isFirstRecord)
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '${formattedDate}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          // 이미지, 강의 제목, 가격
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12.0),
              title: Row(
                children: [
                  // 이미지
                  Image.asset(
                    'assets/image/${payment.Lecture_image_URL}',
                    width: 75.0,
                    height: 110.0,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 8.0), // 이미지와 강의 정보 간격 조절

                  // 강의 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.lectureTitle,
                          style: TextStyle(fontSize: 25),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          '가격: ${payment.price}원',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider 추가: 구매 기록 간에 구분선
          Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }
}
