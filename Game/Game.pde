float depth = 2000;
final float maxAngle = PI/6;


void settings() {
  size(500, 500, P3D);
}
void setup() {
  //noStroke();
}
void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  //directionalLight(50, 100, 125, 0, -1, 0);
  //ambientLight(102, 102, 102);
  lights();
  background(200);
  translate(width/2, height/2, 0);

  if (rx > PI/3) {
    rx = PI/3;
  } else if (rx < - PI/3) {
    rx = -PI/3;
  }
  rotateZ(rz);
  rotateX(rx);
  box(1500, 1500, 100);
  /*for (int x = -2; x <= 2; x++) {
   for (int y = -2; y <= 2; y++) {
   for (int z = -2; z <= 2; z++) {
   pushMatrix();
   translate(100 * x, 100 * y, -100 * z);
   noFill();
   box(200,200,50);
   popMatrix();
   }
   }
   }*/
}
int mouseZ_1 = 0;
int mouseZ_2 = 0;
float rz = 0;
int mouseX_1 = 0;
int mouseX_2 = 0;
float rx = 0;
float speed = 1000;
void mouseMoved() {
  mouseZ_1 = mouseX;
  mouseX_1 = mouseY;
}
void mouseDragged() 
{
  mouseZ_2 = mouseX;
  rz = rz + (mouseZ_1-mouseZ_2)*PI/speed;
  if (rz > maxAngle) {
    rz = maxAngle;
  } else if (rz < - maxAngle) {
    rz = -maxAngle;
  }
  mouseZ_1 = mouseZ_2;
  mouseX_2 = mouseY;
  rx = rx + (mouseX_1-mouseX_2)*PI/1000.0;
  if (rx > maxAngle) {
    rx = maxAngle;
  } else if (rx < - maxAngle) {
    rx = -maxAngle;
  }
  mouseX_1 = mouseX_2;
  draw();
}
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    }
  }
}
void mouseWheel(MouseEvent event) {
  int speed2 = (int)event.getCount();
  if (speed2 < 0) {
    for (int i = 0; i < -speed2; ++i)
      speed *= 1.01;
  } else if (speed2 > 0)
    for (int i = 0; i < speed2; ++i)
      speed /= 1.01;
}