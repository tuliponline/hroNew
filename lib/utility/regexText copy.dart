textLengthRegex(String string, int length) {
  if (string.length >= length) {
    return true;
  } else {
    return false;
  }
}

onlyNumberRegex(String number) {
  if (number?.isEmpty ?? true) {
    return false;
  } else {
    String pattern = r'^[1-9][0-9]*$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(number);
  }
}

cardIdRegex(String number) {
  if (number?.isEmpty ?? true) {
    return false;
  } else {
    if (number.length != 13) {
      return false;
    } else {
      String pattern = r'^[0-9]\d*$';
      RegExp regExp = new RegExp(pattern);
      return regExp.hasMatch(number);
    }
  }
}

phoneRegex(String phone) {
  String pattern = r'^[0][0-9]\d{8}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(phone);
}

emailRegex(String email) {
  String pattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(email);
}

addCreditRegex(String credit) {
  String pattern = r'^[0-9]{1,}\.[0-9]{2}';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(credit);
}

// addCreditRegex(String credit) {
//   String pattern = r'^[0-9]{1,}\.[0-9]{2}';
//   RegExp regExp = new RegExp(pattern);
//   return regExp.hasMatch(credit);
// }
