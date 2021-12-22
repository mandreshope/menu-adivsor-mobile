String priceFormated(double price) {
  if (price == null) {
    return "";
  }
  return price == 0.0 ? "" : "$price €";
}
