import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;
import java.util.List;
import java.util.Set;
import java.util.Random;
import java.util.HashSet;
import java.util.Arrays;

class BlobDetection {

  int getLabel(int x, int y, int w, int h, int[] labels) {
    if (x < 0 || y < 0 || x >= w || y >= h) return Integer.MAX_VALUE;
    else if (labels[y*w + x] == 0) return Integer.MAX_VALUE;
    else return labels[y*w + x];
  }
  
  List<Integer> getNeighbours(int x, int y, int w, int h, int[] labels) {
    List<Integer> list = new ArrayList<Integer>();
    list.add(getLabel(x-1, y-1, w, h, labels));
    list.add(getLabel(x, y-1, w, h, labels));
    list.add(getLabel(x+1, y-1, w, h, labels));
    list.add(getLabel(x-1, y, w, h, labels));

    return list;
  }

  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    // First pass: label the pixels and store labels’ equivalences
    int [] labels = new int [input.width*input.height];
    Map<Integer, Set<Integer>> labelsEquivalence = new HashMap<Integer, Set<Integer>>();

    int currentLabel=1;

    input.loadPixels();
    int w = input.width;
    int h = input.height;

    int temp = 0;
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        if (input.pixels[w*y + x] == color(0)) {
          labels[w*y + x] = 0;
        } else {
          List<Integer> ls = getNeighbours(x, y, w, h, labels);
          int minLabel = Collections.min(ls);
          int currLabel = (minLabel == Integer.MAX_VALUE ? currentLabel++ : minLabel);
          labels[w*y + x] = currLabel;

          if (!labelsEquivalence.containsKey(currLabel)) {
            Set<Integer> set = new HashSet<Integer>();
            set.add(currLabel);
            labelsEquivalence.put(currLabel, set);
          }

          Set<Integer> set = labelsEquivalence.get(currLabel);
          for (int neighbourLabel : ls) {
            if (neighbourLabel < Integer.MAX_VALUE)
              set.addAll(labelsEquivalence.get(neighbourLabel));
          }

          for (int neighbourLabel : ls) {
            if (neighbourLabel < Integer.MAX_VALUE)
              labelsEquivalence.get(neighbourLabel).addAll(set);
          }
        }
      }
    }

    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    // TODO!
    //Map<Integer, Integer> labelCount = new HashMap<Integer, Integer>();
    int [] labelVal = new int[currentLabel];
    int [] labelCount = new int[currentLabel];
    Arrays.fill(labelVal, Integer.MAX_VALUE); 

    int minCurrVal;
    for (int i = 0; i < currentLabel; ++i) {
      labelVal[i] = Math.min(i, labelVal[i]);
      for (Set<Integer> set : labelsEquivalence.values()) {
        if (set.contains(i)) {
          minCurrVal = Collections.min(set);
          labelVal[i] = Math.min(minCurrVal, labelVal[i]);
        }
      }
    }
    
    temp = 0;
    int total;
    int currentElem;
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        total = temp + x;
        currentElem = labels[total];
        if (currentElem != 0) {
          currentElem = labelVal[currentElem];
          labels[total] = currentElem;
          labelCount[currentElem]++;
        }
      }
      temp += w;
    }

    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
    // TODO!
    PImage result = createImage(w, h,RGB);
    result.loadPixels();
    Map<Integer, Integer> toColorize = new HashMap<Integer, Integer>();
    //List<Integer> l = Arrays.asList(labelCount);
    //int maxCount = (int) Collections.min(Arrays.asList(labelCount));
    int maxCount = 0;
    if (onlyBiggest)
      for (int i = 0; i < labelCount.length; ++i) 
        if (labelCount[i] > maxCount) maxCount = labelCount[i]; 

    Random random = new Random();
    //colorblack :
    toColorize.put(0, color(0));
    temp = 0;
    total = 0;
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        total = temp + x;
        int label = labels[total];

        if (!onlyBiggest || labelCount[label] == maxCount)
          if (toColorize.containsKey(label)) {
            result.pixels[total] = toColorize.get(label);
          } else {
            int rgb = color(random.nextInt(255), random.nextInt(255), random.nextInt(255));
            toColorize.put(label, rgb);
            result.pixels[total] = rgb;
          }
      }
      temp += w;
    }
    
    result.updatePixels();
    return result;
  }
}