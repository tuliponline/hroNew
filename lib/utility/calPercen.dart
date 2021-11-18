calVat(int number) {
  double vat = 0.0;
  int vatFinal = 0;
  vat = (7 / 100 * number);
  vatFinal = vat.ceil();
  return vatFinal;
}

calPercen(int number, percen) {
  double vat = 0.0;
  int vatFinal = 0;
  vat = (percen / 100 * number);
  vatFinal = vat.floor();
  return vatFinal;
}

calDiscount(String normalNumber, discount) {
  int discountPrice = 0;
  int discountCal = 0;
  int _discountValue = int.parse(discount);
  int _normalPrice = int.parse(normalNumber);
  discountCal = calPercen(_normalPrice, _discountValue);
  discountPrice = _normalPrice - discountCal;
  print("discountPrice = " + discountPrice.toString());

  return [discountPrice, discountCal];
}

calDiscountAllPrice(String normalNumber, discount) {
  int discountPriceOri = 0;
  int discountPriceApp = 0;
  int discountCal = 0;

  int _discountValue = int.parse(discount);
  int _normalPrice = int.parse(normalNumber);
  discountCal = calPercen(_normalPrice, _discountValue);
  discountPriceOri = _normalPrice - discountCal;

  int cal35 = calPercen(discountPriceOri, 35);
  discountPriceApp = cal35 + discountPriceOri;

  print("discountPriceOri = " + discountPriceOri.toString());
  print("discountPriceApp = " + discountPriceApp.toString());

  return [discountPriceOri, discountPriceApp, discountCal];
}
