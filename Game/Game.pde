//Objects
Mover mover;
Shapes shapes;
Surfaces surfaces;
HScrollbar scroll_bar;

//Constants
final static float CYLINDER_RADIUS = 100;
final static float CYLINDER_HEIGHT = -250;
final static float MAX_ANGLE = PI/3;
final static int BOARD_SIZE = 1000;
final static int SPHERE = 100;
final static int BOX_X = 1500;
final static int BOX_Z = 1500;
final static int BOX_Y = 100;
final static int NB_OF_SQUARES = 10;
final static int CUBE_EDGE = BOX_X/NB_OF_SQUARES;
//Top View constants
final static int TOP_VIEW_SIZE = 150;
final static float TOP_VIEW_CYLINDER_RADIUS = (CYLINDER_RADIUS/BOX_X)*TOP_VIEW_SIZE;
final static float TOP_VIEW_SPHERE = ((float)SPHERE/BOX_X)*TOP_VIEW_SIZE;
final static float TOP_VIEW_CUBE_EDGE = ((float) CUBE_EDGE/BOX_X)*TOP_VIEW_SIZE;

//Variables:
//Default camera depth
float depth = 3000; 
boolean paused = false;
boolean putSquares = false;
//Board angles
float rx = 0;
float rz = 0;
//Initalise mouse_before/after to follow mouse position and rx/rz to save angle
int mouseZ_before = 0;
int mouseZ_after = 0;
int mouseX_before = 0;
int mouseX_after = 0;
//Speed game moves (box and items)
float speed = 1000;
//Scores
float tot_score = 0;
float last_score = 0;
//Time
long game_tick = 0;

PImage img;

PGraphics gameGraphic;

ImageProcessing imgproc;
void settings() {
  size(BOARD_SIZE, BOARD_SIZE, P3D);
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
}

void setup() {
  gameGraphic = createGraphics(BOARD_SIZE, BOARD_SIZE, P3D);
  gameGraphic.noStroke();
  mover = new Mover();
  shapes = new Shapes();
  surfaces = new Surfaces();
  scroll_bar = new HScrollbar(BOARD_SIZE / 3, (4 * BOARD_SIZE / 5) + TOP_VIEW_SIZE + 30, 2*BOARD_SIZE / 3 - 25, 15);
  noStroke();

  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};

  PApplet.runSketch(args, imgproc);
}

void draw() {
  drawGame();
  drawSurfaces();
  scroll_bar.update();
  scroll_bar.display();
}

void drawSurfaces() {
  camera();
  noLights();
  //Create every surface
  surfaces.drawAllSurfaces();
  //Print every surface
  surfaces.showAllSurfaces();
}

void drawGame() {
  gameGraphic.beginDraw();
  gameGraphic.pushMatrix();

  //New lights
  gameGraphic.directionalLight(50, 100, 125, 1, 1, 0);
  gameGraphic.ambientLight(102, 102, 102);

  //Position camera in the center of the screen
  gameGraphic.camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);

  //White background
  gameGraphic.background(255);


  PVector rot = imgproc.getRotation();
  rx = rot.x;
  rz = rot.z;

  //Set correct position for the box
  gameGraphic.translate(width/2, height/2, 0);
  if (paused) {
    gameGraphic.rotateX(-PI/2);
  } else {
    gameGraphic.rotateZ(rz);
    gameGraphic.rotateX(rx);
  }

  //Draw the board
  color c = color(0, 172, 190);
  gameGraphic.fill(c);
  gameGraphic.box(BOX_X, BOX_Y, BOX_Z);

  //Draw the shapes
  shapes.drawShapes();
  if (!paused) {
    mover.update();
    ++game_tick;
  }

  //Display the ball
  mover.display();
  gameGraphic.popMatrix();
  gameGraphic.endDraw();
  image(gameGraphic, 0, 0);
}

void mouseMoved() {
  // Keep track of current mouse position
  mouseZ_before = mouseX;
  mouseX_before = mouseY;
}

/*void mouseDragged() 
{
  if (!paused) {
    //Z AXIS :
    //Save new mouse position
    mouseZ_after = mouseX;

    //Increase the angle by the differnce between mouse positions
    rz += (mouseZ_after - mouseZ_before) * PI/speed;

    //If the angle is too big or to small, readjust it
    if (rz > MAX_ANGLE) rz = MAX_ANGLE;
    else if (rz < - MAX_ANGLE) rz = -MAX_ANGLE;

    //Save new mouse position
    mouseZ_before = mouseZ_after;

    //X AXIS : 
    //Save new mouse position
    mouseX_after = mouseY;

    //Increase the angle by the differnce between mouse positions
    rx = rx + (mouseX_before - mouseX_after) * PI/speed;

    //If the angle is too big or to small, readjust it
    if (rx > MAX_ANGLE) rx = MAX_ANGLE;
    else if (rx < - MAX_ANGLE) rx = -MAX_ANGLE;

    //Save new mouse position
    mouseX_before = mouseX_after;
  }
}*/
void keyPressed() {
  //Changed depth of the camera when key pressed
  if (key == CODED) {
    if (keyCode == UP) depth -= 50; 
    else if (keyCode == DOWN) depth += 50;
    //Pause the game when SHIFT pressed
    else if (keyCode == SHIFT) paused = true;
  }

  //When the game is paused and we press q we can put Cubes on the board
  if ((key == 'Q' || key == 'q') && paused) putSquares = true;
}

void keyReleased() {
  if (key == CODED) {
    //Resume the game when SHIFT released, hence we cannot put cubes anymore
    if (keyCode == SHIFT) {
      paused = false;
      putSquares = false;
    }
  }
  //As soon as the q key is released we cannot put cubes anymore
  if (key == 'Q' || key == 'q') {
    putSquares = false;
  }
}
void mouseWheel(MouseEvent event) {
  //Register how mouse the wheel moved
  int wheelCount = (int)event.getCount();

  //Wheel going down => increase speed
  if (wheelCount < 0) {
    for (int i = 0; i < -wheelCount; ++i) {
      speed *= 1.02;
    }
  }

  //Wheel going up => deacrease speed
  else if (wheelCount > 0) {
    for (int i = 0; i < wheelCount; ++i) {
      speed /= 1.02;
    }
  }
}

void mouseClicked() {
  //Puts cylinders if the game is paused and we're not able to put Cubes
  if (paused && !putSquares) {
    //Mouse positions
    int x = mouseX;
    int y = mouseY;

    //Positions according to the board    
    x = (int)((x-width/2) * (depth-BOX_Y/2)/width*1.15);
    y = (int)((y-height/2) * (depth-BOX_Y/2)/height*1.15);

    //If those positions are bounded, it adds the cylinder to the cylinders array in the shapes object
    if (x + CYLINDER_RADIUS < BOX_X/2 && x - CYLINDER_RADIUS > -BOX_X/2 &&
      y + CYLINDER_RADIUS < BOX_Z/2 && y - CYLINDER_RADIUS > -BOX_Z/2 &&
      Math.pow(mover.location.x - x, 2) + Math.pow(mover.location.z - y, 2) >= Math.pow(SPHERE + CYLINDER_RADIUS, 2)) {
      shapes.cylinders.add(new PVector(x, 0, y));
    }
  }

  //Otherwise if we're able to put cubes:  
  else if (putSquares) {
    //Mouse positions
    int x = mouseX;
    int y = mouseY;

    //Positions according to the board
    x = (int)((x * (depth-BOX_Y/2)/width*1.15)-CUBE_EDGE/4)/CUBE_EDGE*CUBE_EDGE + CUBE_EDGE/2 - (int)(width/2 * (depth-BOX_Y/2)/width*1.15)/CUBE_EDGE*CUBE_EDGE;
    y = (int)((y * (depth-BOX_Y/2)/height*1.15)-CUBE_EDGE/4)/CUBE_EDGE*CUBE_EDGE + CUBE_EDGE/2 - (int)(height/2 * (depth-BOX_Y/2)/height*1.15)/CUBE_EDGE*CUBE_EDGE;

    //If those positions are bounded, it adds the cube to the square array in the shapes object
    if (!shapes.squares.contains(new PVector(x, -BOX_Y/2, y)) && x < BOX_X/2 && y < BOX_Z/2 && x > -BOX_X/2 && y > -BOX_Z/2)
      shapes.squares.add(new PVector(x, -BOX_Y/2, y));
  }
}