
import 'package:instalavista/models/Story.dart';
import 'package:instalavista/models/user.dart';

class StoryGroup {
  final User user;
  final List<Story> stories;
  int lastSeenStory = 0;

  StoryGroup(this.user, this.stories);
}