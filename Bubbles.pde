class Bubble {
  int size, randy, randx;
  float radius, m;
  PVector dir = PVector.fromAngle(random(0, TWO_PI));
  PVector vel = new PVector(random(-2, 2), random(-2, 2));
  PVector location;

  Bubble(int size_) {
    stroke(255);
    noFill();
    size = size_;
    strokeWeight(round(40 / size));
    randx = round(random(width - size));
    randy = round(random(height - size));

    location = new PVector(randx, randy);
    radius = size / 2;
    m = radius*.05;

    while (overlap(this)) {
      randx = size + round(random(0, width - size*2));
      randy = size + round(random(0, height - size*2));
      location = new PVector(randx, randy);
    }
  }


  void Show() {
    strokeWeight(round(400/size) + 1);
    ellipse(location.x, location.y, size, size);
  }

  void Update() {
    location.add(vel);
  }

  boolean overlap(Bubble newLoc) {
    for (int i = 0; i < numBubs; i++) {
      if (bubs[i] != null && dist(newLoc.location.x, newLoc.location.y,
                bubs[i].location.x, bubs[i].location.y) <
                    (newLoc.radius + bubs[i].radius)*1.05) {
        return true;
      }
    }
    return false;
  }

  void checkBoundaryCollision() {
    if (location.x > width - radius) {
      location.x = width - radius;
      vel.x *= -1;
    } else if (location.x < radius) {
      location.x = radius;
      vel.x *= -1;
    } else if (location.y > height - radius) {
      location.y = height-radius;
      vel.y *= -1;
    } else if (location.y < radius) {
      location.y = radius;
      vel.y *= -1;
    }
  }

  void checkCollision(Bubble other) {

    // Get distances between the balls components
    PVector distanceVect = PVector.sub(other.location, location);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = radius + other.radius;

    if (distanceVectMag < minDistance) {
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.location.add(correctionVector);
      location.sub(correctionVector);

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball locations. You 
       just need to worry about bTemp[1] location*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's location is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].location.x and bTemp[0].location.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * vel.x + sine * vel.y;
      vTemp[0].y  = cosine * vel.y - sine * vel.x;
      vTemp[1].x  = cosine * other.vel.x + sine * other.vel.y;
      vTemp[1].y  = cosine * other.vel.y - sine * other.vel.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final vel along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated vel for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated vel for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball locations and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen location
      other.location.x = location.x + bFinal[1].x;
      other.location.y = location.y + bFinal[1].y;

      location.add(bFinal[0]);

      // update velocities
      vel.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      vel.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.vel.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.vel.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
  }
}
