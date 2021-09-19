import 'dart:convert';
import 'package:hro/model/AppConfigModel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/ratingModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cartModel.dart';
import 'locationSetupModel.dart';

class AppDataModel {
  var moneyFormat = NumberFormat('#,###', 'en_US');
  var distanceFormat = NumberFormat('#0.0#', 'en_US');

  var dateShowFormat = DateFormat("dd/MM/yyyy");
  var dateSystemFormat = DateFormat("yyyy-MM-dd");

  String loginLevel = "1";

  bool locationStatus = false;

  double screenW;
  String os;
  double appVersion, serverVersion;
  double centerLat,
      centerLng,
      userLat,
      userLng,
      shopLat,
      shopLng,
      riderLat,
      riderLng;
  AppConfigModel appConfigModel;
  UserOneModel userOneModel;

  List<UserListModel> alluserData;
  List<DriversListModel> allRiderData;
  List<ProductsModel> allProductData;

  Color cols = Color.fromARGB(1, 34, 150, 243);
  String playStoreUrl =
      "https://play.google.com/store/apps/details?id=hroth.hro";

  String projectVersion;
  double distanceLimit;
  int costDelivery;
  int allProductCurrentPage;

  String qrAmount;

  String ratingOrderId, ratingShopId, ratingRiderId, ratingCustomerId;
  String noTiServer = 'https://us-central1-hro-authen.cloudfunctions.net/hello';
  String notifyServer =
      "https://us-central1-hro-authen.cloudfunctions.net/hello/notify";
  String qrGenServer = "https://qrgen.paystationth.com/";

  //location and costDelivery Setup
  LocationSetupModel locationSetupModel;

  List<AllShopModel> allShopAdminList;

  String adminToken = "";

  List<RatingListModel> shopRatingList;
  List<RatingListModel> riderRatingList;

  String productEditId;

  //-----profile Data--------
  String profileEmail;
  String profileName;
  String profileUid;
  String profilePhotoUrl;
  String profilePhone;
  String profileProvider;
  String profileLocation;
  String profileStatus;

  String loginProvider;
  bool profilePhoneVerify = false;
  bool profileEmailVerify = false;

  //-----shop Data-------------
  String shopName;
  String shopType;
  String shopPhotoUrl;
  String shopPhone;
  String shopAddress;
  String shopLocation;
  String shopTime;
  String shopStatus;

  //-----allShop----
  List<AllShopModel> allShopData;
  List<AllShopModel> allFullShopData;

//----product Model
  List<ProductsModel> productsData;
  List<ProductsModel> allProductsData;

//----driVers Data
  DriversModel driverData;

//-----productSelect
  String productSelectId;

  List<CartModel> currentOrder = [];
  int allPcs = 0;
  int allPrice = 0;

  String orderAddressComment = "";

  //---storeData
  String storeSelectId;
  ShopModel currentShopSelect;
  List<ProductsModel> storeProductsData;

  bool shopOpen;

  String lastPage;

  //----Order
  String _orderIdSelected;

  String get orderIdSelected => _orderIdSelected;

  set orderIdSelected(String orderIdSelected) {
    _orderIdSelected = orderIdSelected;
  }

  //---location
  double latStart = 17.591244;
  double lngStart = 103.979989;
  double latYou;
  double lngYou;
  double latShop;
  double lngShop;

  double latOrder;
  double lngOrder;

  String _distanceDelivery;

  String get distanceDelivery => _distanceDelivery;

  set distanceDelivery(String distanceDelivery) {
    _distanceDelivery = distanceDelivery;
  }

  //Notification
  String _token;

  String get token => _token;

  set token(String token) {
    _token = token;
  }
}
