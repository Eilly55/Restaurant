class VendorCategoryModel {
  var id;
  var order;
  var photo;
  var title;

  VendorCategoryModel({this.id, this.order, this.photo, this.title});

  VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order = json['order'];
    photo = json['photo'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order'] = this.order;
    data['photo'] = this.photo;
    data['title'] = this.title;
    return data;
  }
}
