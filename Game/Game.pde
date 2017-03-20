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
float rebond = 0.7;
float gravityConstant = 1;
float normalForce = 1;
float mu = 0.01;
float frictionMagnitude = normalForce * mu;

color c;




void settings() {
  size(1000, 1000, P3D);
}
void setup() {
  noStroke();  
}
void draw() {
  // New lights
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
  c = color(0, 172, 190);
  fill(c);
  box(BOX_X, BOX_Y, BOX_Z);
  
  updatePos();
  
  // Create sphere with a color
  c = color(255, 0, 10);
  fill(c);
  sphere(SPHERE);
  
  
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
  
    float limitX = (BOX_X/2 - SPHERE);
    float limitZ = (BOX_Z/2 - SPHERE);
    PVector posRotX = new PVector(location.x, location.y * cos(-rx) - location.z * sin(-rx), -location.x*sin(-rx) + location.z * cos(-rx));
    PVector posRot = new PVector(posRotX.x*cos(-rz) - posRotX.y*sin(-rz), posRotX.x * sin(-rz)+ posRotX.y * cos(-rz), posRotX.z);
    //PVector limitRotX = new PVector(limitX, - limitZ * sin(-rx), -limitX*sin(-rx) + limitZ * cos(-rx));
    //PVector limitRot = new PVector(limitRotX.x*cos(-rz) - limitRotX.y*sin(-rz), limitRotX.x * sin(-rz)+ limitRotX.y * cos(-rz), limitRotX.z);
    if (posRot.x >= limitX) {
      location.sub(velocity);
      velocity.x *= -rebond;
      
      
    }
    else if (posRot.x <= - limitX) {
      location.sub(velocity);
      velocity.x *= -rebond;
      
    }
    
    if (posRot.z >= limitZ) {
      location.sub(velocity);
       velocity.z *= -rebond;
       
    }
    else if (posRot.z <= - limitZ) {
      location.sub(velocity);
      velocity.z *= -rebond;
      
    }
    
    
}