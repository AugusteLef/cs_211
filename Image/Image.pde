PImage img;
HScrollbar thresholdBarHueMin;
HScrollbar thresholdBarHueMax;
void settings() {
  size(1600, 600);
}
void setup() {

  img = loadImage("board1.jpg");
  thresholdBarHueMin = new HScrollbar(0, 580, 800, 20);
  thresholdBarHueMax = new HScrollbar(0, 540, 800, 20);
  //noLoop(); // no interactive behaviour: draw() will be called only once.
}
void draw() {
  background(color(0, 0, 0));
  image(img, 0, 0);
  thresholdBarHueMin.display();
  thresholdBarHueMin.update();
  thresholdBarHueMax.display();
  thresholdBarHueMax.update();



  //PImage img2 = thresholdHSB(img, (int)(thresholdBarHueMin.getPos()*255), (int)(thresholdBarHueMax.getPos()*255), 0, 255, 0, 255);
  //PImage img2 = thresholdHSB(img, 100, 200, 100, 255, 45, 100);
  PImage img2 = convolute(img);
  image(img2, img.width, 0);
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

PImage convolute(PImage img) {
  float[][] kernel = { 
    { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};

  float normFactor = 1.f;
  int N = 3;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);

  int w = img.width;
  int h = img.height;
  img.loadPixels();
  result.loadPixels();
  // kernel size N = 3
  //
  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by normFactor
  // - set result.pixels[y * img.width + x] to this value
  for (int x = 0; x < w; ++x) {
    for (int y = 0; y < h; ++y) {

      double sumPixels = 0;
      double sumCoeff = 0;

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
          sumCoeff += kernelVal;
          sumPixels = kernelVal * img.pixels[xImg + yImg*w];
        }
      }
      result.pixels[x + y*w] = color((int)(sumPixels/sumCoeff));
      
    }
  }
  return result;
}