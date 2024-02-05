import 'package:petcong/models/pet_info_model.dart';
import 'package:petcong/models/user_info_model.dart';

class UserSignupModel {
  UserInfoModel userInfoModel;
  PetInfoModel petInfoModel;

  UserSignupModel({required this.userInfoModel, required this.petInfoModel});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userInfoDto'] = userInfoModel.toJson();
    data['petInfoDto'] = petInfoModel.toJson();
    return data;
  }
}
