

enum MediaType {
  image,
  video,
}

class Story {
  final String mediaUrl;
  final MediaType mediaType;
  final Duration duration;

  Story(this.mediaUrl, this.mediaType, this.duration);
}