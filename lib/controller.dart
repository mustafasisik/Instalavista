

import 'package:get/get.dart';

class Controller extends GetxController {
  var progress = 0.0.obs;

  void setProgress(token){
    progress.value = token;
  }
}