import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrcode/qrcode.dart';

class QRCodeScanPage extends StatefulWidget {
  @override
  _QRCodeScanPageState createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRCaptureController controller = QRCaptureController();
  bool flashOn = false;
  bool loading = false;
  CartContext _cartContext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _onQRViewCreated(controller);
  }

  @override
  Widget build(BuildContext context) {
    _cartContext = Provider.of<CartContext>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator("Scan code QR"),
      ),
      backgroundColor: BACKGROUND_COLOR,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            QRCaptureView(
              key: qrKey,
              controller: controller,
              /*overlay: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),*/
            ),
            Container(
              color: Colors.black45,
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                      ),
                    )
                  : null,
            ),
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: TextTranslator(
                AppLocalizations.of(context).translate("center_camera"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                child: Icon(
                  flashOn ? Icons.flash_on : Icons.flash_off,
                ),
                onPressed: () {
                  // controller.toggleFlash();
                  if (flashOn) {
                    controller.torchMode = CaptureTorchMode.off;
                  } else {
                    controller.torchMode = CaptureTorchMode.on;
                  }
                  setState(() {
                    flashOn = !flashOn;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: CRIMSON, borderRadius: BorderRadius.circular(158)),
                child: InkWell(
                  child: Icon(
                    Icons.camera,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
                  },
                ),
              ),
            ),
            Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.width / 1.2,
                    decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(50),
                        border: Border.all(color: Colors.blue, width: 1)),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRCaptureController controller) {
    this.controller = controller;
   /*bool withPrice = !"https://preprod-api.clicar.fr/restaurants/5fde0bc875e5035bf72a8efe/qrcode.png".contains("?option");
    _cartContext.withPrice = withPrice;
    RouteUtil.goTo(
        context: context,
        child: RestaurantPage(
          restaurant: "5fde0bc875e5035bf72a8efe",
          withPrice: withPrice,
        ),
        routeName: restaurantRoute,
        method: RoutingMethod.replaceLast,
      );*/
    controller.onCapture((String scanData) async {
      controller.pause();
      if (!scanData.startsWith(RegExp(r'https://(www\.|)preprod-api.clicar.fr/restaurants/'))) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('invalid_qr_code'),
        );
        controller.resume();
        return;
      }

      setState(() {
        loading = true;
      });
      List<String> datas = scanData.split('/');
      String restaurantId = datas[datas.length - 2];
      
      bool withPrice = !scanData.contains("?option");
      _cartContext.withPrice = withPrice;
      
      RouteUtil.goTo(
        context: context,
        child: RestaurantPage(
          restaurant: restaurantId,
          withPrice: withPrice,
        ),
        routeName: restaurantRoute,
        method: RoutingMethod.replaceLast,
      );
    });
  }

  @override
  void dispose() {
    controller?.pause();
    super.dispose();
  }
}
