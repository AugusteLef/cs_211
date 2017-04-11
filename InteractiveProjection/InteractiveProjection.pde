
float angleX = 0;
float angleY = 0;

void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
}
void draw() {
  camera(width/2, height/2, 1000, 250, 250, 0, 0, 1, 0);
  lights();
  background(200);
  translate(width/2, height/2, 0);
  
  rotateX(angleX);
  rotateY(angleY);

  
  box(250);
  
}


void keyPressed()
{
  if (key == CODED) {
    if (keyCode == DOWN ) {
      angleX -= PI/100; 
      
    }
    if (keyCode == UP ) {
      angleX += PI/100;
      
    }
  }
  if (key == CODED) {
    if (keyCode == RIGHT ) {
      angleY += PI/100; 
      
    }
    if (keyCode == LEFT ) {
      angleY -= PI/100;
      
    }
  }






}