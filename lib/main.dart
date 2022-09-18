import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:get/get.dart';
import 'package:instalavista/models/Story.dart';
import 'package:instalavista/models/story_group.dart';
import 'package:instalavista/models/user.dart';
import 'package:video_player/video_player.dart';

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
      title: 'Instalavista',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        MainScreen.routeName: (context) => MainScreen(),
        StoryScreen.routeName: (context) => StoryScreen(),
      },
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  static const String routeName = "routeMain";

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instalavista"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: 6,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, StoryScreen.routeName);
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class StoryScreen extends StatefulWidget {
  static const String routeName = "routeStory";

  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  late final CarouselSliderController _sliderController = CarouselSliderController();
  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: currentStory().duration,
  );
  late VideoPlayerController videoController;

  int currentSGroup = 0;
  int cStory = 0;
  var progress = 0.0.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setStart();
  }

  var storyGroups = <StoryGroup>[
    StoryGroup(
      User("ahmetcan",
          "https://docs.microsoft.com/en-us/answers/storage/attachments/209536-360-f-364211147-1qglvxv1tcq0ohz3fawufrtonzz8nq3e.jpg"),
      <Story>[
        Story(
            "https://i.pinimg.com/originals/b4/86/c9/b486c91f453096ebf294cdd05be7e12e.png",
            MediaType.image,
            Duration(seconds: 5)),
        Story(
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            MediaType.video,
            Duration(seconds: 15)),
        Story("https://wallpapercave.com/wp/wp7412870.jpg", MediaType.image,
            Duration(seconds: 5)),
        Story(
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            MediaType.video,
            Duration(seconds: 9)),
      ],
    ),
    StoryGroup(
      User("elifenur",
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHw%3D&w=1000&q=80"),
      <Story>[
        Story(
            "https://i.pinimg.com/originals/9b/57/9c/9b579cbe58f23bccf94af8d4cb3009b6.png",
            MediaType.image,
            Duration(seconds: 5)),
        Story(
            "https://i.pinimg.com/736x/7a/5e/a2/7a5ea2239b26b62374b0afd1992d42cd.jpg",
            MediaType.image,
            Duration(seconds: 5)),
      ],
    )
  ].obs;

  void setStart() {
    // set if Video
    if (currentStory().mediaType == MediaType.video) {
      videoController = VideoPlayerController.network(currentStory().mediaUrl);
      videoController.initialize().then((_) {
        videoController.play();
        animationController.forward();
      });
    }
    animationController.addListener(() {
      if (animationController.value == 1.0 &&
          (currentSGroup < storyGroups.length - 1 ||
              cStory < currentStoryGroup().stories.length - 1)) {
        nextStory();
      }

      progress.value = animationController.value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
    videoController.dispose();
  }

  void nextStory() {
    animationController.stop();
    if (currentStory().mediaType == MediaType.video) videoController.pause();
    if (cStory < currentStoryGroup().stories.length - 1) {
      animationController.value = 0;
      cStory = cStory + 1;
      currentStoryGroup().lastSeenStory = cStory;
      animationController.duration = currentStory().duration;
    } else {
      if (currentSGroup < storyGroups.length - 1) {
        _sliderController.nextPage(Duration(milliseconds: 300));
      }
    }

    // set Video
    if (currentStory().mediaType == MediaType.video) {
      videoController = VideoPlayerController.network(currentStory().mediaUrl);
      videoController.initialize().then((_) {
        videoController.play();
        print("Playing Video N");
        animationController.forward();
      });
    }
    print(currentStory().mediaUrl);
  }

  void previousStory() {
    animationController.stop();
    if (currentStory().mediaType == MediaType.video)
      videoController.pause(); // stop last video
    if (cStory > 0) {
      animationController.value = 0;
      cStory = cStory - 1;
      currentStoryGroup().lastSeenStory = cStory;
      animationController.duration = currentStory().duration;
    } else {
      if (currentSGroup > 0) {
        _sliderController.previousPage(Duration(milliseconds: 300));
      }
    }

    // set video
    if (currentStory().mediaType == MediaType.video) {
      videoController = VideoPlayerController.network(currentStory().mediaUrl);
      videoController.initialize().then((_) {
        videoController.play();
        animationController.forward();
        print("Playing Video P");
      });
    }
    print(currentStory().mediaUrl);
  }

  Story currentStory() {
    return storyGroups[currentSGroup].stories[cStory];
  }

  StoryGroup currentStoryGroup() {
    return storyGroups[currentSGroup];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CarouselSlider(
          controller: _sliderController,
          slideTransform: CubeTransform(),
          onSlideChanged: (int) {
            currentSGroup = int;
            cStory = storyGroups[currentSGroup].lastSeenStory;
            animationController.value = 0;
          },
          children: [
            buildStoryGroup(context),
            buildStoryGroup(context),
          ],
        ),
      ),
    );
  }

  Stack buildStoryGroup(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            final tapPosition = details.globalPosition;
            final x = tapPosition.dx;
            if (x < MediaQuery.of(context).size.width / 3) {
              previousStory();
            } else if (x > MediaQuery.of(context).size.width * 2 / 3) {
              nextStory();
            } else {
              animationController.stop();
              videoController.pause();
            }
          },
          onTapUp: (details) {
            animationController.forward();
            videoController.play();
          },
          child: Obx(()=>
            Container(
              color: Colors.black,
              child: currentStory().mediaType == MediaType.image
                  ? Image.network(
                      currentStory().mediaUrl,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          animationController.forward();
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: videoController.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: videoController.value.aspectRatio,
                              child: VideoPlayer(videoController),
                            )
                          : Container(),
                    ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 20,
          child: CircleAvatar(
            //radius: 30.0,
            child: Image.network(
              storyGroups[currentSGroup].user.profileImage,
              width: 30,
              height: 40,
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.topCenter,
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(storyGroups[currentSGroup].stories.length,
                  (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: LinearProgressIndicator(
                      value: cStory == index
                          ? progress.value
                          : cStory > index
                              ? currentStory().duration.inSeconds.toDouble()
                              : 0,
                      semanticsLabel: 'Linear progress indicator',
                      color: Colors.blue,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
