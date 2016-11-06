
class Config {
  private String configPath;
  private JSONObject configJSON;

  private int lowerThreshold;
  private int upperThreshold;

  Config() {
    configPath = "data/config.json";
  }

  public void load() {
    configJSON = loadJSONObject(configPath);
  }

  public void save() {
    saveJSONObject(configJSON, configPath);
  }

  public String videoFilename() {
    return configJSON.getString("videoFilename");
  }

  public void minDepth(int v) {
    configJSON.setInt("minDepth", v);
    println("New min depth: " + v);
  }

  public int minDepth() {
    return configJSON.getInt("minDepth");
  }

  public void maxDepth(int v) {
    configJSON.setInt("maxDepth", v);
    println("New max depth: " + v);
  }

  public int maxDepth() {
    return configJSON.getInt("maxDepth");
  }

  public void minContourArea(int v) {
    configJSON.setInt("minContourArea", v);
    println("New min contour area: " + v);
  }

  public int minContourArea() {
    return configJSON.getInt("minContourArea");
  }

  public void maxContourArea(int v) {
    configJSON.setInt("maxContourArea", v);
    println("New max contour area: " + v);
  }

  public int maxContourArea() {
    return configJSON.getInt("maxContourArea");
  }

  ArrayList<BodyCountSound> getBodyCountSounds(BodyCountVideosApp sketch) {
    JSONArray audioFilenamesJSON = configJSON.getJSONArray("audioFilenames");
    ArrayList<BodyCountSound> result = new ArrayList<BodyCountSound>();
    for (int i = 0; i < audioFilenamesJSON.size(); i++) {
      result.add(new BodyCountSound(sketch, audioFilenamesJSON.getJSONObject(i)));
    }

    Comparator<BodyCountSound> comparator = new Comparator<BodyCountSound>() {
      public int compare(BodyCountSound a, BodyCountSound b) {
        return a.bodyCount - b.bodyCount;
      }
    };
    Collections.sort(result, comparator);

    return result;
  }
}

