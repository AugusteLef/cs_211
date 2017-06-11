//Class that updates the position
class Mover {
  //PVectors
  PVector location;
  PVector velocity;
  PVector gravity;
  PVector friction;

  //Floats
  float rebond = 1;
  float gravityConstant = 1;
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;

  //Initialisation
  Mover() {
    gravity  = new PVector(0, 0, 0);
    location = new PVector(0, - BOX_Y/2 - SPHERE, 0);
    velocity = new PVector(0, 0, 0); 
    friction = new PVector(0, 0, 0);
  }

  void update() {
    //Update the gravity according to the angle of the board
    gravity.x = sin(rz) * gravityConstant;
    gravity.z = - sin(rx) * gravityConstant;
    //println(""+toMove.z);
    //gravity.x = sin(toMove.z) * gravityConstant;
    //gravity.z = -sin(toMove.x) * gravityConstant;
    
    //Update friction
    friction = velocity.get().mult(-1).normalize().mult(frictionMagnitude);

    //Update velocity
    velocity.add(gravity);
    velocity.add(friction);

    //Update location
    location.add(velocity);

    //Check if the ball has gone further than the boundaries (board, cylinders, cubes)
    checkEdges();
  }

  void display() {
    translate(location.x, location.y, location.z);
    //sphere(SPHERE);
    pushMatrix();
    float angle = (float)Math.atan2(velocity.x, velocity.z);
    rotateY(angle);
    shape(pacman, 0, 0);
    popMatrix();
  }

  void checkEdges() {
    //Check for the Box boundings
    float limitX = (BOX_X/2 - SPHERE);
    float limitZ = (BOX_Z/2 - SPHERE);
    if (location.x >= limitX) {
      location.x = limitX;
      velocity.x *= -rebond;
      last_score = -velocity.mag();
      tot_score += last_score;
    } else if (location.x <= - limitX) {
      location.x = - limitX;
      velocity.x *= -rebond;
      last_score = -velocity.mag();
      tot_score += last_score;
    }
    if (location.z >= limitZ) {
      location.z = limitZ;
      velocity.z *= -rebond;
      last_score = -velocity.mag();
      tot_score += last_score;
    } else if (location.z <= - limitZ) {
      location.z = - limitZ;
      velocity.z *= -rebond;
      last_score = -velocity.mag();
      tot_score += last_score;
    }

    //Deals bouncings for each cylinder using 2D PVector for angle symetry of the new direction of the velocity. 
    //If the ball comes to touch or to go inside a cylinder, replace it at the edge of the cylinder
    for (PVector pos : shapes.cylinders) {
      if (Math.pow(location.x - pos.x, 2) + Math.pow(location.z - pos.z, 2) < Math.pow(SPHERE + CYLINDER_RADIUS, 2)) {
        last_score = velocity.mag();
        tot_score += last_score;
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

    //Bonus cubes, the edges act like the edge of board and the corner use angle symetry with 2D PVectors.
    //If 2 cubes are one next to another, disenable the boucing of the corners to avoid bugs.
    //Replace the ball at the edge of the cube or at the corner of it.
    for (PVector pos : shapes.squares) {
      //Define 4 corners cases to be dealt separetly
      PVector topLeft = new PVector(pos.x + CUBE_EDGE/2, pos.z + CUBE_EDGE/2);
      PVector topRight = new PVector(pos.x - CUBE_EDGE/2, pos.z + CUBE_EDGE/2);
      PVector botLeft = new PVector(pos.x + CUBE_EDGE/2, pos.z - CUBE_EDGE/2);
      PVector botRight = new PVector(pos.x - CUBE_EDGE/2, pos.z - CUBE_EDGE/2);
      if (location.x >= pos.x - CUBE_EDGE/2 - SPHERE && location.x <= pos.x + CUBE_EDGE/2 + SPHERE && location.z <= pos.z + CUBE_EDGE/2 && location.z >= pos.z - CUBE_EDGE/2) {
        last_score = velocity.mag();
        tot_score += last_score;
        if (location.x < pos.x)
          location.x = pos.x - CUBE_EDGE/2 - SPHERE;
        else
          location.x = pos.x + CUBE_EDGE/2 + SPHERE;
        velocity.x *= -rebond;
      } else if (location.z + SPHERE >= pos.z - CUBE_EDGE/2 && location.z - SPHERE <= pos.z + CUBE_EDGE/2 && location.x <= pos.x + CUBE_EDGE/2 && location.x >= pos.x - CUBE_EDGE/2) {
        last_score = velocity.mag();
        tot_score += last_score;
        if (location.z < pos.z)
          location.z = pos.z - CUBE_EDGE/2 - SPHERE;
        else
          location.z = pos.z + CUBE_EDGE/2 + SPHERE;
        velocity.z *= -rebond;
      } 

      //Deals with the corner of the cubes and check if there's a cube next to it, if so disenable the corner
      else if (Math.pow(location.x - topLeft.x, 2) + Math.pow(location.z - topLeft.y, 2) <= SPHERE*SPHERE -1 && !shapes.squares.contains(new PVector(pos.x-CUBE_EDGE, pos.y, pos.z)) && !shapes.squares.contains(new PVector(pos.x, pos.y, pos.z+CUBE_EDGE))) {
        squareCorner(topLeft);
      } else if (Math.pow(location.x - topRight.x, 2) + Math.pow(location.z - topRight.y, 2) <= SPHERE*SPHERE -1 && !shapes.squares.contains(new PVector(pos.x+CUBE_EDGE, pos.y, pos.z)) && !shapes.squares.contains(new PVector(pos.x, pos.y, pos.z+CUBE_EDGE))) {
        squareCorner(topRight);
      } else if (Math.pow(location.x - botLeft.x, 2) + Math.pow(location.z - botLeft.y, 2) <= SPHERE*SPHERE -1 && !shapes.squares.contains(new PVector(pos.x+CUBE_EDGE, pos.y, pos.z)) && !shapes.squares.contains(new PVector(pos.x, pos.y, pos.z-CUBE_EDGE))) {
        squareCorner(botLeft);
      } else if (Math.pow(location.x - botRight.x, 2) + Math.pow(location.z - botRight.y, 2) <= SPHERE*SPHERE -1 && !shapes.squares.contains(new PVector(pos.x-CUBE_EDGE, pos.y, pos.z)) && !shapes.squares.contains(new PVector(pos.x, pos.y, pos.z-CUBE_EDGE))) {
        squareCorner(botRight);
      }
    }
  }

  //Inner method for bouncing with squares in the corners
  void squareCorner(PVector cornerPos) {
    last_score = velocity.mag();
    tot_score += last_score;
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