class RegisterModel {
  String? message;
  String? user;
  String? email;
  String? token;

  RegisterModel({this.message, this.user, this.email, this.token});

 /* factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      message: json['message'],
      user: json['user'],
      email: json['email'],
      token: json['token'],
    );
  }*/
  RegisterModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'];
    email = json['email'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = this.message;
    data['user'] = this.user;
    data['email'] = this.email;
    data['token'] = this.token;
    return data;
  }
}