class ChatUser {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  bool? isOnline;
  String? id;
  String? lastActive;
  String? email;
  String? pushToken;

  ChatUser(
      {this.image,
      this.about,
      this.name,
      this.createdAt,
      this.isOnline,
      this.id,
      this.lastActive,
      this.email,
      this.pushToken});

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? bool;
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['about'] = this.about;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['is_online'] = this.isOnline;
    data['id'] = this.id;
    data['last_active'] = this.lastActive;
    data['email'] = this.email;
    data['push_token'] = this.pushToken;
    return data;
  }
}