import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/geolocation.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/utilities.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_discount_model.dart';
import 'package:menu_advisor/src/pages/map_polyline.dart';
import 'package:menu_advisor/src/pages/photo_view.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';

class Summary extends StatefulWidget {
  Summary({
    Key key,
    @required this.commande,
    this.fromHistory = false,
  }) : super(key: key);
  final Command commande;
  final bool fromHistory;

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
    // final CommandContext commandContext = Provider.of<CommandContext>(
    //   context,
    //   listen: false,
    // );

    if (widget.commande.restaurant is String) {
      Api.instance.getRestaurant(id: widget.commande.restaurant).then((value) {
        widget.commande.restaurant = value;
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
    return WillPopScope(
      onWillPop: () async {
        if (widget.fromHistory) {
          RouteUtil.goBack(context: context);
        } else {
          while (Navigator.canPop(context)) {
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _header(),
                    ),

                    Divider(),
                    // about user
                    if (widget.commande.commandType != 'on_site') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () async {
                            Position currentPosition = await Geolocator.getCurrentPosition();
                            String q = widget.commande.shippingAddress ?? widget.commande.relatedUser["address"];

                            // final geocoding = GoogleMapsGeocoding(apiKey: GOOGLE_API_KEY);
                            final places = new GoogleMapsPlaces(apiKey: GOOGLE_API_KEY);

                            List<Location> locations = [];
                            try {
                              PlacesSearchResponse response = await places.searchByText(q);
                              locations = response.results.map((e) => e.geometry.location).toList();
                            } catch (error) {
                              Fluttertoast.showToast(
                                msg: 'Adresse introvable',
                              );
                              return;
                            }

                            RouteUtil.goTo(
                              context: context,
                              child: MapPolylinePage(
                                restaurant: widget.commande.restaurant,
                                initialPosition: LatLng(currentPosition.latitude, currentPosition.longitude),
                                destinationPosition: LatLng(locations.first.lat, locations.first.lng),
                              ),
                              routeName: restaurantRoute,
                            );
                          },
                          child: TextTranslator(
                            widget.commande.shippingAddress ?? "",
                            style: TextStyle(decoration: TextDecoration.underline, fontSize: 16, color: Colors.blue
                                // color: Colors.blue
                                ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () async {
                            await launch("tel:${widget.commande.restaurant.phoneNumber}");
                          },
                          child: TextTranslator(widget.commande.relatedUser != null ? widget.commande.relatedUser["phoneNumber"] : widget.commande.customer['phoneNumber'],
                              style: TextStyle(decoration: TextDecoration.underline, fontSize: 16, color: Colors.blue)),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (widget.commande.commandType == 'delivery') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () async {
                              // await launch("tel:${widget.commande.restaurant.phoneNumber}");
                            },
                            child: TextTranslator("Appartement : " + widget.commande.appartement,
                                style: TextStyle(
                                  // decoration: TextDecoration.underline,
                                  fontSize: 16,
                                  // color: Colors.blue
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () async {
                              // await launch("tel:${widget.commande.restaurant.phoneNumber}");
                            },
                            child: TextTranslator("Etage : " + widget.commande.etage.toString(),
                                style: TextStyle(
                                  // decoration: TextDecoration.underline,
                                  fontSize: 16,
                                  // color: Colors.blue
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () async {
                              // await launch("tel:${widget.commande.restaurant.phoneNumber}");
                            },
                            child: TextTranslator("Code appartemment : " + widget.commande.codeappartement,
                                style: TextStyle(
                                  // decoration: TextDecoration.underline,
                                  fontSize: 16,
                                  // color: Colors.blue
                                )),
                          ),
                        ),
                      ],
                      Divider(),
                    ],
                    //commande id
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          TextTranslator("Commande ID : "),
                          TextTranslator(widget.commande.code?.toString()?.padLeft(6, '0') ?? "", style: TextStyle(color: CRIMSON, fontWeight: FontWeight.bold, fontSize: 18)),
                          Spacer(),
                          _validated()
                        ],
                      ),
                    ),
                    //end commande id
                    Divider(),
                    // food
                    for (var command in widget.commande.items) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _items(command),
                      ),
                    ],
                    // Divider(),
                    // menu
                    if (widget.commande.menus != null)
                      for (var command in widget.commande.menus) _items(command),
                    if (widget.commande.commandType == 'delivery') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          children: [
                            TextTranslator(
                              'Frais de livraison : ',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Spacer(),
                            Opacity(
                              opacity: 0.6,
                              child: Text(
                                '${widget.commande.priceLivraison ?? 0} €',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: CRIMSON,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                    Visibility(
                      visible: widget.commande?.withCodeDiscount,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextTranslator(
                                  'Remise code promo : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.commande?.restaurant?.discount?.codeDiscount?.discountIsPrice == true
                                      ? '${widget.commande?.restaurant?.discount?.codeDiscount?.valueDouble ?? 0.0} €'
                                      : '${widget.commande?.restaurant?.discount?.codeDiscount?.valueDouble ?? 0.0} % ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (widget.commande.commandType == 'delivery') && (widget.commande?.restaurant?.discount?.delivery?.valueDouble ?? 0.0) > 0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextTranslator(
                                  "Remise ${widget.commande?.restaurant?.discount?.delivery?.discountType == DiscountType.SurTotalite ? "sur la totalité" : widget.commande?.restaurant?.discount?.delivery?.discountType == DiscountType.SurTransport ? "sur le transport" : "sur la commande"}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.commande?.restaurant?.discount?.delivery?.discountIsPrice == true
                                      ? '${widget.commande?.restaurant?.discount?.delivery?.valueDouble ?? 0.0} €'
                                      : '${widget.commande?.restaurant?.discount?.delivery?.valueDouble ?? 0.0} % ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (widget.commande.commandType == 'takeaway') && (widget.commande?.restaurant?.discount?.aEmporter?.valueDouble ?? 0.0) > 0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextTranslator(
                                  'Remise des plat à emporter : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.commande?.restaurant?.discount?.aEmporter?.discountIsPrice == true
                                      ? '${widget.commande?.restaurant?.discount?.aEmporter?.valueDouble ?? 0.0} €'
                                      : '${widget.commande?.restaurant?.discount?.aEmporter?.valueDouble ?? 0.0} % ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          TextTranslator(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          widget.commande.priceless
                              ? Text(" ")
                              : Text(
                                  '${widget.commande.totalPrice / 100} €',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CRIMSON,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    if (widget.commande.commandType == 'delivery') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextTranslator(
                              "Option de livraison",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            TextTranslator(widget.commande.optionLivraison == 'behind_the_door'
                                ? 'Devant la porte'
                                : widget.commande.optionLivraison == 'on_the_door'
                                    ? 'Rdv à la porte'
                                    : "A l'exterieur")
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextTranslator(
                              "Mode de paiement",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            TextTranslator('${widget.commande.paiementLivraison ? "A la livraison" : "CB"}')
                          ],
                        ),
                      ),
                    ],
                    Divider(),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextTranslator(
                        "Commentaire",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.underline),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _renderComment(widget.commande.comment),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              RouteUtil.goTo(
                  context: context,
                  child: PhotoViewPage(
                    tag: 'tag:${widget.commande.restaurant.logo}',
                    img: widget.commande.restaurant.logo,
                  ),
                  routeName: null);
            },
            child: Image.network(
              widget.commande.restaurant.logo ?? "",
              // width: 4 * MediaQuery.of(context).size.width / 7,
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.width / 4,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.fastfood,
                  size: MediaQuery.of(context).size.width / 4,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextTranslator(
                widget.commande.restaurant.originName,
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
                  InkWell(
                    onTap: () async {
                      Position currentPosition = await Geolocator.getCurrentPosition();
                      var coordinates = widget.commande.restaurant.location.coordinates;
                      // MapUtils.openMap(currentPosition.latitude, currentPosition.longitude,
                      // coordinates.last,coordinates.first);
                      RouteUtil.goTo(
                        context: context,
                        child: MapPolylinePage(
                          restaurant: widget.commande.restaurant,
                          initialPosition: LatLng(currentPosition.latitude, currentPosition.longitude),
                          destinationPosition: LatLng(coordinates.last, coordinates.first),
                        ),
                        routeName: restaurantRoute,
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: TextTranslator(
                        widget.commande.restaurant.address ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, decoration: TextDecoration.underline, color: Colors.blue),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
                onTap: () async {
                  if (widget.commande.restaurant.phoneNumber != null) await launch("tel:${widget.commande.restaurant.phoneNumber}");
                },
              ),
            ],
          ),
          Spacer(),
          widget.fromHistory
              ? Stack(
                  children: [
                    CircleButton(
                      backgroundColor: CRIMSON,
                      onPressed: () {
                        showDialog<String>(
                            context: context,
                            builder: (_) => MessageDialog(
                                  message: message,
                                )).then((value) async {
                          print(value);
                          //widget.food.message = value;

                          if (value.isNotEmpty) {
                            User user = Provider.of<AuthContext>(
                              context,
                              listen: false,
                            ).currentUser;
                            Message message = Message(
                                email: user.email, message: value, name: "${user.name.first} ${user.name.last}", phoneNumber: user.phoneNumber, read: false, target: widget.commande.restaurant.admin);
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => Center(
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
                            if (result) {
                              Fluttertoast.showToast(
                                msg: "Message envoyé",
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: "Message non envoyé",
                              );
                            }
                          } else {
                            setState(() {
                              hasMessage = false;
                            });
                          }
                        });
                      },
                      child: Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    Visibility(
                      visible: hasMessage,
                      child: Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.brightness_1,
                            color: Color(0xff62C0AB),
                            size: 12,
                          )),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  Widget _items(CommandItem commandItem) {
    dynamic item = commandItem.food != null ? commandItem.food : commandItem.menu;
    List<Option> options = commandItem.options;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextTranslator('${commandItem.quantity}x', style: TextStyle(fontSize: 16)),
              SizedBox(width: 15),
              InkWell(
                onTap: () {
                  RouteUtil.goTo(
                      context: context,
                      child: PhotoViewPage(
                        tag: 'tag:${item.imageURL}',
                        img: item.imageURL,
                      ),
                      routeName: null);
                },
                child: Image.network(
                  item.imageURL ?? "",
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.fastfood,
                      size: 40,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              TextTranslator('${item.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Spacer(),
              item.isMenu
                  ? widget.commande.priceless || item.type == MenuType.per_food.value || item.type == MenuType.priceless.value
                      ? Text(" ")
                      : item.price?.amount == null
                          ? Text("_")
                          : Text(
                              "${item.price.amount / 100} €",
                              style: TextStyle(fontSize: 16),
                            )
                  : widget.commande.priceless
                      ? Text(" ")
                      : item.price?.amount == null
                          ? Text("_")
                          : Text(
                              "${item.price.amount / 100} €",
                              style: TextStyle(fontSize: 16),
                            ),
            ],
          ),
        ),
        Divider(),
        if (item is Food)
          for (int i = 0; i < options.length; i++) ...[
            Container(
              // color: (options.length/quantity) <   ? Colors.grey.withAlpha(100) : Colors.white,
              padding: EdgeInsets.only(top: 15, bottom: 15, left: MediaQuery.of(context).size.width / 2.5, right: 0),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // SizedBox(width: 150),
                        TextTranslator('${options[i].title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  for (ItemsOption itemsOption in options[i].items) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // SizedBox(width: 150),
                        if (itemsOption.quantity != null && itemsOption.quantity > 0) Text("${itemsOption.quantity}x\t", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap: () {
                            RouteUtil.goTo(
                                context: context,
                                child: PhotoViewPage(
                                  tag: 'tag:${itemsOption.item.imageUrl}',
                                  img: itemsOption.item.imageUrl,
                                ),
                                routeName: null);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/loading.gif',
                              image: itemsOption.item.imageUrl ?? "",
                              height: 35,
                              width: 35,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (_, __, ___) => Container(
                                width: 35,
                                height: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 5,
                        ),
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
                          itemsOption.item.price.amount == null ? Text("") : TextTranslator('${itemsOption.item.price.amount / 100} €', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
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
          for (FoodSelectedFromCommandMenu food in commandItem.foodMenuSelected) ...[_renderMenus(food)]
      ],
    );
  }

  Widget _validated() {
    Color color;
    String title = "";
    if (!widget.commande.validated && !widget.commande.revoked) {
      title = "En attente";
      color = Colors.orange;
    } else if (widget.commande.validated) {
      title = "Valider";
      color = TEAL;
    } else if (widget.commande.revoked) {
      title = "Refuser";
      color = CRIMSON;
    } else {
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
                InkWell(
                  onTap: () {
                    RouteUtil.goTo(
                        context: context,
                        child: PhotoViewPage(
                          tag: 'tag:${item.food.imageURL}',
                          img: item.food.imageURL,
                        ),
                        routeName: null);
                  },
                  child: Image.network(
                    item.food.imageURL ?? "",
                    width: 35,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 35,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                TextTranslator('${item.food.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Spacer(),
                if (item.food.type == MenuType.fixed_price.value) ...[
                  Text(" ")
                ] else ...[
                  widget.commande.priceless
                      ? Text(" ")
                      : item.food.price?.amount == null
                          ? Text("_")
                          : Text("${item.food.price.amount / 100} €", style: TextStyle(fontSize: 16)),
                ]
              ],
            ),
          ),
          Divider(),
          for (Option option in item.options) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 150),
                TextTranslator('${option.title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 5),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            for (ItemsOption itemsOption in option.items) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 150),
                  if (itemsOption.quantity != null && itemsOption.quantity > 0) Text("${itemsOption.quantity}x\t", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      RouteUtil.goTo(
                          context: context,
                          child: PhotoViewPage(
                            tag: 'tag:${item.food.imageURL}',
                            img: item.food.imageURL,
                          ),
                          routeName: null);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: itemsOption.item.imageUrl,
                        height: 20,
                        width: 20,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (_, __, ___) => Container(
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  TextTranslator('${itemsOption.item.name}', style: TextStyle(fontSize: 16)),
                  Spacer(),
                  if (widget.commande.priceless)
                    Text("")
                  else
                    itemsOption.item.price.amount == null ? Text("") : TextTranslator('${itemsOption.item.price.amount / 100} €', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
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
        child: TextTranslator(
          comment,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.grey, fontStyle: FontStyle.normal),
          textAlign: TextAlign.justify,
        ),
      );
}
