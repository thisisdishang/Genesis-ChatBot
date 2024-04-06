import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:genesis/myapi.dart';
import 'package:genesis/splashscreen.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:genesis/message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const splashscreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput = TextEditingController();

  final model = GenerativeModel(model: 'gemini-pro', apiKey: GEMINI_API_KEY);

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userInput.text;

    if (message.isEmpty) {
      Fluttertoast.showToast(
          msg: 'You Ask Nothing!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      setState(() {
        _messages
            .add(Message(isUser: true, message: message, date: DateTime.now()));
      });

      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
            isUser: false, message: response.text ?? "", date: DateTime.now()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Genesis ChatBot',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.8), BlendMode.dstATop),
                image: NetworkImage(
                    'https://cdnb.artstation.com/p/assets/images/images/033/476/585/large/mono-mars-earth-logo.jpg?1609728849'),
                fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Messages(
                      isUser: message.isUser,
                      message: message.message,
                      date: DateFormat('HH:mm').format(message.date));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        hintText: 'Ask the question',
                        hintStyle:
                            TextStyle(fontSize: 16.0, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // label: Text('Ask the question'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                    padding: EdgeInsets.all(12),
                    iconSize: 28,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(CircleBorder())),
                    onPressed: () {
                      sendMessage();
                      setState(() {
                        _userInput.clear();
                      });
                    },
                    icon: Icon(Icons.send),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  IconButton(
                    padding: EdgeInsets.all(12),
                    iconSize: 28,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(CircleBorder())),
                    onPressed: () {
                      Fluttertoast.showToast(
                          msg: 'Chat Clear',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 10,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      setState(() {
                        _messages.clear();
                      });
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
