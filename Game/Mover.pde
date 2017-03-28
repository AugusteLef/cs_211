class Mover {

  PVector location;
  PVector velocity;
  PVector gravity;
  PVector friction;

  float rebond = 1;
  float gravityConstant = 1;
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;

  Mover() {
    gravity  = new PVector(0, 0, 0);
    location = new PVector(0, - BOX_Y/2 - SPHERE, 0);
    velocity = new PVector(0, 0, 0); 
    friction = new PVector(0, 0, 0);
  }

  void update() {
    gravity.x = sin(rz) * gravityConstant;
    gravity.z = - sin(rx) * gravityConstant;

    friction = velocity.get().mult(-1).normalize().mult(frictionMagnitude);

    velocity.add(gravity);
    velocity.add(friction);
    location.add(velocity);
    
    checkEdges();
  }

  void display() {
    translate(location.x, location.y, location.z);
    color c = color(255, 0, 10);
    fill(c);
    sphere(SPHERE);
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

    for (PVector pos : shapes.cylinders) {
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
    for (PVector pos : shapes.squares) {
      PVector topLeft = new PVector(pos.x + CUBE_EDGE/2, pos.z + CUBE_EDGE/2);
      PVector topRight = new PVector(pos.x - CUBE_EDGE/2, pos.z + CUBE_EDGE/2);
      PVector botLeft = new PVector(pos.x + CUBE_EDGE/2, pos.z - CUBE_EDGE/2);
      PVector botRight = new PVector(pos.x - CUBE_EDGE/2, pos.z - CUBE_EDGE/2);
      if (location.x >= pos.x - CUBE_EDGE/2 - SPHERE && location.x <= pos.x + CUBE_EDGE/2 + SPHERE && location.z <= pos.z + CUBE_EDGE/2 && location.z >= pos.z - CUBE_EDGE/2) {
        if (location.x < pos.x)
          location.x = pos.x - CUBE_EDGE/2 - SPHERE;
        else
          location.x = pos.x + CUBE_EDGE/2 + SPHERE;
        velocity.x *= -rebond;
      } else if (location.z + SPHERE >= pos.z - CUBE_EDGE/2 && location.z - SPHERE <= pos.z + CUBE_EDGE/2 && location.x <= pos.x + CUBE_EDGE/2 && location.x >= pos.x - CUBE_EDGE/2) {
        if (location.z < pos.z)
          location.z = pos.z - CUBE_EDGE/2 - SPHERE;
        else
          location.z = pos.z + CUBE_EDGE/2 + SPHERE;
        velocity.z *= -rebond;
      } else if (Math.pow(location.x - topLeft.x, 2) + Math.pow(location.z - topLeft.y, 2) <= SPHERE*SPHERE -1) {
        squareCorner(topLeft);
      } else if (Math.pow(location.x - topRight.x, 2) + Math.pow(location.z - topRight.y, 2) <= SPHERE*SPHERE -1) {
        squareCorner(topRight);
      } else if (Math.pow(location.x - botLeft.x, 2) + Math.pow(location.z - botLeft.y, 2) <= SPHERE*SPHERE -1) {
        squareCorner(botLeft);
      } else if (Math.pow(location.x - botRight.x, 2) + Math.pow(location.z - botRight.y, 2) <= SPHERE*SPHERE -1) {
        squareCorner(botRight);
      }
    }
  }

  //Inner method for bouncing with squares in the corners
  void squareCorner(PVector cornerPos) {
    PVector normal2 = new PVector(location.x - cornerPos.x, location.z - cornerPos.y);
    PVector velocity2D = new PVector(velocity.x, velocity.z);
    float angle = 2*PVector.angleBetween(velocity2D, normal2);
    if ((velocity2D.x == 0 && normal2.x < 0)||(velocity2D.x/velocity2D.y)>(normal2.x/normal2.y))
      angle *= -1;
    velocity2D.rotate(angle).setMag(velocity.mag());
    velocity = new PVector(- velocity2D.x*rebond, 0, - velocity2D.y*rebond);

    PVector normal = new PVector(location.x - cornerPos.x, 0, location.z - cornerPos.y);
    float coefXY = (float)(Math.pow(SPHERE, 2)/(normal.z*normal.z+(normal.x*normal.x)));
    location = new PVector(Math.signum(normal.x)*(float)Math.sqrt(normal.x*normal.x*coefXY) + cornerPos.x, location.y, Math.signum(normal.z)*(float)Math.sqrt(normal.z*normal.z*coefXY) + cornerPos.y);
  }
}