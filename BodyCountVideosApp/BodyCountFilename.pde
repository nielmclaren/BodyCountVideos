import processing.sound.*;

class BodyCountSound {
  public int bodyCount;
  public String filename;
  public SoundFile sound;

  BodyCountSound(BodyCountVideosApp sketch, JSONObject audioFilenameJSON) {
    bodyCount = audioFilenameJSON.getInt("bodyCount");
    filename = audioFilenameJSON.getString("filename");
    sound = new SoundFile(sketch, filename);
  }
}
