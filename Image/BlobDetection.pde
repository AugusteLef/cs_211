import java.util.ArrayList;
import java.util.Collections;

import java.util.List;
import java.util.TreeSet;

List<Color> colors = new ArrayList<>();
class BlobDetection {

  int getLabel(int x, int y, int w, int h, int[] labels) {
    if (x < 0 || y < 0 || x >= w || y >= h) return Integer.MAX_VALUE;
    else return labels[y*w + x];
  }
  List<Integer> getNeighbours(int x, int y, int w, int h, int[] labels) {
    List<Integer> list = new ArrayList<>();
    list.add(getLabel(x-1, y-1, w, h, labels));
    list.add(getLabel(x, y-1, w, h, labels));
    list.add(getLabel(x+1, y-1, w, h, labels));
    list.add(getLabel(x-1, y, w, h, labels));

    return list;
  }

  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    // First pass: label the pixels and store labels’ equivalences
    int [] labels = new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
    int currentLabel=1;

    input.loadPixels();
    int w = input.width;
    int h = input.height;


    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        if (input.pixels[y*w + x] == 0) {
          labels[y*w + x] = 0;
        }
        if (input.pixels[y*w + x] == 255) {
          List<Integer> ls = getNeighbours(x, y, w, h, labels);
          int minLabel = Collections.min(ls);
          labels[y*w + x] = (minLabel == Integer.MAX_VALUE ? ++currentLabel : minLabel); 
          for (int elem : ls) {
            if (elem < Integer.MAX_VALUE) {
              labelsEquivalences.get(labels[y*w + x]).add(elem);
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
        for (TreeSet<Integer> set : labelsEquivalences) {
          if (set.contains(labels[y*w + x])) {
            labels[y*w + y] = Collections.min(set); 
            if (onlyBiggest) labelCount[labels[y*w + y]]++;
          }
        }
      }



      // Finally,
      // if onlyBiggest==false, output an image with each blob colored in one uniform color
      // if onlyBiggest==true, output an image with the biggest blob colored in white a  nd the others in black
      // TODO!

      if (!onlyBiggest) {
        for (int y = 0; y < h; ++y) {
          for (int x = 0; x < w; ++x) {
            
          }
        }


          return null;
        }
      }
      
      Color getColor(int i) {
        return Color.random();
      }