
class BodyCountFilename {
  public int bodyCount;
  public String filename;

  BodyCountFilename(JSONObject configBodyCountFilenameJSON) {
    bodyCount = configBodyCountFilenameJSON.getInt("bodyCount");
    filename = configBodyCountFilenameJSON.getString("filename");
  }
}
