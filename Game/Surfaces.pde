class Surfaces {
  PGraphics backgroundSurface; 
  Surfaces() {
    backgroundSurface = createGraphics(BOARD_SIZE, BOARD_SIZE / 4, P2D);
  }
  void drawBackgroundSurface() {
    backgroundSurface.beginDraw();
    backgroundSurface.background(128, 222, 234);
    backgroundSurface.endDraw();
  }
}