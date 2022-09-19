import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:instalavista/models/Story.dart';
import 'package:instalavista/models/story_group.dart';
import 'package:instalavista/models/user.dart';
import 'package:instalavista/progress_bloc.dart';
import 'package:video_player/video_player.dart';


class StoryScreen extends StatefulWidget {
  static const String routeName = "routeStory";

  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  late final CarouselSliderController _sliderController =
  CarouselSliderController();
  late AnimationController _animationController = AnimationController(
    vsync: this,
    duration: currentStory().duration,
  );
  late VideoPlayerController _videoController;

  final ProgressBloc progressBloc = ProgressBloc();

  int _currentStoryGroupIndex = 0;
  int _currentStoryIndex = 0;

  @override
  void initState() {
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
  ];

  void setStart() {
    // set if Video
    if (currentStory().mediaType == MediaType.video) {
      _videoController = VideoPlayerController.network(currentStory().mediaUrl);
      _videoController.initialize().then((_) {
        _videoController.play();
        _animationController.forward();
      });
    }
    _animationController.addListener(() {
      if (_animationController.value == 1.0 &&
          (_currentStoryGroupIndex < storyGroups.length - 1 ||
              _currentStoryIndex < currentStoryGroup().stories.length - 1)) {
        nextStory();
      }
      progressBloc.progressSink.add(_animationController.value);
      //_controller.setProgress(_animationController.value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _videoController.dispose();
  }

  void nextStory() {
    _animationController.stop();
    if (currentStory().mediaType == MediaType.video) _videoController.dispose();
    if (_currentStoryIndex < currentStoryGroup().stories.length - 1) {
      _animationController.value = 0;
      _currentStoryIndex = _currentStoryIndex + 1;
      currentStoryGroup().lastSeenStory = _currentStoryIndex;
      _animationController.duration = currentStory().duration;
    } else {
      if (_currentStoryGroupIndex < storyGroups.length - 1) {
        _sliderController.nextPage(Duration(milliseconds: 300));
      }
    }

    // set Video
    if (currentStory().mediaType == MediaType.video) {
      _videoController = VideoPlayerController.network(currentStory().mediaUrl);
      _videoController.initialize().then((_) {
        _videoController.play();
        _animationController.forward();
      });
    }
    print(currentStory().mediaUrl);
  }

  void previousStory() {
    _animationController.stop();
    if (currentStory().mediaType == MediaType.video) _videoController.dispose();
    if (currentStory().mediaType == MediaType.video &&
        _videoController.value.isPlaying) _videoController.dispose();

    if (_currentStoryIndex > 0) {
      _animationController.value = 0;
      _currentStoryIndex = _currentStoryIndex - 1;
      currentStoryGroup().lastSeenStory = _currentStoryIndex;
      _animationController.duration = currentStory().duration;
    } else {
      if (_currentStoryGroupIndex > 0) {
        _sliderController.previousPage(Duration(milliseconds: 300));
      }
    }

    // set video
    if (currentStory().mediaType == MediaType.video) {
      _videoController = VideoPlayerController.network(currentStory().mediaUrl);
      _videoController.initialize().then((_) {
        _videoController.play();
        _animationController.forward();
      });
    }
  }

  Story currentStory() {
    return storyGroups[_currentStoryGroupIndex].stories[_currentStoryIndex];
  }

  StoryGroup currentStoryGroup() {
    return storyGroups[_currentStoryGroupIndex];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<double>(
          stream: progressBloc.progressStream,
          builder: (context, snapshot) {
            return CarouselSlider(
              controller: _sliderController,
              slideTransform: CubeTransform(),
              onSlideChanged: (int) {
                if (currentStory().mediaType == MediaType.video)
                  _videoController.dispose();
                _currentStoryGroupIndex = int;
                _currentStoryIndex =
                    storyGroups[_currentStoryGroupIndex].lastSeenStory;
                _animationController.value = 0;

                print(_currentStoryGroupIndex.toString() +
                    " " +
                    _currentStoryIndex.toString());

                // set video
                if (currentStory().mediaType == MediaType.video) {
                  _videoController =
                      VideoPlayerController.network(currentStory().mediaUrl);
                  _videoController.initialize().then((_) {
                    _videoController.play();
                    _animationController.forward();
                  });
                }
              },
              children: [
                buildStoryGroup(context),
                buildStoryGroup(context),
              ],
            );
          },
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
              _animationController.stop();
              _videoController.pause();
            }
          },
          onTapUp: (details) {
            _animationController.forward();
            _videoController.play();
          },
          child: Container(
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
                  _animationController.forward();
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
              child: _videoController.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              )
                  : Container(),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 20,
          child: CircleAvatar(
            //radius: 30.0,
            child: Image.network(
              storyGroups[_currentStoryGroupIndex].user.profileImage,
              width: 30,
              height: 40,
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.topCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                storyGroups[_currentStoryGroupIndex].stories.length, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: LinearProgressIndicator(
                    value: _currentStoryIndex == index
                        ? _animationController.value
                        : _currentStoryIndex > index
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
      ],
    );
  }
}