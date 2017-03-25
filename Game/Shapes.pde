class Shapes {

  ArrayList<PVector> cylinders = new ArrayList();
  ArrayList<PVector> squares = new ArrayList();

  int cylinderResolution = 25;
  PShape openCylinder = new PShape();
  PShape coverTop = new PShape();
  PShape openCube = new PShape();
  PShape topCube = new PShape();

  Shapes() {
    
    // Create shapes
    
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

    //For the cube : cylinders of resolution 4
    float[] x1 = new float[5];
    float[] y1 = new float[5];
    //get the x and y position on a square
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

    openCube = createShape();
    openCube.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x1.length; i++) {
      openCube.vertex(x1[i], 0, y1[i]);
      openCube.vertex(x1[i], -CUBE_EDGE, y1[i]);
    }
    openCube.endShape();

    topCube = createShape();
    topCube.beginShape(TRIANGLE);
    for (int i = 0; i < x1.length-1; ++i) {
      topCube.vertex(x1[i], -CUBE_EDGE, y1[i]);
      topCube.vertex(0, -CUBE_EDGE, 0);
      topCube.vertex(x1[i + 1], -CUBE_EDGE, y1[i+1]);
    }
    topCube.endShape();
  }
  
  void drawShapes() {
    for (PVector p : cylinders) {
      translate(p.x, p.y, p.z);
      shape(openCylinder);
      shape(coverTop);
      translate(-p.x, -p.y, -p.z);
    }
    for (PVector p : squares) {
      translate(p.x, p.y, p.z);
      shape(openCube);
      shape(topCube);
      translate(-p.x, -p.y, -p.z);
    }
  }
}