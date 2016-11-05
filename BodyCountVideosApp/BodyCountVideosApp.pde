import gab.opencv.*;
import java.util.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import processing.sound.*;
import processing.video.*;

JSONObject configJSON;
ArrayList<BodyCountSound> bodyCountSounds;
BodyCountSound currSound;

Kinect kinect;
OpenCV opencv;
Movie movie;

void setup() {
  size(1920, 520);

  configJSON = loadJSONObject("config.json");
  String videoFilename = configJSON.getString("videoFilename");
  bodyCountSounds = getBodyCountSounds(configJSON.getJSONArray("audioFilenames"));
  currSound = null;

  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableColorDepth(false);

  opencv = new OpenCV(this, 640, 480);

  movie = new Movie(this, videoFilename);
  movie.loop();
}

void draw() {
  int bodyCount = (millis() / 10000) % 9;
  updateSound(bodyCount);

  background(0);
  image(kinect.getDepthImage(), 0, 0);

  opencv.loadImage(kinect.getDepthImage());
  opencv.blur(3);
  opencv.dilate();

  image(opencv.getSnapshot(), 640, 0);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  for (Contour contour : opencv.findContours()) {
    if (contour.area() > 50) {
      contour.draw();
    }
  }

  image(movie, 1280, 0);
}

void movieEvent(Movie m) {
  m.read();
}

ArrayList<BodyCountSound> getBodyCountSounds(JSONArray audioFilenamesJSON) {
  ArrayList<BodyCountSound> result = new ArrayList<BodyCountSound>();
  for (int i = 0; i < audioFilenamesJSON.size(); i++) {
    result.add(new BodyCountSound(this, audioFilenamesJSON.getJSONObject(i)));
  }

  Comparator<BodyCountSound> comparator = new Comparator<BodyCountSound>() {
    public int compare(BodyCountSound a, BodyCountSound b) {
      return a.bodyCount - b.bodyCount;
    }
  };
  Collections.sort(result, comparator);

  return result;
}

void updateSound(int bodyCount) {
  // TODO: Crossfade durations from config.
  BodyCountSound nextSound = getBodyCountSoundByBodyCount(bodyCount);
  if (nextSound != currSound && (nextSound == null || currSound == null || nextSound.filename != currSound.filename)) {
    if (currSound != null) {
      currSound.sound.stop();
    }

    if (nextSound != null) {
      println("bodies: " + bodyCount + ". playing: " + nextSound.filename);
      nextSound.sound.play();
    }
    else {
      println("bodies: " + bodyCount + ". no sound to play");
    }
  }
  currSound = nextSound;
}

BodyCountSound getBodyCountSoundByBodyCount(int bodyCount) {
  for (int i = bodyCountSounds.size() - 1; i >= 0; i--) {
    if (bodyCountSounds.get(i).bodyCount <= bodyCount) {
      return bodyCountSounds.get(i);
    }
  }

  return null;
}

