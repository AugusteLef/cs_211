import processing.video.*;

class ImageProcessing extends PApplet {
  OpenCV opencv;
  //Capture cam;
  Movie cam;
  PVector correctRotation = new PVector(0, 0, 0);
  PImage img;
  Random rd = new Random();
  BlobDetection blob = new BlobDetection();
  Hough hough = new Hough();
  QuadGraph qg = new QuadGraph();
  TwoDThreeD tdtd;
  Image image = new Image();
  PGraphics pgraphic;
  boolean fpsSetted = false;
  long t1;
  int counter = 0;
  final static int SET_FPS_AT = 10;
  

  void settings() {
    size(1600, 1200, P2D);
  }
  void setup() {
    System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    opencv = new OpenCV(this, 100, 100);
    cam = new Movie(this, "D:/programmes/git info visu/Informatique-Visuelle/Game/test.avi"); //Put the absolute path => change with your own computer
    cam.loop();
    /*String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
      cam = new Capture(this, cameras[3]);
      cam.start();
    }*/
    pgraphic = createGraphics(1600, 1200, P2D);
  }
  void draw() {
    if (cam.available() == true) {
      cam.read();
    }
    img = cam.get();
    
    if(counter == 0){
      t1 = System.currentTimeMillis();
      tdtd = new TwoDThreeD(img.width, img.height, 3);//temporarly set the fps at 3
    }
    
    pgraphic.beginDraw();
    pgraphic.image(img, 0, 0);
    float[][] blur = {
      {9, 12, 9}, 
      {12, 15, 12}, 
      {9, 12, 9}
    };

    PImage img2 = image.thresholdHSB(img, 78, 138, 86, 255, 35, 200);                                                                                                                                                                                                                                                                                                                                     
    img2 = image.thresholdBinary(img2, 10, false);
    img2 = image.convolute(img2, blur);
    img2 = blob.findConnectedComponents(img2, true);

    PImage img3 = image.convolute(img2, blur);
    img3 = image.scharr(img3);

    List<PVector> edges = hough.hough(img3, 6);
    //hough.drawLines(edges, img3, daube);

    List<PVector> vertices = qg.findBestQuad(edges, img3.width, img3.height, img3.width*img3.height, 1500, false);//1500 might need to be change depending of the size of the camera...

    for (PVector pv : vertices) {
      pgraphic.ellipse(pv.x, pv.y, 20, 20);
    }

    pgraphic.image(img2, img2.width, 0);
    pgraphic.image(img3, 0, img3.height);
    pgraphic.endDraw();
    image(pgraphic, 0, 0);

    List<PVector> vertInHomogenous = new ArrayList<PVector>();
    for (PVector pv : vertices) {
      vertInHomogenous.add(new PVector(pv.x, pv.y, 1));
    }
    if (vertInHomogenous.size() == 4) {
      PVector rotation =  tdtd.get3DRotations(vertInHomogenous);
      correctRotation = new PVector(rotation.x > PI/2 ? rotation.x - PI : (rotation.x < -PI/2 ? rotation.x + PI : rotation.x), 
        rotation.y > PI/2 ? rotation.y - PI : (rotation.y < -PI/2 ? rotation.y + PI : rotation.y), 
        rotation.z > PI/2 ? rotation.z - PI : (rotation.z < -PI/2 ? rotation.z + PI : rotation.z));//in radians
      //println("rx = " + correctRotation.x + " ry = " + correctRotation.y + " rz = " + correctRotation.z);
    }
    if(!fpsSetted){//set the fps after 10 frames
      ++counter;
      if(counter == SET_FPS_AT){
        t1 = (System.currentTimeMillis() - t1);
        int fps = (int)Math.round((SET_FPS_AT*1000d)/t1);
        fpsSetted = true;
        println("FPS computed (rounded to the closest after 10 frames) = ~"+fps);
        tdtd = new TwoDThreeD(img.width, img.height, fps);
      }
    }
  }
  PVector getRotation() {
    return correctRotation;
  }
}