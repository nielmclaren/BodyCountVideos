
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

  public void depthThresholdMin(int v) {
    JSONObject depthThresholdJSON = configJSON.getJSONObject("depthThreshold");
    depthThresholdJSON.setInt("min", v);
    configJSON.setJSONObject("depthThreshold", depthThresholdJSON);
  }

  public int depthThresholdMin() {
    return configJSON.getJSONObject("depthThreshold").getInt("min");
  }

  public void depthThresholdMax(int v) {
    JSONObject depthThresholdJSON = configJSON.getJSONObject("depthThreshold");
    depthThresholdJSON.setInt("max", v);
    configJSON.setJSONObject("depthThreshold", depthThresholdJSON);
  }

  public int depthThresholdMax() {
    return configJSON.getJSONObject("depthThreshold").getInt("max");
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

