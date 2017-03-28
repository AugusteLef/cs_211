class Surfaces {
  PGraphics backgroundSurface; 
  
  Surfaces() {
    backgroundSurface = createGraphics(BOARD_SIZE, BOARD_SIZE / 5, P2D);
  }
  void drawAllSurfaces() {
    drawBackgroundSurface();
  }
  void showAllSurfaces() {
    image(backgroundSurface, 0, 4 * BOARD_SIZE / 5); 
  }
  void drawBackgroundSurface() {
    backgroundSurface.beginDraw();
    backgroundSurface.background(128, 222, 234);
    backgroundSurface.endDraw();
  }
  
}