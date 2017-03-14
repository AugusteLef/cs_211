float depth = 3000; // Default camera depth
final float maxAngle = PI/3;
final static int SPHERE = 100;
final static int BOX_X = 1500;
final static int BOX_Z = 1500;
final static int BOX_Y = 100;
PVector gravity  = new PVector(0, 0, 0);
PVector location = new PVector(width/2, height/2 - BOX_Y - SPHERE, 0);
PVector velocity = new PVector(0, 0, 0); 
PVector friction = new PVector(0, 0, 0);
float gravityConstant = 9.81;
float normalForce = 1;
float mu = 0.01;
float frictionMagnitude = normalForce * mu;




void settings() {
  size(1000, 1000, P3D);
}
void setup() {
  noStroke();  
}
void draw() {
  // New light
  directionalLight(50,100,125,1,1,0);
  ambientLight(102,102,102);
  
  // Position camera in the center of the screen
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  // WHite background
  background(255);
  
  // Set correct position for the box
  translate(width/2, height/2, 0); // Place it in the center of the screen
  
  // use the rotation that is defined by mouse action
  rotateZ(rz);
  rotateX(rx);
  
  // Create the box with a color
  color c = color(0, 172, 190);
  fill(c);
  box(BOX_X, 100, BOX_Z);
  
  
  
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  
  gravity.x = sin(rz) * gravityConstant;
  gravity.z = - sin(rx) * gravityConstant;
  
  friction = velocity.get().mult(-1).normalize().mult(frictionMagnitude);
  
  velocity.add(gravity);
  velocity.add(friction);
  location.add(velocity);
  checkEdges();
  
  c = color(255, 0, 10);
  
  fill(c);
  translate(location.x, location.y, location.z);
  sphere(SPHERE);
  
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
  rx = rx + (mouseX_before - mouseX_after) * PI/1000.0;
  
  // If the angle is too big or to small, readjust it
  if (rx > maxAngle)
    rx = maxAngle;
  else if (rx < - maxAngle) 
    rx = -maxAngle;
  
  // Save new mouse position
  mouseX_before = mouseX_after;
  
  // Call draw to update the view

}
void keyPressed() {
  // Changed depth of the camera when key pressed
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
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
    if (location.x >= (BOX_X/2 - SPHERE)*cos(rx)) {
      velocity.x *= -1;
      location.x = (BOX_X/2 - SPHERE)*cos(rx);
    }else if (location.x <= - (BOX_X/2 - SPHERE)*cos(rx)) {
      velocity.x *= -1;
      location.x = - (BOX_X/2 - SPHERE)*cos(rx);
    }
      
    
    if (location.z >=  (BOX_Z/2 - SPHERE)*cos(rz)) {
       velocity.z *= -1;
       location.z = (BOX_Z/2 - SPHERE)*cos(rz);
    }else if (location.z <=  - (BOX_Z/2 - SPHERE)*cos(rz)) {
      velocity.z *= -1;
      location.z =  - (BOX_Z/2 - SPHERE)*cos(rz);
    }
}