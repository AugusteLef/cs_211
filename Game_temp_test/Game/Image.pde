class Image {
  //OpenCV opencv;
  PVector correctRotation = new PVector(0, 0, 0);
  Random rd = new Random();
  BlobDetection blob = new BlobDetection();
  Hough hough = new Hough();
  QuadGraph qg = new QuadGraph();
  TwoDThreeD tdtd;

  public Image(int w, int h) {
    //opencv = new OpenCV(this, 100, 100);
    tdtd = new TwoDThreeD(w, h, 0);
  }


  /*img.widthoid settings() {
   size(1600, 1200);
   }
   void setup() {
   img = loadImage("board4.jpg");
   noLoop();
   opencv = new OpenCV(this,100,100);
   tdtd = new TwoDThreeD(img.width, img.height, 0);
   }*/
  PVector drawImage(PImage img, PGraphics toDraw1) {
    

    float[][] blur = {
      {9, 12, 9}, 
      {12, 15, 12}, 
      {9, 12, 9}
    };

    PImage img2 = thresholdHSB(img, 67, 138, 86, 255, 35, 200); 
    img2 = thresholdBinary(img2, 10, false);
    img2 = convolute(img2, blur);
    img2 = blob.findConnectedComponents(img2, true);

    PImage img3 = convolute(img2, blur);
    img3 = scharr(img3);

    List<PVector> edges = hough.hough(img3, 4);
    //hough.drawLines(edges, img3);

    List<PVector> vertices = qg.findBestQuad(edges, img3.width, img3.height, img3.width*img3.height, 100, true);

    //TODO REMOVE (?)
    /*if (img.width == toDraw1.width) {
      toDraw1.beginDraw();
      toDraw1.background(img);
      toDraw1.endDraw();
    }
    
    toDraw1.beginDraw();
    for (PVector pv : vertices) {
      toDraw1.ellipse(pv.x, pv.y, 20, 20);
    }
    toDraw1.endDraw();
    */
    
    
    if (vertices.size() < 4) return correctRotation;

    //toDraw1.image(img2, img2.width, 0);
    //image(img3, 0, img3.height);

    List<PVector> vertInHomogenous = new ArrayList<PVector>();
    for (PVector pv : vertices) {
      vertInHomogenous.add(new PVector(pv.x, pv.y, 1));
    }
    PVector rotation =  tdtd.get3DRotations(vertInHomogenous);
    correctRotation = new PVector(rotation.x > PI/2 ? rotation.x -PI : (rotation.x < -PI/2 ? rotation.x + PI : rotation.x), 
      rotation.y > PI/2 ? rotation.y - PI : (rotation.y < -PI/2 ? rotation.y + PI : rotation.y), 
      rotation.z > PI/2 ? rotation.z - PI : (rotation.z < -PI/2 ? rotation.z + PI : rotation.z));
    println("rx = " + correctRotation.x + " ry = " + correctRotation.y + " rz = " + correctRotation.z);

    toMove.x = correctRotation.x;
    toMove.z = correctRotation.z;
    return correctRotation;
  }

  PImage thresholdBinary(PImage img, int threshold, boolean inverted) {
    // create a new, initially transparent, 'result' image
    img.loadPixels();
    PImage result = createImage(img.width, img.height, RGB);
    result.loadPixels();
    int sizeMax = img.width * img.height;
    for (int i = 0; i < sizeMax; i++) {
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
    int sizeMax = img.width * img.height;
    for (int i = 0; i < sizeMax; i++) {

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
}