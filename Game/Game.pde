Mover mover;
Shapes shapes;

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

float depth = 3000; // Default camera depth

boolean paused = false;
boolean putSquares = false;

// Board angles
float rx = 0;
float rz = 0;
// Initalise mouse_before/after to follow mouse position and rx/rz to save angle
int mouseZ_before = 0;
int mouseZ_after = 0;
int mouseX_before = 0;
int mouseX_after = 0;

//Speed game moves (box and items)
float speed = 1000;





void settings() {
  size(BOARD_SIZE, BOARD_SIZE, P3D);
}
void setup() {
  // Initalize Mover and Shapes
  mover = new Mover();
  shapes = new Shapes();
  noStroke();
}
void draw() {
  // New lights
  directionalLight(50, 100, 125, 1, 1, 0);
  ambientLight(102, 102, 102);

  // Position camera in the center of the screen
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  // White background
  background(255);

  // Set correct position for the box
  translate(width/2, height/2, 0); // Place it in the center of the screen
  if (paused) { // If paused, fixed rotation
    rotateX(-PI/2);
  } else { // Rotate with rx and rz
    rotateZ(rz);
    rotateX(rx);
  }
  
  // Draw the board
  color c = color(0, 172, 190);
  fill(c);
  box(BOX_X, BOX_Y, BOX_Z);
  
  // Draw the shapes
  shapes.drawShapes();
  if (!paused) { // If game running, update ball position
    mover.update();
  }
  
  // Display the ball
  mover.display();
}

void mouseMoved() {
  // Keep track of current mouse position
  mouseZ_before = mouseX;
  mouseX_before = mouseY;
}
void mouseDragged() 
{
  if (!paused) {
    // Z AXIS :

    // Save new mouse position
    mouseZ_after = mouseX;
    //Increase the angle by the differnce between mouse positions
    rz += (mouseZ_after - mouseZ_before) * PI/speed;

    // If the angle is too big or to small, readjust it
    if (rz > MAX_ANGLE)
      rz = MAX_ANGLE;
    else if (rz < - MAX_ANGLE) 
      rz = -MAX_ANGLE;

    // Save new mouse position
    mouseZ_before = mouseZ_after;

    // X AXIS : 

    // Save new mouse position
    mouseX_after = mouseY;
    //Increase the angle by the differnce between mouse positions
    rx = rx + (mouseX_before - mouseX_after) * PI/speed;

    // If the angle is too big or to small, readjust it
    if (rx > MAX_ANGLE)
      rx = MAX_ANGLE;
    else if (rx < - MAX_ANGLE) 
      rx = -MAX_ANGLE;

    // Save new mouse position
    mouseX_before = mouseX_after;

    // Call draw to update the view
  }
}
void keyPressed() {
  // Changed depth of the camera when key pressed
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    } // Pause the game when SHIFT pressed
    else if (keyCode == SHIFT) {
      paused = true;
    }
  }
  if ((key == 'Q' || key == 'q') && paused) {
    putSquares = true;
  }
}
void keyReleased() {
  if (key == CODED) {
    // Resume the game when SHIFT pressed
    if (keyCode == SHIFT) {
      paused = false;
      putSquares = false;
    }
  }
  if (key == 'Q' || key == 'q') {
    putSquares = false;
  }
}
void mouseWheel(MouseEvent event) {
  // Register how mouse the wheel moved
  int wheelCount = (int)event.getCount();

  // Wheel going down => increase speed
  if (wheelCount < 0) 
    for (int i = 0; i < -wheelCount; ++i)
      speed *= 1.02;
  // Wheel going up => deacrease speed
  else if (wheelCount > 0)
    for (int i = 0; i < wheelCount; ++i)
      speed /= 1.02;
}

void mouseClicked() {
  if (paused && !putSquares) {
    int x = mouseX;
    int y = mouseY;
    x = (int)((x-width/2) * (depth-BOX_Y/2)/width*1.15);
    y = (int)((y-height/2) * (depth-BOX_Y/2)/height*1.15);

    if (x + CYLINDER_RADIUS < BOX_X/2 && x - CYLINDER_RADIUS > -BOX_X/2 &&
      y + CYLINDER_RADIUS < BOX_Z/2 && y - CYLINDER_RADIUS > -BOX_Z/2 &&
      Math.pow(mover.location.x - x, 2) + Math.pow(mover.location.z - y, 2) >= Math.pow(SPHERE + CYLINDER_RADIUS, 2)) {
      shapes.cylinders.add(new PVector(x, 0, y));
    }
  } else if (putSquares) {
    int x = mouseX;
    int y = mouseY;
    x = (int)((x * (depth-BOX_Y/2)/width*1.15)-CUBE_EDGE/4)/CUBE_EDGE*CUBE_EDGE + CUBE_EDGE/2 - (int)(width/2 * (depth-BOX_Y/2)/width*1.15)/CUBE_EDGE*CUBE_EDGE;
    y = (int)((y * (depth-BOX_Y/2)/height*1.15)-CUBE_EDGE/4)/CUBE_EDGE*CUBE_EDGE + CUBE_EDGE/2 - (int)(height/2 * (depth-BOX_Y/2)/height*1.15)/CUBE_EDGE*CUBE_EDGE;
    shapes.squares.add(new PVector(x, -BOX_Y/2, y));
  }
}