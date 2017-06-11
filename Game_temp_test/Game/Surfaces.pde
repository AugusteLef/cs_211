//Create and draw all surfaces used for the score / Top_view

class Surfaces {
  //Declare all 4 surfaces
  PGraphics backgroundSurface; 
  PGraphics topView;
  PGraphics scoreboard;
  PGraphics barChart;
  PGraphics testCamImage;
  
  //Default Size of a "box" from the graph
  int graph_box_x = 10;
  int graph_box_y = 5;
  
  //Current max_score the graph can show
  float max_score = 500;
  
  // Remember how the score changed during the game
  ArrayList<Integer> score_list = new ArrayList();


  Surfaces() {
    // Create all surfaces with their correct sizes
    backgroundSurface = createGraphics(BOARD_SIZE, BOARD_SIZE / 5, P2D);
    topView = createGraphics(TOP_VIEW_SIZE, TOP_VIEW_SIZE, P2D);
    scoreboard = createGraphics(TOP_VIEW_SIZE, TOP_VIEW_SIZE, P2D);
    barChart = createGraphics(2*BOARD_SIZE / 3 - 25, TOP_VIEW_SIZE, P2D);
    testCamImage = createGraphics(640, 360, P2D);
  }
  void drawAllSurfaces() {
    // Draw every Surface
    drawBackgroundSurface();
    drawTopView();
    drawScoreboard();
    drawBarChart();
  }
  void showAllSurfaces() {
    // "Print" every surface at their correct positions
    image(backgroundSurface, 0, 4 * BOARD_SIZE / 5); 
    image(topView, 25, (4 * BOARD_SIZE / 5) + 25);
    image(scoreboard, 50 + TOP_VIEW_SIZE, (4 * BOARD_SIZE / 5) + 25);
    image(barChart, BOARD_SIZE / 3, (4 * BOARD_SIZE / 5) + 25);
  }
  void drawBackgroundSurface() {
    //Draw the background surface
    backgroundSurface.beginDraw();
    backgroundSurface.background(128, 222, 234);
    backgroundSurface.endDraw();
  }
  void drawTopView() {
    //Draw the top view
    topView.beginDraw();
    //Draw the square on which we print the top view
    topView.background(178, 45, 104);
    topView.stroke(0);
    topView.fill(123, 76, 212);
    //Draw the ball on the top view
    topView.ellipse((mover.location.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X, (mover.location.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z, TOP_VIEW_SPHERE+10, TOP_VIEW_SPHERE+10);
    //Draw every cylinder
    for (PVector p : shapes.cylinders) {
      topView.stroke(0);
      topView.fill(10, 111, 134);
      topView.ellipse((p.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X, (p.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z, TOP_VIEW_CYLINDER_RADIUS+10, TOP_VIEW_CYLINDER_RADIUS+10);
    }
    
    //Draw every cube
    for (PVector c : shapes.squares) {
      topView.stroke(0);
      topView.fill(0, 111, 134);
      topView.rect(((c.x+BOX_X/2)*TOP_VIEW_SIZE/BOX_X)-(TOP_VIEW_CUBE_EDGE/2), ((c.z+BOX_Z/2)*TOP_VIEW_SIZE/BOX_Z)-(TOP_VIEW_CUBE_EDGE/2), TOP_VIEW_CUBE_EDGE, TOP_VIEW_CUBE_EDGE);
    }
    topView.endDraw();
  }
  void drawScoreboard() {
    //Draw the text version of the scoreboard
    scoreboard.beginDraw();
    scoreboard.background(128, 222, 234);
    //Set the text color to black
    scoreboard.fill(0);
    //Print score, velocity, last_score
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
    //We show score not on all ticks
    if (game_tick == 50) {
      game_tick = 0;
      //We implemented an adapting vertical scale. When the score is bigger than the max_score, 
      //we update the height of a "graph pixel" to reduce the scale
      //We don't update the scale after 1600 to keep the graph readable
      if (tot_score > max_score && tot_score < 1500) max_score = tot_score;
      graph_box_y = (int)((float)(10*TOP_VIEW_SIZE) / max_score );
      //We add the current score to the history of scores
      score_list.add((int)tot_score / 10);
    }
    //For each score in the score history
    for (int s = 0; s < score_list.size(); ++s) {
      //Draw every "pixel" of the score at the correct position
      for (int i = 0; i <= score_list.get(s); ++i) {
        barChart.fill(0, 255, 255);
        barChart.noStroke();
        barChart.rect(s*graph_box_x*scroll_bar.getPos(), TOP_VIEW_SIZE - i*graph_box_y, graph_box_x*scroll_bar.getPos(), graph_box_y);
      }
    }
    barChart.endDraw();
  }
}