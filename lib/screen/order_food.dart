import 'dart:convert';
// @dart=2.9
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rrs_app/model/cart_model.dart';
import 'package:flutter_rrs_app/model/food_menu_model.dart';
import 'package:flutter_rrs_app/model/read_shop_model.dart';
import 'package:flutter_rrs_app/model/table_model.dart';
import 'package:flutter_rrs_app/screen/cart_orderfood.dart';
import 'package:flutter_rrs_app/screen/payment_method.dart';
import 'package:flutter_rrs_app/utility/my_constant.dart';
import 'package:flutter_rrs_app/utility/my_style.dart';
import 'package:flutter_rrs_app/utility/normal_dialog.dart';
import 'package:flutter_rrs_app/utility/sqlite_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'show_cart.dart';

class OrderFood extends StatefulWidget {
  final ReadshopModel readshopModel;

  OrderFood({
    Key? key,
    required this.readshopModel,
  }) : super(key: key);
  @override
  _OrderFoodState createState() => _OrderFoodState();
}

class _OrderFoodState extends State<OrderFood> {
  ReadshopModel? readshopModel;
  TableModel? tableModel;
  String? restaurantId;
  int amount = 1;

  String? customerId, restaurantNameshop;
  List<FoodMenuModel> foodmenuModels = [];

  @override
  void initState() {
    super.initState();
    readshopModel = widget.readshopModel;
    restaurantNameshop = readshopModel!.restaurantNameshop;
    readFoodMenu();
  }

//อ่านข้อมูลเมนูอาหารจากฐานข้อมูล
  Future<Null> readFoodMenu() async {
    restaurantId = readshopModel!.restaurantId;
    String url =
        '${Myconstant().domain_00webhost}/getFoodmenuWhererestaurantId.php?isAdd=true&restaurantId=$restaurantId';
    await Dio().get(url).then((value) {
      print('res==> $value');
      if (value.statusCode == 200) {
        var result = json.decode(value.data);
        print('result= $result');
        for (var map in result) {
          FoodMenuModel foodMenuModel = FoodMenuModel.fromJson(map);
          setState(() {
            foodmenuModels.add(foodMenuModel);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: kprimary,
        child: Icon(
          Icons.shopping_cart_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CartOrderfood(readshopModel: readshopModel!)));
        },
      ),
      appBar: AppBar(
        backgroundColor: kprimary,
        title: Text('Select menu'),
      ),
      body: foodmenuModels.length == 0
          ? MyStyle().showProgrsee()
          : ListView.builder(
              itemCount: foodmenuModels.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  print('You Click  index = $index');
                  amount = 1;
                  confirmOrder(index);
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        showFoodMenuImage(context, index),
                        Flexible(
                          child: Container(
                            width: double.infinity,
                            //height: MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                              0.5 -
                                          8.0,
                                      child: foodmenuModels[index]
                                                  .foodMenuIdBuyOne ==
                                              null
                                          ? Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    foodmenuModels[index]
                                                        .foodmenuName!,
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        color:
                                                            Colors.blue[800]),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${foodmenuModels[index].foodmenunameBuyOne} + ${foodmenuModels[index].foodmenunameGetOne}',
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        color:
                                                            Colors.blue[800]),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    )
                                  ],
                                ),
                                //show price food
                                Row(
                                  children: [
                                    foodmenuModels[index].promotion_id == null
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4 -
                                                8.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  'price',
                                                  style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      color: Colors.grey[800]),
                                                ),
                                                Text(
                                                  foodmenuModels[index]
                                                      .foodmenuPrice!,
                                                  style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      color: Colors.green[800]),
                                                ),
                                                Text("K",
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        color: Colors.grey[800],
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough))
                                              ],
                                            ))
                                        : Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4 -
                                                8.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  'price ',
                                                  style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      color: Colors.blue[800]),
                                                ),
                                                Text(
                                                  foodmenuModels[index]
                                                      .promotionOldPrice!,
                                                  style: GoogleFonts.lato(
                                                      fontSize: 14,
                                                      color: Colors.grey[800],
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      decorationColor:
                                                          Colors.red,
                                                      decorationThickness: 3),
                                                ),
                                                Text("K",
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        color: Colors.grey[800],
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough))
                                              ],
                                            ))
                                  ],
                                ),
                                Column(
                                  children: [
                                    foodmenuModels[index].promotion_id == null
                                        ? Text("")
                                        : Row(
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.4 -
                                                      8.0,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        'price ',
                                                        style: GoogleFonts.lato(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .green[800]),
                                                      ),
                                                      Text(
                                                        foodmenuModels[index]
                                                            .promotionNewPrice!,
                                                        style: GoogleFonts.lato(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .green[800]),
                                                      ),
                                                      Text("K",
                                                          style: GoogleFonts.lato(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .grey[800],
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough))
                                                    ],
                                                  ))
                                            ],
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4 -
                                          8.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.add_circle_rounded,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey[200],
                      thickness: 10,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

//เเสดงรูปเมนูอาหารจากฐานข้อมูล
  Padding showFoodMenuImage(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                image: NetworkImage(
                  '${Myconstant().domain_foodPic}${foodmenuModels[index].foodmenuPicture!}',
                ),
                fit: BoxFit.cover)),
      ),
    );
  }

//ยืนยันการเลือกเมนูอาหารที่เราต้องการสั่ง
  Future<Null> confirmOrder(int index) async {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        foodmenuModels[index].foodMenuIdBuyOne == null
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.6 -
                                    8.0,
                                child:
                                    Text(foodmenuModels[index].foodmenuName!))
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.6 -
                                    8.0,
                                child: Text(
                                    '${foodmenuModels[index].foodmenunameBuyOne} + ${foodmenuModels[index].foodmenunameGetOne} '),
                              )
                      ],
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 150,
                      height: 130,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image: NetworkImage(
                                  '${Myconstant().domain_foodPic}${foodmenuModels[index].foodmenuPicture!}'),
                              fit: BoxFit.cover)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (amount > 1) {
                              setState(() {
                                amount--;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          iconSize: 30,
                        ),
                        Text(amount.toString()),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              amount++;
                            });
                          },
                          icon: Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          iconSize: 30,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 90,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)))),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancle')),
                          ),
                          Container(
                            width: 90,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)))),
                                onPressed: () {
                                  Navigator.pop(context);
                                  addOrder(index);
                                  // recordOrderfood(index);
                                },
                                child: Text('Order')),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

//insert ข้อมูลรายการสั่งอาหารไปที่ฐานข้อมูล sqlite
  Future<Null> addOrder(int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? customerId = preferences.getString("customerId");
    String? restaurantNameshop = readshopModel!.restaurantNameshop;
    String? foodmenuId = foodmenuModels[index].foodmenuId;
    String? foodmenuName = foodmenuModels[index].foodMenuIdBuyOne == null
        ? foodmenuModels[index].foodmenuName
        : '${foodmenuModels[index].foodmenunameBuyOne} + ${foodmenuModels[index].foodmenunameGetOne}';
    String? foodmenuPrice = foodmenuModels[index].promotion_id == null
        ? foodmenuModels[index].foodmenuPrice
        : foodmenuModels[index].promotionNewPrice;
    int priceInt = int.parse(foodmenuPrice!);
    int netPrice = priceInt * amount;
    //print('foodmenu price==>$foodmenuPrice');
    //print(
    // 'customerId = $customerId,restaurantId = $restaurantId,restaurantNameshop =$restaurantNameshop,foodmenuId =$foodmenuId,foodmenuName =$foodmenuName,foodmenuPrice =$foodmenuPrice,amount =$amount ,netPrice =$netPrice');
    Map<String, dynamic> map = Map();

    map['restaurantId'] = restaurantId;
    map['restaurantNameshop'] = restaurantNameshop;
    map['foodmenuId'] = foodmenuId;
    map['foodmenuName'] = foodmenuName;
    map['foodmenuPrice'] = foodmenuPrice;
    map['amount'] = amount.toString();
    map['netPrice'] = netPrice.toString();
    // print('map ==> ${map.toString()}');
    CartModel cartModel = CartModel.fromJson(map);

    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object  lenght=${object.length}');
    if (object.length == 0) {
      await SQLiteHelper().insertDataToSQLite(cartModel).then((value) {
        print('Insert Success');
        showToast('Insert Success');
      });
    } else {
      String? restaurantIdSQLite = object[0].restaurantId;
      // print('restaurantIdSQLite ==> $restaurantIdSQLite');
      if (restaurantId == restaurantIdSQLite) {
        await SQLiteHelper().insertDataToSQLite(cartModel).then((value) async {
          // print('restaurantIdSQLite ==> $restaurantIdSQLite');
        });
      } else {
        normalDialog(context,
            'ตะกร้ามี รายการอาหารของ ร้าน ${object[0].restaurantNameshop} กรุณา ซื้อจากร้านนี่ให้ จบก่อน คะ');
      }
    }
  }

//เเสดงToast ในหน้าจอตามที่เรากำหนดข้อความ
  Future<bool?> showToast(String string) {
    return Fluttertoast.showToast(
        msg: string,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 5,
        backgroundColor: kprimary,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
