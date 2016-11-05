import java.util.*;
import gab.opencv.*;
import processing.video.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

JSONObject configJSON;
ArrayList<BodyCountFilename> audioFilenames;

Kinect kinect;
OpenCV opencv;
Movie movie;

void setup() {
  size(1920, 520);

  configJSON = loadJSONObject("config.json");
  String videoFilename = configJSON.getString("videoFilename");
  audioFilenames = getBodyCountFilenames(configJSON.getJSONArray("audioFilenames"));

  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableColorDepth(false);

  opencv = new OpenCV(this, 640, 480);

  movie = new Movie(this, videoFilename);
  movie.loop();
}

void draw() {
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

ArrayList<BodyCountFilename> getBodyCountFilenames(JSONArray bodyCountFilenamesJSON) {
  ArrayList<BodyCountFilename> result = new ArrayList<BodyCountFilename>();
  for (int i = 0; i < bodyCountFilenamesJSON.size(); i++) {
    JSONObject bodyCountFilenameJSON = bodyCountFilenamesJSON.getJSONObject(i);
    result.add(new BodyCountFilename(bodyCountFilenameJSON));
  }

  Comparator<BodyCountFilename> comparator = new Comparator<BodyCountFilename>() {
    public int compare(BodyCountFilename a, BodyCountFilename b) {
      return a.bodyCount - b.bodyCount;
    }
  };
  Collections.sort(result, comparator);

  for (int i = 0; i < result.size(); i++) {
    BodyCountFilename bodyCountFilename = result.get(i);
    println(bodyCountFilename.bodyCount + " " + bodyCountFilename.filename);
  }

  return result;
}
