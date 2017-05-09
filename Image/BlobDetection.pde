import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;
import java.util.List;
import java.util.Set;
import java.util.Random;
import java.util.HashSet;


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
    
    
    
    //List<Set<Integer>> labelsEquivalences = new ArrayList<Set<Integer>>();
    int currentLabel=1;

    input.loadPixels();
    int w = input.width;
    int h = input.height;

    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        if (input.pixels[y*w + x] == color(0)) {
          labels[y*w + x] = 0;
        }else{
          List<Integer> ls = getNeighbours(x, y, w, h, labels);
          int minLabel = Collections.min(ls);
          int currLabel = (minLabel == Integer.MAX_VALUE ? currentLabel++ : minLabel);
          labels[y*w + x] = currLabel;
          
          if (!labelsEquivalence.containsKey(currLabel)) labelsEquivalence.put(currLabel, new HashSet<Integer>());
          Set<Integer> set = labelsEquivalence.get(currLabel);
          for (int neighbourLabel : ls) {
            if (neighbourLabel < Integer.MAX_VALUE) {
              set.add(neighbourLabel);
              labelsEquivalence.get(neighbourLabel).add(currLabel);
            }            
          }
        }
      }
    }




    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    // TODO!
    int [] labelCount = new int[currentLabel];
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        for (Set<Integer> set : labelsEquivalence.values()) {
          if (set.contains(labels[y*w + x])) {
            labels[y*w + x] = Collections.min(set); 
            if (onlyBiggest) labelCount[labels[y*w + y]]++;
          }
        }
      }
    }



    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
    // TODO!
    PImage result = createImage(w, h, ALPHA);
    result.loadPixels();
    Map<Integer, Integer> toColorize = new HashMap<Integer, Integer>();
    if (!onlyBiggest) {
      Random random = new Random();
      //colorblack :
      toColorize.put(0, color(0));
      for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
          int label = labels[y*w + x];
          if (toColorize.containsKey(label)) {
            result.pixels[y*w + x] = toColorize.get(label);
            
          } else {
            int rgb = color(random.nextInt(255), random.nextInt(255), random.nextInt(255));
            toColorize.put(label, rgb);
            result.pixels[y*w + x] = rgb;
          }
        }
        
      }
    } else {
      for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
          if (labels[y*w + x] != currentLabel-1) result.pixels[y*w + x] = color(0);
          else result.pixels[y*w + x] = color(255);
        }
      }
    }
    result.updatePixels();


    return result;
  }
}