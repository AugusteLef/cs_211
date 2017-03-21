float depth = 3000; // Default camera depth
final static float cylinderBaseSize = 100;
final static float cylinderHeight = -250;
final float maxAngle = PI/3;
final static int BOARD_SIZE = 1000;
final static int SPHERE = 100;
final static int BOX_X = 1500;
final static int BOX_Z = 1500;
final static int BOX_Y = 100;
PVector gravity  = new PVector(0, 0, 0);
PVector location = new PVector(width/2, height/2 - BOX_Y - SPHERE, 0);
PVector velocity = new PVector(0, 0, 0); 
PVector friction = new PVector(0, 0, 0);
float rebond = 0.7;
float gravityConstant = 1;
float normalForce = 1;
float mu = 0.01;
float frictionMagnitude = normalForce * mu;
boolean paused = false;

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
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], 0, y[i]);
    openCylinder.vertex(x[i], cylinderHeight, y[i]);
  }
  openCylinder.endShape();

  coverTop = createShape();
  coverTop.beginShape(TRIANGLE);

  for (int i = 0; i < x.length; ++i) {
    coverTop.vertex(x[i], cylinderHeight, y[i]);
    coverTop.vertex(0, cylinderHeight, 0);
  }
  coverTop.endShape();
  coverBot = createShape();
  coverBot.beginShape(TRIANGLE);

  for (int i = 0; i < x.length; ++i) {
    coverBot.vertex(x[i], 0, y[i]);
    coverBot.vertex(0, 0, 0);
  }
  coverBot.endShape();
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
// Initalise mouse_before/after to follow mouse position and rx/rz to save angle
int mouseZ_before = 0;
int mouseZ_after = 0;
float rz = 0;
int mouseX_before = 0;
int mouseX_after = 0;
float rx = 0;

// Initialize speed

float speed = 1000;
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
    if (rz > maxAngle)
      rz = maxAngle;
    else if (rz < - maxAngle) 
      rz = -maxAngle;

    // Save new mouse position
    mouseZ_before = mouseZ_after;

    // X AXIS : 

    // Save new mouse position
    mouseX_after = mouseY;
    //Increase the angle by the differnce between mouse positions
    rx = rx + (mouseX_before - mouseX_after) * PI/speed;

    // If the angle is too big or to small, readjust it
    if (rx > maxAngle)
      rx = maxAngle;
    else if (rx < - maxAngle) 
      rx = -maxAngle;

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
  
  for(PVector pos : cylinders){
    if(Math.pow(location.x - pos.x,2) + Math.pow(location.z - pos.z, 2) < Math.pow(SPHERE + cylinderBaseSize, 2) + 1){
      PVector normal2 = new PVector(location.x - pos.x, location.z - pos.z);
      PVector velocity2D = new PVector(velocity.x, velocity.z);
      float angle = 2*PVector.angleBetween(velocity2D,normal2);
      if((velocity2D.x == 0 && normal2.x < 0)||(velocity2D.x/velocity2D.y)>(normal2.x/normal2.y))
        angle *= -1;
      velocity2D.rotate(angle).setMag(velocity.mag());
      println("v1 "+velocity);
      velocity = new PVector(velocity2D.x*rebond, 0, velocity2D.y*rebond);
      println("v2 "+velocity);
      
      
      
      PVector normal = new PVector(location.x - pos.x, 0, location.z - pos.z);
      float coefXY = (float)(Math.pow(cylinderBaseSize + SPHERE, 2)/(normal.z*normal.z+(normal.x*normal.x)));
      location = new PVector(Math.signum(normal.x)*(float)Math.sqrt(normal.x*normal.x*coefXY) + pos.x, location.y , Math.signum(normal.z)*(float)Math.sqrt(normal.z*normal.z*coefXY) + pos.z);
    }
  }
}

void mouseClicked() {
  if (paused) {
    int x = mouseX;
    int y = mouseY;
    x = (int)((x-width/2) * depth/BOARD_SIZE);
    y = (int)((y-height/2) * depth/BOARD_SIZE);

    if (x + cylinderBaseSize < BOX_X/2 && x - cylinderBaseSize > -BOX_X/2 &&
      y + cylinderBaseSize < BOX_Z/2 && y - cylinderBaseSize > -BOX_Z/2 &&
      Math.pow(location.x - x,2) + Math.pow(location.z - y, 2) >= Math.pow(SPHERE + cylinderBaseSize, 2)) {

      cylinders.add(new PVector(x, 0, y));
    }
  }
}