import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petcong/constants/style.dart';
import 'package:petcong/controller/history_controller.dart';
import 'package:petcong/models/card_profile_model.dart';
import 'package:petcong/widgets/matched_card.dart';

class MainChatPage extends StatefulWidget {
  const MainChatPage({super.key});
  @override
  State<MainChatPage> createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage> {
  @override
  Widget build(BuildContext context) {
    Get.put(HistoryController());

//TODO: fix getMatchedUsers api
    HistoryController.to.getMatchedUsers();
    RxList<CardProfileModel> matchedUsers = HistoryController.to.matchedUsers;
    if (matchedUsers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: MyColor.myColor2,
        ),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.8, // Adjust this value as needed
            children: List.generate(matchedUsers.length, (index) {
              return GestureDetector(
                onTap: () {
                  if (kDebugMode) {
                    print(
                        "matchedUser nickname onTap: ${matchedUsers[index].nickname}");
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileDetailPage(
                            matchedUser: matchedUsers[index])),
                  );
                },
                child: MatchedCard(matchedUser: matchedUsers[index]),
              );
            }),
          ),
        ),
      );
    }
  }
}
