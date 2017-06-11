class Hough {
  private final static int RADIUS_AREA = 10;
  float discretizationStepsPhi = 0.06f; 
  float discretizationStepsR = 2.5f;
  Map<Float, Float> tabSin = new HashMap();
  Map<Float, Float> tabCos = new HashMap();
  int minVotes=50;
  
  float gcos(float cos){
    if(tabCos.containsKey(cos))return tabCos.get(cos);
    float out = cos(cos);
    tabCos.put(cos, out);
    return out;
  }
  float gsin(float sin){
    if(tabSin.containsKey(sin))return tabSin.get(sin);
    float out = sin(sin);
    tabSin.put(sin, out);
    return out;
  }
  
  List<PVector> hough(PImage edgeImg, int nlines) {

    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();


    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
      edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
    // our accumulator
    int[] accumulator = new int[phiDim * rDim];
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; ++y) {
      for (int x = 0; x < edgeImg.width; ++x) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator: r += rDim / 2

          for (float phi = 0; phi < Math.PI; phi += discretizationStepsPhi) {
           float r = x*gcos(phi) + y*gsin(phi) ;
           accumulator[(int)(phi/discretizationStepsPhi * rDim + r/discretizationStepsR + rDim/2)] ++;
           }
          
        }
      }
    }
    for (int idx = 0; idx < accumulator.length; ++idx) {
      if (accumulator[idx] > minVotes) {
        int x = idx % rDim;
        int y = (int)(idx / rDim);
        float localMax = accumulator[idx];
        boolean exit = false;
        int xSize = x + RADIUS_AREA;
        int ySize = y + RADIUS_AREA;
        for (int i = x - RADIUS_AREA; i <= xSize; ++i) {
          for (int j = y - RADIUS_AREA; j <= ySize; ++j) {

            if (i < 0 || i >= rDim || j < 0 || j >= phiDim) {
            } else {
            
              if (accumulator[j*rDim + i] > localMax) {

                exit = true;
                break;
              }
            }
          }
         
          if (exit)break;
        }
        if (!exit) {
           bestCandidates.add(idx);
        }
      }
    }

    if (nlines <= bestCandidates.size()) {
      Collections.sort(bestCandidates, new HoughComparator(accumulator));
    }
    ArrayList<PVector> bestLines = new ArrayList<PVector>();
    
    for (int i = 0; i < min(nlines, bestCandidates.size()); ++i) {
      int idx = bestCandidates.get(i);
      int accPhi = (int) (idx / (rDim));
      int accR = idx - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      PVector line = new PVector(r, phi);
      bestLines.add(line);
     
    }
    return bestLines;
  }
  void drawLines(List<PVector> lines, PImage img) {
    for (PVector line : lines) {
     
      float r = line.x;
      float phi = line.y;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      //TODO
      float sinPhi = gsin(phi);
      float rSinPhi = r/sinPhi;
      float cosPhi = gcos(phi);
      float rCosPhi = r/cosPhi;
      int y0 = (int) rSinPhi;
      int x1 = (int)rCosPhi;
      int y1 = 0;
      int x2 = img.width;
      int y2 = (int) (- cosPhi / sinPhi * x2 + rSinPhi);
      int y3 = img.width;
      int x3 = (int) (-(y3 - rSinPhi) * (sinPhi / cosPhi));
      // Finally, plot the lines
     strokeWeight(5);
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0){
          line(x0, y0, x1, y1);
        }
        else if (y2 > 0){
          line(x0, y0, x2, y2);
        }
        else{
          line(x0, y0, x3, y3);
        }
      } else {
        if (x1 > 0) {
          if (y2 > 0){
            line(x1, y1, x2, y2);
          }
          else{
            line(x1, y1, x3, y3);
          }
        } else{
          line(x2, y2, x3, y3);
        }
      }
    }
  }
  
  class HoughComparator implements java.util.Comparator<Integer> {
    int[] accumulator;
    public HoughComparator(int[] accumulator) {
      this.accumulator = accumulator;
    }
    @Override
      public int compare(Integer l1, Integer l2) {
      if (accumulator[l1] > accumulator[l2]
        || (accumulator[l1] == accumulator[l2] && l1 < l2)) return -1;
      return 1;
    }
  }
}