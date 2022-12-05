import 'dart:core';

class DeliveryChargeModel {
  num amount, delivery_charges_per_km, minimum_delivery_charges, minimum_delivery_charges_within_km;
  bool vendor_can_modify = false;

  DeliveryChargeModel(
      {this.amount = 0,
      this.delivery_charges_per_km = 0,
      this.minimum_delivery_charges = 0,
      this.minimum_delivery_charges_within_km = 0,
      this.vendor_can_modify = false});

  factory DeliveryChargeModel.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryChargeModel(
        amount: parsedJson['amount'] ?? 0,
        delivery_charges_per_km: parsedJson['delivery_charges_per_km'] ?? 0,
        minimum_delivery_charges: parsedJson['minimum_delivery_charges'] ?? 0,
        minimum_delivery_charges_within_km: parsedJson['minimum_delivery_charges_within_km'] ?? 0,
        vendor_can_modify: parsedJson['vendor_can_modify'] ?? false);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'delivery_charges_per_km': this.delivery_charges_per_km,
      'minimum_delivery_charges': this.minimum_delivery_charges,
      'minimum_delivery_charges_within_km': this.minimum_delivery_charges_within_km
    };

    return json;
  }
}
