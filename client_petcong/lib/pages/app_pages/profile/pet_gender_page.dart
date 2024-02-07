import 'package:flutter/material.dart';
import 'package:petcong/controller/signup_controller.dart';
import 'introduce_page.dart';
import 'package:petcong/widgets/continue_button.dart';
import 'package:get/get.dart';

class PetGenderPage extends StatefulWidget {
  final String petName;
  final double progress;

  const PetGenderPage({required this.petName, required this.progress, Key? key})
      : super(key: key);

  @override
  PetGenderPageState createState() => PetGenderPageState();
}

class PetGenderPageState extends State<PetGenderPage> {
  final SignupController signupController = Get.put(SignupController());
  String _gender = '';
  bool _isNeutered = false;
  late double _progress; // _progress를 late로 선언
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress; // initState에서 _progress를 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: LinearProgressIndicator(
          value: _progress,
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color.fromARGB(255, 249, 113, 95),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 32),
                  onPressed: () => Get.back(),
                ),
              ),
              Text('${widget.petName}의 성별은?',
                  style: const TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.w600)),
              const SizedBox(height: 40.0),
              Center(
                child: SizedBox(
                  width: 240.0,
                  height: 50.0,
                  child: ContinueButton(
                    isFilled: _gender == 'FEMALE',
                    buttonText: 'FEMALE',
                    onPressed: () {
                      setState(() {
                        _gender = 'FEMALE';
                        _isButtonDisabled = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: SizedBox(
                  width: 240.0,
                  height: 50.0,
                  child: ContinueButton(
                    isFilled: _gender == 'MALE',
                    buttonText: 'MALE',
                    onPressed: () {
                      setState(() {
                        _gender = 'MALE';
                        _isButtonDisabled = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 1.5, // 원하는 사이즈로 조절
                      child: Checkbox(
                        value: _isNeutered,
                        activeColor: const Color.fromARGB(
                            255, 249, 113, 95), // 체크박스 컬러 변경
                        checkColor: Colors.white, // 체크 마크 컬러
                        onChanged: (bool? value) {
                          setState(() {
                            _isNeutered = !_isNeutered;
                            // _isButtonDisabled = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20.0), // 체크박스와 텍스트 사이의 간격 조절
                    const Text(
                      '중성화했어요',
                      style: TextStyle(fontSize: 20.0), // 텍스트 크기 조절
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50.0),
              ContinueButton(
                isFilled: !_isButtonDisabled,
                buttonText: 'CONTINUE',
                onPressed: !_isButtonDisabled
                    ? () {
                        SignupController.to.addPetGender(_gender);
                        SignupController.to.addNeutered(_isNeutered);
                        Get.to(() => (const IntroducePage(progress: 0.65)),
                            transition: Transition.noTransition);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
