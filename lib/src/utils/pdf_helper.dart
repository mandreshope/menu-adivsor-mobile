import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/date_format.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

import '../types.dart';

class PdfHelper {
  List<Food> foods = [
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
  ];
  CommandModel commande;

  PdfHelper(ctx, CommandModel commande) {
    final Document pdf = Document();

    this.commande = commande;

    pdf.addPage(MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PdfColors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: Text(
              'Portable Document Format',
              style: Theme.of(context).defaultTextStyle.copyWith(
                    color: PdfColors.grey,
                  ),
            ),
          );
        },
        footer: (Context context) {
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: Text('Page ${context.pageNumber} of ${context.pagesCount}', style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey)));
        },
        build: (Context context) => <Widget>[_body(ctx)]));

    //getExternalStorageDirectory().then((value) async {

    //});

    _saveFile(pdf, ctx);
  }

  _saveFile(Document pdf, ctx) async {
    String pathToSaveFile = "/storage/emulated/0/MenuAdvisor/";
    final Directory appDirectory = Directory(pathToSaveFile);
    if (!await appDirectory.exists()) {
      var dirTemp = await appDirectory.create(recursive: true);
    }

    String fileName = "${DateTime.now().dateToString(DATE_FORMATED_ddMMyyyyHHmmWithSpacer)}.pdf";
    File file = File("$pathToSaveFile$fileName");
    file.writeAsBytesSync(await pdf.save());
    print("file saved... to $pathToSaveFile$fileName");

    Fluttertoast.showToast(
      msg: "${AppLocalizations.of(ctx).translate('success')} \n$pathToSaveFile$fileName",
    );
  }

  Widget _body(ctx) => Column(
        children: [
          SizedBox(
            height: 25,
          ),
          Text(
            AppLocalizations.of(ctx).translate('summary').toUpperCase(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            commande?.restaurant?.name ?? "",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PdfColor.fromInt(0xffda143c)),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "${DateTime.now().dateToString(DATE_FORMATED_ddMMyyyyHHmmWithSpacer2)}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PdfColors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 25,
          ),
          for (int i = 0; i <= commande.items.length - 1; i++) _items(commande.items[i], i),
          SizedBox(
            height: 15,
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.only(right: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  commande.totalPrice == null ? "_" : "Total : ${commande.totalPrice / 100} eur",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              )),
        ],
      );

  Widget _items(CommandItem item, int position) {
    return Container(
      padding: EdgeInsets.all(10),
      color: position % 2 == 0 ? PdfColor.fromInt(0xffda143c) : PdfColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(width: 120, child: _text(item.food?.name ?? "", position)),
          _text("|", position),
          Container(width: 50, child: _text("${item?.quantity ?? 0}x", position)),
          _text("|", position),
          if (item.food?.price?.amount == null) _text("_", position) else _text("${item.food.price.amount / 100} ${item.food.price?.currency ?? ""}", position),
        ],
      ),
    );
  }

  _text(String value, position) => Text(
        value,
        style: TextStyle(fontSize: 16, color: position % 2 == 0 ? PdfColors.white : PdfColors.black),
      );
}
