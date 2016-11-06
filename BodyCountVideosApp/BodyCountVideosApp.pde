import gab.opencv.*;
import java.util.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import processing.sound.*;
import processing.video.*;

Config config;
ArrayList<BodyCountSound> bodyCountSounds;
BodyCountSound currSound;

Kinect kinect;
OpenCV opencv;
Movie movie;

PImage thresholder;

PFont contourCountFont;

void setup() {
  size(1920, 520);

  config = new Config();
  config.load();

  bodyCountSounds = config.getBodyCountSounds(this);
  currSound = null;

  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableColorDepth(false);

  opencv = new OpenCV(this, 640, 480);

  movie = new Movie(this, config.videoFilename());
  movie.loop();

  thresholder = createImage(kinect.width, kinect.height, ALPHA);

  contourCountFont = createFont("data/roadgeek.ttf", 128);
}

void draw() {
  int bodyCount = (millis() / 10000) % 9;
  updateSound(bodyCount);

  background(0);
  image(kinect.getDepthImage(), 0, 0);

  updateThresholder(kinect.getDepthImage());
  opencv.loadImage(thresholder);
  opencv.blur(5);

  image(opencv.getSnapshot(), 640, 0);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);

  int contourCount = 0;
  for (Contour contour : opencv.findContours()) {
    if (contour.area() >= config.minContourArea()
        && contour.area() <= config.maxContourArea()) {
      contour.draw();
      contourCount++;
    }
  }

  fill(255);
  textFont(contourCountFont);
  text(contourCount, 20, 120);

  image(movie, 1280, 0);
}

void movieEvent(Movie m) {
  m.read();
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

void updateThresholder(PImage source) {
  color white = color(255);
  color black = color(0);
  thresholder.loadPixels();
  source.loadPixels();
  for (int i = 0; i < source.width * source.height; i++) {
    float b = brightness(source.pixels[i]);
    thresholder.pixels[i] = b >= config.minDepth() && b <= config.maxDepth() ? white : black;
  }
  thresholder.updatePixels();
}

void keyReleased() {
  switch(key) {
    case 'j':
      config.minDepth(config.minDepth() - 1);
      config.save();
      break;
    case 'k':
      if (config.minDepth() < config.maxDepth()) {
        config.minDepth(config.minDepth() + 1);
        config.save();
      }
      break;
    case 'J':
      if (config.minDepth() < config.maxDepth()) {
        config.maxDepth(config.maxDepth() - 1);
        config.save();
      }
      break;
    case 'K':
      config.maxDepth(config.maxDepth() + 1);
      config.save();
      break;
  }
}
