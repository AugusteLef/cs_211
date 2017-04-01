

class Surfaces {
  PGraphics backgroundSurface; 
  PGraphics topView;
  PGraphics scoreboard;
  PGraphics barChart;
  int graph_box_x = 10;
  int graph_box_y = 5;
  float max_score = 500;

  int current_col = 0;
  ArrayList<Integer> score_list = new ArrayList();



  Surfaces() {
    backgroundSurface = createGraphics(BOARD_SIZE, BOARD_SIZE / 5, P2D);
    topView = createGraphics(TOP_VIEW_SIZE, TOP_VIEW_SIZE, P2D);
    scoreboard = createGraphics(TOP_VIEW_SIZE, TOP_VIEW_SIZE, P2D);
    barChart = createGraphics(2*BOARD_SIZE / 3 - 25, TOP_VIEW_SIZE, P2D);
  }
  void drawAllSurfaces() {
    drawBackgroundSurface();
    drawTopView();
    drawScoreboard();
    drawBarChart();
  }
  void showAllSurfaces() {
    image(backgroundSurface, 0, 4 * BOARD_SIZE / 5); 
    image(topView, 25, (4 * BOARD_SIZE / 5) + 25);
    image(scoreboard, 50 + TOP_VIEW_SIZE, (4 * BOARD_SIZE / 5) + 25);
    image(barChart, BOARD_SIZE / 3, (4 * BOARD_SIZE / 5) + 25);
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
    topView.fill(123, 76, 212);
    topView.ellipse((mover.location.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X, (mover.location.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z, TOP_VIEW_SPHERE+10, TOP_VIEW_SPHERE+10);
    for (PVector p : shapes.cylinders) {
      topView.stroke(0);
      topView.fill(10, 111, 134);
      topView.ellipse((p.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X, (p.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z, TOP_VIEW_CYLINDER_RADIUS+10, TOP_VIEW_CYLINDER_RADIUS+10);
    }
    for (PVector c : shapes.squares) {
      topView.stroke(0);
      topView.fill(0, 111, 134);
      topView.rect(((c.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X)-(TOP_VIEW_CUBE_EDGE/2), ((c.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z)-(TOP_VIEW_CUBE_EDGE/2), TOP_VIEW_CUBE_EDGE, TOP_VIEW_CUBE_EDGE);
    }
    topView.endDraw();
  }
  void drawScoreboard() {
    scoreboard.beginDraw();
    scoreboard.background(128, 222, 234);
    scoreboard.fill(0);
    scoreboard.text("Total Score : ", 0, 10);
    scoreboard.text(tot_score, 0, 25);
    scoreboard.text("Velocity : ", 0, 65);
    scoreboard.text(mover.velocity.mag(), 0, 80);
    scoreboard.text("Last Score : ", 0, 120);
    scoreboard.text(last_score, 0, 135);
    scoreboard.endDraw();
  }
  void drawBarChart() {
    barChart.beginDraw();
    barChart.background(255, 0, 0);
    if (game_tick == 50) {
      game_tick = 0;
      if (tot_score > max_score) {max_score = tot_score;}
      graph_box_y = (int)((float)(25*TOP_VIEW_SIZE) / max_score );
      score_list.add((int)tot_score / 25);
    }
    for (int s = 0; s < score_list.size(); ++s) {

      for (int i = 0; i < score_list.get(s); ++i) {
        barChart.fill(0, 255, 255);
        barChart.noStroke();
        barChart.rect(s*graph_box_x*scroll_bar.getPos(), TOP_VIEW_SIZE - i*graph_box_y, graph_box_x*scroll_bar.getPos(), graph_box_y);
      }
    }
    barChart.endDraw();
  }
}