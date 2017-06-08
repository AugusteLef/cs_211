import processing.video.*;

class ImageProcessing extends PApplet {
  OpenCV opencv;
  Movie cam;
  PVector correctRotation = new PVector(0, 0, 0);
  PImage img;
  Random rd = new Random();
  BlobDetection blob = new BlobDetection();
  Hough hough = new Hough();
  QuadGraph qg = new QuadGraph();
  TwoDThreeD tdtd;
  Image image = new Image();


  void settings() {
    size(1600, 1200);
   
  }
  void setup() {

    
    System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    opencv = new OpenCV(this, 100, 100);
    cam = new Movie(this, "testvideo.avi"); //Put the video in the same directory
    cam.loop();
  }
  void draw() {
    if (cam.available() == true) {
      cam.read();
    }
    img = cam.get();

    tdtd = new TwoDThreeD(img.width, img.height, 0);
    float[][] blur = {
      {9, 12, 9}, 
      {12, 15, 12}, 
      {9, 12, 9}
    };

    PImage img2 = image.thresholdHSB(img, 67, 138, 86, 255, 35, 200); 
    img2 = image.thresholdBinary(img2, 10, false);
    img2 = image.convolute(img2, blur);
    img2 = blob.findConnectedComponents(img2, true);

    PImage img3 = image.convolute(img2, blur);
    img3 = image.scharr(img3);

    List<PVector> edges = hough.hough(img3, 4);
    hough.drawLines(edges, img3);

    List<PVector> vertices = qg.findBestQuad(edges, img3.width, img3.height, img3.width*img3.height, 100, true);

    for (PVector pv : vertices) {
      ellipse(pv.x, pv.y, 20, 20);
    }

    image(img2, img2.width, 0);
    image(img3, 0, img3.height);

    List<PVector> vertInHomogenous = new ArrayList<PVector>();
    for (PVector pv : vertices) {
      vertInHomogenous.add(new PVector(pv.x, pv.y, 1));
    }
    PVector rotation =  tdtd.get3DRotations(vertInHomogenous);
    correctRotation = new PVector(rotation.x > PI/2 ? rotation.x*180/PI - 180 : (rotation.x < -PI/2 ? rotation.x*180/PI + 180 : rotation.x*180/PI), 
      rotation.y > PI/2 ? rotation.y*180/PI - 180 : (rotation.y < -PI/2 ? rotation.y*180/PI + 180 : rotation.y*180/PI), 
      rotation.z > PI/2 ? rotation.z*180/PI - 180 : (rotation.z < -PI/2 ? rotation.z*180/PI + 180 : rotation.z*180/PI));
    println("rx = " + correctRotation.x + " ry = " + correctRotation.y + " rz = " + correctRotation.z);
  }
  PVector getRotation() {


    return correctRotation;
  }
}