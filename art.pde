import org.openkinect.processing.*;
Kinect kinect;
int[] depth;

Bubble[] bubs;
Bubble mouseBub;
int numBubs = 300;

int minthresh = 0;
int maxthresh = 600;
PImage img;
int kw, kh;
float prevX = 0;
float prevY = 0;

//PImage kImage = kinect.getDepthImage();
void setup() {
  size(2880, 2160);
  background(50);

  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  depth = kinect.getRawDepth();

  kw = kinect.width;
  kh = kinect.height;

  img = createImage(kw, kh, RGB);

  bubs = new Bubble[numBubs];
  for (int i = 0; i < numBubs; i++) {
    bubs[i] = new Bubble(round(random(10, 100)));
    bubs[i].Show();
  }
  mouseBub = new Bubble(200);
}

void draw() {
  background(50);
  depth = kinect.getRawDepth();

  stroke(255);
  for (int i = 0; i < numBubs; i++) {
    Bubble bubble = bubs[i];

    for (int j = 0; j < numBubs; j++) {
      bubs[j].checkBoundaryCollision();
      if (bubble != bubs[j])
        bubble.checkCollision(bubs[j]);
    }
    bubble.checkCollision(mouseBub);
    bubble.Show();
    bubble.Update();
  }

  float sumX  = 0;
  float sumY  = 0;
  float count = 0;

  img.loadPixels();
  for (int i = 0; i < kw; i++) {
    for (int j = 0; j < kh; j++) {
      int index = i + (j * kw);
      int d = depth[index];
      if (d > minthresh && d < maxthresh) {
        img.pixels[index] = color(255, 0, 105);
        sumX += i;
        sumY += j;
        count++;
      } else {
        img.pixels[index] = color(50);
      }
    }
  }
  img.updatePixels();
  image(img, 0, 0);

  if (count != 0) {
    float avgX = sumX / count;
    float avgY = sumY / count;

    avgX = map(avgX, 0, kw, width, 0);
    avgY = map(avgY, 0, kh, 0, height);

    float easing = 0.03;
    float targetX = avgX;
    float dx = targetX - prevX;
    prevX += dx * easing;

    float targetY = avgY;
    float dy = targetY - prevY;
    prevY += dy * easing;

    //fill(255);
    //ellipse(avgX, avgY, 80, 80);
    prevX = avgX;
    prevY = avgY;

    stroke(255, 255, 255, 30);
    mouseBub.location.x = avgX;
    mouseBub.location.y = avgY;
  }

  mouseBub.Show();
}
