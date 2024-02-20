import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제 화면'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 수단 선택',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildPaymentMethodButton('카카오페이'),
            _buildPaymentMethodButton('네이버페이'),
            _buildPaymentMethodButton('토스페이'),
            _buildPaymentMethodButton('신용/체크카드'),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // 선택된 결제 수단에 따라 결제 처리 로직 추가
                if (selectedPaymentMethod.isNotEmpty) {
                  _processPayment(selectedPaymentMethod);
                } else {
                  // 선택된 결제 수단이 없는 경우 처리
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('알림'),
                      content: Text('결제 수단을 선택해주세요.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('확인'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('결제하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(String paymentMethod) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = paymentMethod;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == paymentMethod
                ? Colors.blue
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.payment,
              color: selectedPaymentMethod == paymentMethod
                  ? Colors.blue
                  : Colors.grey,
            ),
            SizedBox(width: 8.0),
            Text(
              paymentMethod,
              style: TextStyle(
                fontSize: 16,
                color: selectedPaymentMethod == paymentMethod
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(String selectedMethod) {
    // 선택된 결제 수단에 따른 처리 로직을 여기에 추가
    // 카카오페이 API 호출, 네이버페이 API 호출 나중에하는부분
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('결제 완료'),
        content: Text('$selectedMethod 결제가 완료되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PaymentPage(),
  ));
}
