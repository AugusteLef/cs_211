int test = 0;
import processing.video.*;

PImage img;
HScrollbar thresholdBarHueMin;
HScrollbar thresholdBarHueMax;
HScrollbar thresholdBarSatMin;
HScrollbar thresholdBarSatMax;
Random rd = new Random();

BlobDetection blob = new BlobDetection();
Hough hough = new Hough();
Capture cam;
QuadGraph qg = new QuadGraph();
ArrayList<PImage> imgs = new ArrayList<PImage>();

void settings() {
  size(1600, 600);
}
void setup() {
  
  /*String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[1]);
    cam.start();
  }*/


  thresholdBarHueMin = new HScrollbar(0, 580, 800, 20);
  thresholdBarHueMax = new HScrollbar(0, 540, 800, 20);
  thresholdBarSatMin = new HScrollbar(0, 500, 800, 20);
  thresholdBarSatMax = new HScrollbar(0, 460, 800, 20);
  //noLoop(); // no interactive behaviour: draw() will be called only once.
  
  imgs.add(loadImage("board1.jpg"));
  imgs.add(loadImage("board2.jpg"));
  imgs.add(loadImage("board3.jpg"));
  imgs.add(loadImage("board4.jpg"));
}
void draw() {
  /*if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();*/
  
  img = imgs.get(++test%4);
  delay(2000);
  background(color(0, 0, 0));
  image(img, 0, 0);

  /*thresholdBarHueMin.display();
  thresholdBarHueMin.update();
  thresholdBarHueMax.display();
  thresholdBarHueMax.update();
  thresholdBarSatMin.display();
  thresholdBarSatMin.update();
  thresholdBarSatMax.display();
  thresholdBarSatMax.update();
  println(thresholdBarHueMin.sliderPosition + " " + thresholdBarHueMax.sliderPosition);*/

  
  // 100 150
  // 86 255
  float[][] blur = {
    {9, 12, 9}, 
    {12, 15, 12}, 
    {9, 12, 9}
  };
  
  //PImage img2 = thresholdHSB(img, 67, 138, 86, 255,0, 255);
  PImage img2 = thresholdHSB(img, 67, 138, 86, 255,35, 200);  
  //image(img2, img2.width,0);
  img2 = thresholdBinary(img2, 10,false);
  
  img2 = convolute(img2, blur);
  //image(img2, img2.width,0);
  img2 = blob.findConnectedComponents(img2, true);
  
  img2 = convolute(img2, blur);
  img2 = scharr(img2);
  img2 = thresholdBinary(img2, 50,false);

  List<PVector> edges = hough.hough(img2, 4);
  for(PVector p : edges)println(p);
  hough.drawLines(edges,img2);
  
  List<PVector> vertices = qg.findBestQuad(edges,img2.width,img2.height,img2.width*img2.height,200,true);
  for (PVector pv : vertices) {
     ellipse(pv.x*2.5, pv.y*2.5, 20, 20); 
  }
    image(img2, img2.width, 0);

  
}

PImage thresholdBinary(PImage img, int threshold, boolean inverted) {
  // create a new, initially transparent, 'result' image
  img.loadPixels();
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    if (brightness(img.pixels[i])<threshold)result.pixels[i] = color(inverted ? 255 : 0);
    else result.pixels[i] = color(inverted ? 0 : 255);
  }
  return result;
}
PImage thresholdHSB(PImage img, int hueMin, int hueMax, int satMin, int satMax, int briMin, int briMax) {
  img.loadPixels();
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {

    int hue = (int)hue(img.pixels[i]);
    int sat = (int)saturation(img.pixels[i]);
    int bri = (int)brightness(img.pixels[i]);
    if (hueMin <= hue && hue <= hueMax && satMin <= sat && sat <= satMax && briMin <= bri && bri <= briMax) result.pixels[i] = img.pixels[i];
  }
  return result;
}
boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))

      return false;
  return true;
}

PImage convolute(PImage img, float[][] kernel) {


  float normFactor = 1.f;
  int N = kernel.length;//kernel must be a square, odd is the best
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);

  int w = img.width;
  int h = img.height;
  img.loadPixels();
  result.loadPixels();

  double sumCoeff = 0;
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      sumCoeff += kernel[i][j];
    }
  }

  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by normFactor
  // - set result.pixels[y * img.width + x] to this value
  for (int x = 0; x < w; ++x) {
    for (int y = 0; y < h; ++y) {

      //For color blur, use these 3 valo
      /*double sumPixelsRed = 0;
       double sumPixelsGreen = 0;
       double sumPixelsBlue = 0;*/
      double sumBrightness = 0;

      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          float kernelVal = kernel[i][j];
          if (kernelVal == 0) continue;
          int xImg = x - N/2 + i;
          int yImg = y - N/2 + j;
          if (xImg < 0) xImg = 0;
          else if (xImg >= w) xImg = w-1;
          if (yImg < 0) yImg = 0;
          else if (yImg >= h) yImg = h-1;

          sumBrightness += kernelVal * brightness(img.pixels[xImg + yImg*w]);
        }
      }
      result.pixels[x + y*w] = color((int)(sumBrightness/sumCoeff));
    }
  }
  result.updatePixels();
  return result;
}

int[] convoluteForScharr(PImage img, float[][] kernel) {


  float normFactor = 1.f;
  int N = kernel.length;//kernel must be a square, odd is the best
  // create a greyscale image (type: ALPHA) for output
  int[] result = new int[img.width*img.height];

  int w = img.width;
  int h = img.height;
  img.loadPixels();

  double sumCoeff = 0;
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      sumCoeff += abs(kernel[i][j]);
    }
  }

  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by normFactor
  // - set result.pixels[y * img.width + x] to this value
  for (int x = 0; x < w; ++x) {
    for (int y = 0; y < h; ++y) {


      double sumBrightness = 0;

      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          float kernelVal = kernel[i][j];
          if (kernelVal == 0) continue;
          int xImg = x - N/2 + i;
          int yImg = y - N/2 + j;
          if (xImg < 0) xImg = 0;
          else if (xImg >= w) xImg = w-1;
          if (yImg < 0) yImg = 0;
          else if (yImg >= h) yImg = h-1;

          sumBrightness += kernelVal * brightness(img.pixels[xImg + yImg*w]);
        }
      }
      result[x + y*w] = (int)(sumBrightness/sumCoeff);
    }
  }
  return result;
}

PImage scharr(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 } };
  float[][] hKernel = {
    { 3, 10, 3 }, 
    { 0, 0, 0 }, 
    { -3, -10, -3 } };
  int h = img.height;
  int w = img.width;
  PImage result = createImage(w, h, ALPHA);
  // clear the image
  for (int i = 0; i < w * h; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[w * h];

  // *************************************
  // Implement here the double convolution
  // *************************************
  int[] sum_h_pix = convoluteForScharr(img, hKernel);
  int[] sum_v_pix = convoluteForScharr(img, vKernel);
  for (int i = 0; i < h; ++i) {
    for (int j = 0; j < w; ++j) {
      buffer[i * w + j] = sqrt(pow(sum_h_pix[i * w + j], 2) + pow(sum_v_pix[i * w + j], 2));
      if (buffer[i * w + j] > max) max = buffer[i * w + j];
    }
  }


  for (int y = 2; y < h - 2; ++y) { // Skip top and bottom edges
    for (int x = 2; x < w - 2; ++x) { // Skip left and right
      int val=(int) ((buffer[y * w + x] / max)*255);
      result.pixels[y * w + x]=color(val);
    }
  }
  return result;
}