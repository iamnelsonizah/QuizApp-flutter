import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:quiz_app/constants/colors.dart';
import 'package:quiz_app/constants/images.dart';
import 'package:quiz_app/constants/text_style.dart';
import 'package:quiz_app/api_services.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int points = 0;
  int seconds = 60;
  late Timer timer;
  var currentQuestionIndex = 0;
  var isLoaded = false;
  var optionsList =  [];
  var optionsColor = [
    Colors.red,
    Colors.green,
    Colors.white,
    Colors.white,
    Colors.white,
  ] ;
  

  resetColors() {
    optionsColor = [
    Colors.red,
    Colors.green,
    Colors.white,
    Colors.white,
    Colors.white,
    ] ;
  }



  @override
  void initState() {
    super.initState();
    startTimer();
    fetchQuizData();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.indigo],
            ),
          ),
          child: FutureBuilder(
            // Replace 'Future' and 'initialData' with your actual future and initial data
            future: fetchQuizData(), // Replace with your actual future function
            initialData: null, // Replace with your actual initial data
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasData) {
                var data = snapshot.data['results'];

                if (isLoaded == false) {
                  optionsList =  data[currentQuestionIndex]["incorrect_answers"];
                  optionsList = data[currentQuestionIndex]["correct_answer"];
                  optionsList.shuffle();
                  isLoaded = true;
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: lightgrey, width: 2),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                CupertinoIcons.xmark,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              normalText(color: Colors.white, size: 22, text: "$seconds"),
                              CircularProgressIndicator(
                                value: seconds / 60,
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: lightgrey, width: 2),
                            ),
                            child: TextButton.icon(
                              onPressed: null,
                              icon: const Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: normalText(color: Colors.white, size: 14, text: "Like"),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Image.asset(ideas, width: 200),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: normalText(
                            color: lightgrey, size: 18, text: "Question ${currentQuestionIndex + 1} of ${data.length}"),
                      ),
                      const SizedBox(height: 20),
                      normalText(color: Colors.white, size: 20, text: data[currentQuestionIndex]["question"]),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: optionsList.length,
                        itemBuilder: (BuildContext context, int index) {

                          var answer = data[currentQuestionIndex]["correct_answer"];
                          return GestureDetector(
                            onTap: () {
                             setState(() {
                               if (answer.toString() == optionsList[index].toString()) {
                                optionsColor[index] = Colors.green;
                                points = points + 10;
                               } else {
                                optionsColor[index] = Colors.red;
                               }

                               isLoaded = false;

                               if(currentQuestionIndex < data.length - 1) {
                                Future.delayed(Duration(seconds: 1), () {
                                  currentQuestionIndex++;
                                  resetColors();
                                  timer.cancel();
                                  seconds = 60;
                                  startTimer();
                                });
                               } else {
                                timer.cancel();
                               }
                             });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: MediaQuery.of(context).size.width - 100,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: optionsColor[index],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: headingText(color: blue, size: 18, text: optionsList[index].toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
