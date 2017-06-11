class Shapes {
  //Arrays of the position of cylinders and squares
  ArrayList<PVector> cylinders = new ArrayList();
  ArrayList<PVector> squares = new ArrayList();

  //Cylinder resolution
  int cylinderResolution = 25;
  
  //PShapes of the cylinders, cubes and their respective "cover"
  PShape openCylinder = new PShape();
  PShape coverTop = new PShape();
  PShape openCube = new PShape();
  PShape topCube = new PShape();

  //Creating the cylinders and cubes when initializing a shapes object
  Shapes() {  
    createCylinders();
    createCubes();
  }
  
  //Creating the Cylinders
  void createCylinders() {
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    
    //Get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * CYLINDER_RADIUS;
      y[i] = cos(angle) * CYLINDER_RADIUS;
    }
    
    //Draw the border of the cylinder
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    openCylinder.noStroke();
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0, y[i]);
      openCylinder.vertex(x[i], CYLINDER_HEIGHT, y[i]);
    }
    openCylinder.endShape();
    
    //Draw the cover of the cylinder
    coverTop = createShape();
    coverTop.beginShape(TRIANGLE);
    coverTop.noStroke();
    for (int i = 0; i < x.length-1; ++i) {
      coverTop.vertex(x[i], CYLINDER_HEIGHT, y[i]);
      coverTop.vertex(0, CYLINDER_HEIGHT, 0);
      coverTop.vertex(x[i + 1], CYLINDER_HEIGHT, y[i+1]);
    }
    coverTop.endShape();
  }
  
  //Creating the Cubes
  void createCubes() {
    //For the cube : cylinders of resolution 4
    float[] x1 = new float[5];
    float[] y1 = new float[5];
    
    //Get the x and y positions on a square
    x1[0] = CUBE_EDGE/2;
    y1[0] = CUBE_EDGE/2;
    x1[1] = - CUBE_EDGE/2;
    y1[1] = CUBE_EDGE/2;
    x1[2] = - CUBE_EDGE/2;
    y1[2] = - CUBE_EDGE/2;
    x1[3] = CUBE_EDGE/2;
    y1[3] = - CUBE_EDGE/2;
    x1[4] = x1[0];
    y1[4] = y1[0];

    //Draw the border of the cube(like the cylinder)
    openCube = createShape();
    openCube.beginShape(QUAD_STRIP);
    openCube.noStroke();
    for (int i = 0; i < x1.length; i++) {
      openCube.vertex(x1[i], 0, y1[i]);
      openCube.vertex(x1[i], -CUBE_EDGE, y1[i]);
    }
    openCube.endShape();
    
    //Draw the cover of the cube
    topCube = createShape();
    topCube.beginShape(TRIANGLE);
    topCube.noStroke();
    for (int i = 0; i < x1.length-1; ++i) {
      topCube.vertex(x1[i], -CUBE_EDGE, y1[i]);
      topCube.vertex(0, -CUBE_EDGE, 0);
      topCube.vertex(x1[i + 1], -CUBE_EDGE, y1[i+1]);
    }
    topCube.endShape();
  }
  
  //Draw both cylinders and cubes
  void drawShapes() {
    for (PVector p : cylinders) {
       gameGraphic.translate(p.x, p.y, p.z);
       //gameGraphic.shape(openCylinder);
       //gameGraphic.shape(coverTop); => to draw cylinders
       gameGraphic.shape(tower, 0, 0);
       gameGraphic.translate(-p.x, -p.y, -p.z);
    }
    for (PVector p : squares) {
       gameGraphic.translate(p.x, p.y, p.z);
       gameGraphic.shape(openCube);
       gameGraphic.shape(topCube);
      gameGraphic. translate(-p.x, -p.y, -p.z);
    }
  }
}