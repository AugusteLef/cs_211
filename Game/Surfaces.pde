class Surfaces {
  PGraphics backgroundSurface; 
  PGraphics topView;
  
  Surfaces() {
    backgroundSurface = createGraphics(BOARD_SIZE, BOARD_SIZE / 5, P2D);
    topView = createGraphics(TOP_VIEW_SIZE, TOP_VIEW_SIZE, P2D);
  }
  void drawAllSurfaces() {
    drawBackgroundSurface();
    drawTopView();
  }
  void showAllSurfaces() {
    image(backgroundSurface, 0, 4 * BOARD_SIZE / 5); 
    image(topView, 25, (4 * BOARD_SIZE / 5) + 25);
  }
  void drawBackgroundSurface() {
    backgroundSurface.beginDraw();
    backgroundSurface.background(128, 222, 234);
    backgroundSurface.endDraw();
  }
  void drawTopView() {
    topView.beginDraw();
    topView.background(178, 45, 104);
    topView.stroke(0);
    topView.fill(123,76,212);
    topView.ellipse((mover.location.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X,(mover.location.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z,TOP_VIEW_SPHERE+10,TOP_VIEW_SPHERE+10);
    for(PVector p:shapes.cylinders){
      topView.stroke(0);
      topView.fill(10,111,134);
      topView.ellipse((p.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X,(p.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z,TOP_VIEW_CYLINDER_RADIUS+10,TOP_VIEW_CYLINDER_RADIUS+10);
    }
    for(PVector c:shapes.squares){
      topView.stroke(0);
      topView.fill(0,111,134);
      topView.rect(((c.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X)-(TOP_VIEW_CUBE_EDGE/2),((c.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z)-(TOP_VIEW_CUBE_EDGE/2),TOP_VIEW_CUBE_EDGE,TOP_VIEW_CUBE_EDGE);
    }
    topView.endDraw();
  }
  
}