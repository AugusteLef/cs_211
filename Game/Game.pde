final static float CYLINDER_RADIUS = 100;
final static float CYLINDER_HEIGHT = -250;
final static float MAX_ANGLE = PI/3;
final static int BOARD_SIZE = 1000;
final static int SPHERE = 100;
final static int BOX_X = 1500;
final static int BOX_Z = 1500;
final static int BOX_Y = 100;
PVector gravity  = new PVector(0, 0, 0);
PVector location = new PVector(width/2-SPHERE/2, height/2 - BOX_Y - SPHERE, 0);
PVector velocity = new PVector(0, 0, 0); 
PVector friction = new PVector(0, 0, 0);
float depth = 3000; // Default camera depth
float rebond = 0.7;
float gravityConstant = 1;
float normalForce = 1;
float mu = 0.01;
float frictionMagnitude = normalForce * mu;
boolean paused = false;

// Initalise mouse_before/after to follow mouse position and rx/rz to save angle
int mouseZ_before = 0;
int mouseZ_after = 0;
float rz = 0;
int mouseX_before = 0;
int mouseX_after = 0;
float rx = 0;
//Speed game moves (box and items)
float speed = 1000;

color c;
ArrayList<PVector> cylinders = new ArrayList();

int cylinderResolution = 25;
PShape openCylinder = new PShape();
PShape coverTop = new PShape();
PShape coverBot = new PShape();

void settings() {
  size(BOARD_SIZE, BOARD_SIZE, P3D);
}
void setup() {
  noStroke();
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * CYLINDER_RADIUS;
    y[i] = cos(angle) * CYLINDER_RADIUS;
  }
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], 0, y[i]);
    openCylinder.vertex(x[i], CYLINDER_HEIGHT, y[i]);
  }
  openCylinder.endShape();

  coverTop = createShape();
  coverTop.beginShape(TRIANGLE);
  for (int i = 0; i < x.length-1; ++i) {
    coverTop.vertex(x[i], CYLINDER_HEIGHT, y[i]);
    coverTop.vertex(0, CYLINDER_HEIGHT, 0);
    coverTop.vertex(x[i + 1], CYLINDER_HEIGHT, y[i+1]);
  }
  coverTop.endShape();
  
  
  /* Bot is useless here
  coverBot = createShape();
  coverBot.beginShape(TRIANGLE);
  for (int i = 0; i < x.length-1; ++i) {
    coverBot.vertex(x[i], 0, y[i]);
    coverBot.vertex(0, 0, 0);
    coverTop.vertex(x[i + 1], 0, y[i+1]);
  }
  coverBot.endShape();*/
}
void draw() {
  // New lights
  directionalLight(50, 100, 125, 1, 1, 0);
  ambientLight(102, 102, 102);

  // Position camera in the center of the screen
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  // WHite background
  background(255);

  // Set correct position for the box
  translate(width/2, height/2, 0); // Place it in the center of the screen

  if (!paused) {
    // use the rotation that is defined by mouse action
    rotateZ(rz);
    rotateX(rx);


    // Create the box with a color
    c = color(0, 172, 190);
    fill(c);
    box(BOX_X, BOX_Y, BOX_Z);

    for (PVector p : cylinders) {
      translate(p.x, p.y, p.z);
      shape(openCylinder);
      shape(coverBot);
      shape(coverTop);
      translate(-p.x, -p.y, -p.z);
    }
    updatePos();
    // Create sphere with a color
    c = color(255, 0, 10);
    fill(c);
    sphere(SPHERE);
  } else {
    rotateX(-PI/2);
    // Create the box with a color
    c = color(0, 172, 190);
    fill(c);
    box(BOX_X, BOX_Y, BOX_Z);

    for (PVector p : cylinders) {
      translate(p.x, p.y, p.z);
      shape(openCylinder);
      shape(coverBot);
      shape(coverTop);
      translate(-p.x, -p.y, -p.z);
    }
    // Create sphere with a color
    translate(location.x, location.y, location.z);
    c = color(255, 0, 10);
    fill(c);
    sphere(SPHERE);
  }
}



void updatePos() {

  gravity.x = sin(rz) * gravityConstant;
  gravity.z = - sin(rx) * gravityConstant;

  friction = velocity.get().mult(-1).normalize().mult(frictionMagnitude);

  velocity.add(gravity);
  velocity.add(friction);
  location.add(velocity);

  checkEdges();

  translate(location.x, location.y, location.z);
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
}
void keyReleased() {
  if (key == CODED) {
    // Resume the game when SHIFT pressed
    if (keyCode == SHIFT) {
      paused = false;
    }
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

void checkEdges() {

  //Check for the Box boundings
  float limitX = (BOX_X/2 - SPHERE);
  float limitZ = (BOX_Z/2 - SPHERE);
  if (location.x >= limitX) {
    location.x = limitX;
    velocity.x *= -rebond;
  } else if (location.x <= - limitX) {
    location.x = - limitX;
    velocity.x *= -rebond;
  }
  if (location.z >= limitZ) {
    location.z = limitZ;
    velocity.z *= -rebond;
  } else if (location.z <= - limitZ) {
    location.z = - limitZ;
    velocity.z *= -rebond;
  }

  for (PVector pos : cylinders) {
    if (Math.pow(location.x - pos.x, 2) + Math.pow(location.z - pos.z, 2) < Math.pow(SPHERE + CYLINDER_RADIUS, 2)) {
      PVector normal2 = new PVector(location.x - pos.x, location.z - pos.z);
      PVector velocity2D = new PVector(velocity.x, velocity.z);
      float angle = 2*PVector.angleBetween(velocity2D, normal2);
      if ((velocity2D.x == 0 && normal2.x < 0)||(velocity2D.x/velocity2D.y)>(normal2.x/normal2.y))
        angle *= -1;
      velocity2D.rotate(angle).setMag(velocity.mag());
      velocity = new PVector(- velocity2D.x*rebond, 0, - velocity2D.y*rebond);



      PVector normal = new PVector(location.x - pos.x, 0, location.z - pos.z);
      float coefXY = (float)(Math.pow(CYLINDER_RADIUS + SPHERE, 2)/(normal.z*normal.z+(normal.x*normal.x)));
      location = new PVector(Math.signum(normal.x)*(float)Math.sqrt(normal.x*normal.x*coefXY) + pos.x, location.y, Math.signum(normal.z)*(float)Math.sqrt(normal.z*normal.z*coefXY) + pos.z);
    }
  }
  
  /* Bouncing with squares, to be tested!*/
  int edge = 2;
  for(PVector pos : squares){
    PVector topLeft = new PVector(pos.x - edge/2, pos.z - edge/2);
    PVector topRight = new PVector(pos.x + edge/2, pos.z - edge/2);
    PVector botLeft = new PVector(pos.x - edge/2, pos.z + edge/2);
    PVector botRight = new PVector(pos.x -+ edge/2, pos.z + edge/2);
    if(location.x + SPHERE >= pos.x - edge/2 && location.x - SPHERE <= pos.x + edge/2 && location.y <= pos.y + edge/2 && location.y >= pos.y - edge/2){
      if(location.x < pos.x)
        location.x = pos.x - edge/2 - SPHERE;
      else
        location.x = pos.x + edge/2 + SPHERE;
      velocity.x *= -rebond;
    }else if(location.y + SPHERE >= pos.y - edge/2 && location.y - SPHERE <= pos.y + edge/2 && location.x <= pos.x + edge/2 && location.x >= pos.x - edge/2){
      if(location.y < pos.y)
        location.y = pos.y - edge/2 - SPHERE;
      else
        location.y = pos.y + edge/2 + SPHERE;
        velocity.y *= -rebond;
    }else if(Math.pow(location.x - topLeft.x, 2) + Math.pow(location.y - topLeft.y, 2) <= SPHERE*SPHERE){
      squareCorner(topLeft);
    }else if(Math.pow(location.x - topRight.x, 2) + Math.pow(location.y - topRight.y, 2) <= SPHERE*SPHERE){
      squareCorner(topRight);
    }else if(Math.pow(location.x - botLeft.x, 2) + Math.pow(location.y - botLeft.y, 2) <= SPHERE*SPHERE){
      squareCorner(botLeft);
    }else if(Math.pow(location.x - botRight.x, 2) + Math.pow(location.y - botRight.y, 2) <= SPHERE*SPHERE){
      squareCorner(botRight);
    }
  }
  
  
}
//Inner method for bouncing with squares in the corners
void squareCorner(PVector cornerPos){
  PVector normal2 = new PVector(location.x - cornerPos.x, location.z - cornerPos.z);
  PVector velocity2D = new PVector(velocity.x, velocity.z);
  float angle = 2*PVector.angleBetween(velocity2D, normal2);
  if ((velocity2D.x == 0 && normal2.x < 0)||(velocity2D.x/velocity2D.y)>(normal2.x/normal2.y))
     angle *= -1;
  velocity2D.rotate(angle).setMag(velocity.mag());
  velocity = new PVector(- velocity2D.x*rebond, 0, - velocity2D.y*rebond);
  
  PVector normal = new PVector(location.x - cornerPos.x, 0, location.z - cornerPos.z);
  float coefXY = (float)(Math.pow(SPHERE, 2)/(normal.z*normal.z+(normal.x*normal.x)));
  location = new PVector(Math.signum(normal.x)*(float)Math.sqrt(normal.x*normal.x*coefXY) + cornerPos.x, location.y, Math.signum(normal.z)*(float)Math.sqrt(normal.z*normal.z*coefXY) + cornerPos.z);
}

void mouseClicked() {
  if (paused) {
    int x = mouseX;
    int y = mouseY;
    x = (int)((x-width/2) * (depth-BOX_Y/2)/width*1.15);
    y = (int)((y-height/2) * (depth-BOX_Y/2)/height*1.15);

    if (x + CYLINDER_RADIUS < BOX_X/2 && x - CYLINDER_RADIUS > -BOX_X/2 &&
      y + CYLINDER_RADIUS < BOX_Z/2 && y - CYLINDER_RADIUS > -BOX_Z/2 &&
      Math.pow(location.x - x, 2) + Math.pow(location.z - y, 2) >= Math.pow(SPHERE + CYLINDER_RADIUS, 2)) {

      cylinders.add(new PVector(x, 0, y));
    }
  }
}