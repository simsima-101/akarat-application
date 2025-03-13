class LoginModel {
  String? email;
  String? message;
  int? id;
  String? name;
  String? role;
  String? token;

  LoginModel(
      {this.email, this.message, this.id, this.name, this.role, this.token});

  LoginModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    message = json['message'];
    id = json['id'];
    name = json['name'];
    role = json['role'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = this.email;
    data['message'] = this.message;
    data['id'] = this.id;
    data['name'] = this.name;
    data['role'] = this.role;
    data['token'] = this.token;
    return data;
  }
}