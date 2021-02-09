import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/splash.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';

class Summary extends StatefulWidget {
  Summary({@required this.commande, this.fromHistory = false});
  Command commande;
  bool fromHistory;
  

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  BuildContext context;

  bool isLoading = true;
  bool hasMessage = false;

  String message = "";

  @override
  Widget build(BuildContext context) {
    this.context = context;

    if (widget.commande.restaurant is String) {
      Api.instance.getRestaurant(id: widget.commande.restaurant).then((value) 
     {
       widget.commande.restaurant = value;
       setState(() {
         isLoading = false;
       });
       
     });
    }else{
      setState(() {
         isLoading = false;
       });
    }

    return WillPopScope(
      onWillPop: () async {
        if (widget.fromHistory) {
          RouteUtil.goBack(context: context);
        }else{
          while(Navigator.canPop(context)){
            RouteUtil.goBack(context: context);
          }
        }
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: TextTranslator(
              AppLocalizations.of(context).translate('summary'),
            ),
          ),
          body: isLoading ? Center(
            child:CircularProgressIndicator()
          ) :
           SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  Divider(),
                  _header(),
                  Divider(),
                  //commande id
                  Row(
                    children: [
                      TextTranslator("Commande ID : "),
                      TextTranslator(widget.commande.code?.toString()?.padLeft(6,'0') ?? "", style: TextStyle(color: CRIMSON, fontWeight: FontWeight.bold, fontSize: 18)),
                      Spacer(),
                      _validated()
                    ],
                  ),
                  //end commande id
                  Divider(),
                  // food
                  for (var command in widget.commande.items)
                    _items(command),
                  // Divider(),
                  // menu
                  if (widget.commande.menus != null)
                  for (var command in widget.commande.menus) _items(command),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        TextTranslator('Total', style: TextStyle(fontSize: 16)),
                        Spacer(),
                        widget.commande.priceless ? Text(" ") : Text('${widget.commande.totalPrice / 100} €', style: TextStyle(fontSize: 16, color: CRIMSON, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextTranslator(
                          AppLocalizations.of(context).translate(widget.commande.commandType ?? 'on_site').toUpperCase(),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        TextTranslator('${widget.commande.shippingTime == null ? "" : widget.commande.shippingTime.dateToString("dd/MM/yyyy HH:mm")}')
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 30,),
                  TextTranslator("Commentaire",
                    style:TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.underline

                    ),

                  ),
                  SizedBox(height: 5,),
                  _renderComment(widget.commande.comment),
                  SizedBox(height: 50,)
                ],
              ),
            ),
          )),
    );
  }

  _header() {
    
    return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.commande.restaurant.imageURL ?? "",
              // width: 4 * MediaQuery.of(context).size.width / 7,
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.width / 4,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextTranslator(
                  widget.commande.restaurant.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      FontAwesomeIcons.mapMarkerAlt,
                      size: 15,
                      color: CRIMSON,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width/2.5,
                      child: TextTranslator(
                        widget.commande.restaurant.address ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                InkWell(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.phoneAlt,
                                            size: 15,
                                            color: CRIMSON,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          TextTranslator(
                                            "${widget.commande.restaurant.phoneNumber ?? "0"}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue,
                                              decoration: TextDecoration.underline,),
                                            
                                          )
                                        ],
                                      ),
                                      onTap: () async {
                                        if (widget.commande.restaurant.phoneNumber != null)
                                          await launch(
                                              "tel:${widget.commande.restaurant.phoneNumber}");
                                      },
                                    ),
              ],
            ),
            Spacer(),
            widget.fromHistory ? Stack(
                  children: [
                    
                    CircleButton(
  
                    backgroundColor: CRIMSON,
                    onPressed: (){
                      showDialog<String>(context: context,
                      child: MessageDialog(message: message,)).then((value) async {
                          print(value);
                          //widget.food.message = value;
                       
                        if (value.isNotEmpty){
                             User user =  Provider.of<AuthContext>(
                              context,
                              listen: false,
                            ).currentUser;
                          Message message = Message(email: user.email,message: value,name: "${user.name.first} ${user.name.last}", phoneNumber: user.phoneNumber,read: false,
                          target: widget.commande.restaurant.admin);
                          showDialog(
                            barrierDismissible: false,
                            context: context,child: Center(
                            child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  CRIMSON,
                                                ),
                                              ),
                          ));
                          bool result = await Api.instance.sendMessage(message);
                          RouteUtil.goBack(context: context);
                            setState(() {
                              this.message = value;
                              hasMessage = true;
                            });
                            if (result){
                                Fluttertoast.showToast(
                                    msg: "Message envoyé",
                                  );
                            }else{
                                Fluttertoast.showToast(
                                    msg: "Message non envoyé",
                                  );
                            }
                            
                          }else{
                            setState(() {
                              hasMessage = false;
                            });
                          }
                        }   
                      );
                    },
                    child: Icon(Icons.comment,
                        color: Colors.white,
                        size: 15,),
                        
                  ),
                  Visibility(
                    visible: hasMessage,
                             child: Positioned(
                        right: 0,
                        bottom: 0,
                        child:  Icon(
                                        Icons.brightness_1,
                                        color: Color(0xff62C0AB),
                                        size: 12,
                                      )
                      ),
                  ),
                  ],
              ) :
              Container()
          ],
        ),
      );
  }

  Widget _items(CommandItem commandItem) {
    dynamic item = commandItem.food != null ? commandItem.food : commandItem.menu;
    List<Option> options = commandItem.options;
    int quantity = commandItem.quantity;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextTranslator('${commandItem.quantity}', style: TextStyle(fontSize: 16)),
              SizedBox(width: 15),
              Image.network(
                item.imageURL,
                width: 25,
              ),
              SizedBox(width: 8),
              TextTranslator('${item.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Spacer(),
              widget.commande.priceless ? Text(" ") : item.price?.amount == null ? Text("_") : Text("${item.price.amount / 100} €", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        Divider(),
        if (item is Food)
        for (int i = 0; i < options.length; i++)...[
          Container(
            // color: (options.length/quantity) <   ? Colors.grey.withAlpha(100) : Colors.white,
            padding: EdgeInsets.only(top:15,bottom: 15,left: MediaQuery.of(context).size.width/2.5,right: 0),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // SizedBox(width: 150),
                      TextTranslator('${options[i].title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      // TextTranslator('(x${option.items.length})', style: TextStyle(fontSize: 16)),
                      /*Image.network(
                          item.imageURL,
                          width: 25,
                        ),*/
                      // SizedBox(width: 8),

                      // Spacer(),
                      // item.price?.amount == null ? Text("_") : Text("${item.price.amount / 100} €", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 5,),
                for (ItemsOption itemsOption in options[i].items)...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // SizedBox(width: 150),
                      if (itemsOption.quantity != null && itemsOption.quantity > 0)
                        Text("${itemsOption.quantity} x\t",
                        style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      TextTranslator('${itemsOption.item.name}', style: TextStyle(fontSize: 16)),
                      Spacer(),
                      /*Image.network(
                        item.imageURL,
                        width: 25,
                      ),*/
                      // SizedBox(width: 8),
                      if (itemsOption.item.price == 0 || widget.commande.priceless)
                        Text("")
                      else
                        itemsOption.item.price.amount == null ? Text("") : TextTranslator('${itemsOption.item.price.amount/100} €', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                      // Spacer(),
                      // item.price?.amount == null ? Text("_") : Text("${item.price.amount / 100} €", style: TextStyle(fontSize: 16)),
                    ],
                  ),

                ],

              ],
            ),
          ),
          Divider(),
        ]
        else
        for (FoodSelectedFromCommandMenu food in commandItem.foodMenuSelected)...[
           _renderMenus(food)
        ]
      ],
    );
  }
  Widget _validated() {
    Color color;
    String title = "";
    if (!widget.commande.validated && !widget.commande.revoked){
      title = "En attente";
      color = Colors.orange;
    }else if (widget.commande.validated){
      title = "Valider";
      color = TEAL;
    }else if (widget.commande.revoked){
      title = "Refuser";
      color = CRIMSON;
    }else{
      title = "En attente";
      color = Colors.orange;
    }


    return Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                        color: color,
                      ),
                      child: TextTranslator(
                        title,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    );
  }

 Widget _renderMenus(FoodSelectedFromCommandMenu item) {
       return Padding(
         padding: const EdgeInsets.only(left: 80),
         child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 15),
                    Image.network(
                      item.food.imageURL,
                      width: 25,
                    ),
                    SizedBox(width: 8),
                    TextTranslator('${item.food.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Spacer(),
                    if (item.food.type == MenuType.fixed_price.value)...[
                      Text(" ")
                    ]else...[
                      widget.commande.priceless ? Text(" ") : item.food.price?.amount == null ? Text("_") : Text("${item.food.price.amount / 100} €", style: TextStyle(fontSize: 16)),
                    ]

                  ],
                ),
              ),
              Divider(),
              for (Option option in item.options)...[
              Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 150),
                            TextTranslator('${option.title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                             SizedBox(width: 5),
                             ],
                        ),
                      SizedBox(height: 5,),
                      for (ItemsOption itemsOption in option.items)...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 150),

                            if (itemsOption.quantity != null && itemsOption.quantity > 0)
                              Text("${itemsOption.quantity} x\t",
                                  style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/loading.gif',
                                image: itemsOption.item.imageUrl,
                                height: 20,
                                width: 20,
                                fit: BoxFit.cover,

                              ),
                            ),
                            SizedBox(width: 5,),
                            TextTranslator('${itemsOption.item.name}', style: TextStyle(fontSize: 16)),
                            Spacer(),
                            if (itemsOption.item.price == 0 || widget.commande.priceless)
                              Text("")
                            else
                              itemsOption.item.price.amount == null ? Text("") : TextTranslator('${itemsOption.item.price.amount/100} €', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                            ],
                        ),
                       
                      ],
                       Divider(),
              ]

            ],
          ),
       );
 }

Widget _renderComment(String comment) => Container(
  padding: EdgeInsets.all(15),
  child: TextTranslator(comment,
    style:TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      color: Colors.grey,
      fontStyle: FontStyle.normal
    ),
    textAlign: TextAlign.justify,
  ),
);

  /*Widget _options() {
    // int i = 0;
    List<Option> options = _cartContext.options[widget.food.id]
        .expand((element) => element)
        .toList();
    var o = _cartContext.options[widget.food.id];
    return Container(
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/4),
      child: Column(
        children: [
          for (int a=0;a<o.length;a++)...[
            Container(
              padding: EdgeInsets.only(top:15,bottom: 15),
              color: a%2 == 0 ? Colors.grey.withAlpha(50) : Colors.white,
              child: Column(
                children: [
                  for (Option option in o[a])...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 15),
                        TextTranslator('${option.title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black,decoration: TextDecoration.underline)),
                        SizedBox(width: 5),
                      ],
                    ),
                    SizedBox(height: 15,),
                    for (ItemsOption itemsOption in option.itemOptionSelected)...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 15),
                          TextTranslator('${itemsOption.name}', style: TextStyle(fontSize: 16)),
                          Spacer(),
                          /*Image.network(
                          item.imageURL,
                          width: 25,
                        ),*/
                          // SizedBox(width: 8),
                          if (itemsOption.price == 0 || widget.withPrice)
                            Text("")
                          else
                            itemsOption.price.amount == null ? Text("") : TextTranslator('${itemsOption.price.amount/100} €', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                          // Spacer(),
                          // item.price?.amount == null ? Text("_") : Text("${item.price.amount / 100} €", style: TextStyle(fontSize: 16)),
                        ],
                      ),

                    ],
                    // Divider(),
                  ]
                ],
              ),
            ),
            // Divider()
          ]
        ],
      ),
    );
    // for (int a=0;a<o.length;a++){
    return Container(
      child: Column(
        children: [

          for (int i = 0; i < options.length;i++) ...[

            Container(
              color: (((i)%o.length-2))%o.length == 0 ? CRIMSON : Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 150),
                  TextTranslator('${options[i].title}',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  // TextTranslator('(x${option.items.length})', style: TextStyle(fontSize: 16)),
                  /*Image.network(
                            item.imageURL,
                            width: 25,
                          ),*/
                  // SizedBox(width: 8),

                  // Spacer(),
                  // item.price?.amount == null ? Text("_") : Text("${item.price.amount / 100} €", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            for (ItemsOption itemsOption
            in options[i].itemOptionSelected) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 150),
                  TextTranslator('${itemsOption.name}',
                      style: TextStyle(fontSize: 16)),
                  Spacer(),
                  /*Image.network(
                          item.imageURL,
                          width: 25,
                        ),*/
                  // SizedBox(width: 8),
                  if (itemsOption.price == 0 || !widget.withPrice)
                    Text("")
                  else
                    itemsOption.price.amount == null
                        ? Text("")
                        : TextTranslator(
                        '${itemsOption.price.amount / 100} €',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal)),
                  // Spacer(),
                  // item.price?.amount == null ? Text("_") : Text("${item.price.amount / 100} €", style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
            Divider(),
          ]
        ],
      ),
    );

    // }

  }*/

}
