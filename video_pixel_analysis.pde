import processing.video.*;

/*
  the big leap in this program would require the implementation of some machine
 learning level of data analysis where instead of hard coding what the average
 change of pixel color is acceptable, we statistically measure an acceptable range
 of error through intelligent observation and calculation of pixel flicker
 */

Capture cam;

color[][] averageTable = new color[1000][1000];
color[][] oldAverageTable = new color[1000][1000];

int normalizationPeriod = 100; //milliseconds a pixel should stay the same
long lastMillis = 0;
int currentCycleMillis = 0;
int boxWidth = 3;

void setup() {
  //set screen size based on camera res
  size(640, 700);

  //get list of connected cameras
  String[] cameras = Capture.list();

  //if we have 0 cameras, exit... else, continue and setup
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    //use the first camera --> builtin
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}

void draw() {
  //if we have data, then go along
  if (cam.available() == true) {

    /*
     //uncomment these lines to test fps and efficiency
     int newMillis = millis();
     println(newMillis - lastMillis);
     lastMillis = newMillis;
     */

    //read camera data
    cam.read();

    //draw image
    pushMatrix(); 
    scale(-0.5, 0.5); 
    translate(-width * 2, height);
    image(cam, 0, 0);
    popMatrix();

    int currentMillis = millis();
    currentCycleMillis += currentMillis - lastMillis;

    setAverages(boxWidth);
    if (currentCycleMillis > normalizationPeriod) {
      //after about 500 ms, we set old = to the current and then update 
      copyToOldTable();
      //reset the wait period
      currentCycleMillis = 0;
    }

    lastMillis = currentMillis;
    loadPixels();
  }
}

color samplePixelArea(int midX, int midY, int w) {
  int rSum = 0;
  int gSum = 0;
  int bSum = 0;
  int index = 0;

  int initialX = midX - int(0.5 * w);
  int initialY = midY - int(0.5 * w);
  for (int x = initialX; x < midX + int(0.5 * w); x++) {
    for (int y = initialY; y < midY + int(0.5 * w); y++) {
      color c = get(x, int(height * 0.5) + y);
      rSum += c >> 16 & 0xFF;
      gSum += c >> 8 & 0xFF;
      bSum += c & 0xFF;
      index++;
    }
  }

  return color(rSum / index, gSum / index, bSum / index);
}

//void keyPressed() {
//  if (key == ' ') {
//    println("pressed space");
//    //use space to lock all data for pixel data change
//  }
//}

void copyToOldTable() {
  //Cannot use the below line since we will just be equalizing memory location
  //oldAverageTable = averageTable;
  int xIndex = 0;
  int yIndex = 0;
  for (int[] x : averageTable) {
    for (int y : x) {
      oldAverageTable[xIndex][yIndex] = averageTable[xIndex][yIndex];
      yIndex++;
    }
    xIndex++;
    yIndex = 0;
  }
}

void setAverages(int boxWidth) {
  //int numBoxes = (width / boxWidth) * (height / boxWidth);

  for (int column = 0; column <= (width / boxWidth); column++) {
    for (int row = 0; row <= ((height * 0.5) / boxWidth); row++) {
      //if (column == 1) {return;}
      int x = (column * boxWidth);
      int y = (row * boxWidth);
      color c = samplePixelArea(x + (boxWidth / 2), (y + (boxWidth / 2)), boxWidth);
      averageTable[x][y] = c;

      //if (shouldNormalize) {
      color oldColor = oldAverageTable[x][y];
      int redDiff = abs(((c >> 16) & 0xFF) - ((oldColor >> 16) & 0xFF));
      int greenDiff = abs(((c >> 8) & 0xFF) - ((oldColor >> 8) & 0xFF));
      int blueDiff = abs((c & 0xFF) - (oldColor & 0xFF));
      float averagePercent = ((redDiff / 255.0) + (greenDiff / 255.0) + (blueDiff / 255.0)) / 3.0;
      if (averagePercent > 0.04) {
        //show green filter
        c = c & #00FF00;
      }
      //}

      drawBox(x, y, boxWidth, c);

      //appendAverageColor(x, y, c);
    }
  }
}

void drawBox(int x, int y, int w, color c) {
  fill(c);
  noStroke();
  rect(x, y, w, w);
}