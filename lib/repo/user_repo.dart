import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:prim_derma_app/models/user.dart';
import 'package:prim_derma_app/repo/env_variable.dart';

class UserRepo {
  Future<(User?,String)> userLogin(String loginCredentials, String password) async {
    try {
      var url = '$PRIM_URL/login';
      var uri = Uri.parse(url);

      Map<String, dynamic> loginData = {
        'email': loginCredentials,
        'password': password,
        'device_token':User.device_token??''
      };

      

      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        return (User.fromJson(data) , 'Login Successfully');
      } else {
        return (null,'Invalid Login');
      }
    } catch (e) {
      //print("Error: $e");
      return (null,'Please check your connection');
    }
  }

  Future<int> validateToken(String token) async {
    try {
      var url = '$PRIM_URL/validateToken';
      var uri = Uri.parse(url);

    
      Map<String, dynamic> tokenData = {
        'token': token,
        
      };

      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tokenData),
      );

     return response.statusCode;
     
    } catch (e) {
      //print("Error: $e");
      return 0;
    }
  }
}
