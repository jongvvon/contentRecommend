import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

Future<String> getApiKey() async {
  String data = await rootBundle.loadString('assets/config.json');
  var config = jsonDecode(data);
  return config['youtube_api_key'];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List _items = [];

  Future<void> searchVideos() async {
    // getApiKey() 함수는 비동기 함수(async)로 선언되어 있습니다. 이는 함수의 실행이 즉시 완료되지 않고, Future 객체를 반환한다는 것을 의미합니다. 따라서 var apiKey = getApiKey();와 같이 코드를 작성하면, apiKey 변수는 Future<String> 타입의 객체를 가지게 됩니다.
    // 비동기 함수의 결과를 사용하려면 await 키워드를 사용해야 합니다. 하지만 await 키워드는 비동기 함수 내에서만 사용할 수 있습니다. 따라서 apiKey를 선언하는 코드를 비동기 함수 내로 옮겨야 합니다.
    var apiKey = await getApiKey();
    print('api key: $apiKey');
    var url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&q=${_controller.text}&type=video&key=$apiKey');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        _items = jsonResponse['items'];
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
      // Response Body 내용을 통해서 문제가 무엇인지 json 형식으로 확인 가능
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Search')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => searchVideos(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                var videoId = _items[index]['id']['videoId'];
                var title = _items[index]['snippet']['title'];
                var thumbnailUrl =
                    _items[index]['snippet']['thumbnails']['default']['url'];

                return ListTile(
                  leading: Image.network(thumbnailUrl),
                  title: Text(title),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(videoId: videoId),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: YoutubePlayer(controller: _controller!),
    );
  }
}
