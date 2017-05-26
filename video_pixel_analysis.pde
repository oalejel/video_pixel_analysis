import processing.video.*;

Capture cam;

int lastMillis = 0;

color[][] averageTable = new color[1000][1000];
color[][] oldAverageTable = new color[1000][1000];

void setup() {
  //set screen size based on camera res
  size(640, 700);
  //get list of connected cameras
  String[] cameras = Capture.list();
  //increase framerate if you need fast camera updates?
  //frameRate(240);
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

    //activate these lines to test fps and efficiency
    //int newMillis = millis();
    //println(newMillis - lastMillis);
    //lastMillis = newMillis;

    cam.read();

    //draw image
    pushMatrix(); 
    scale(-0.5, 0.5); 
    translate(-width * 2, height);
    image(cam, 0, 0);
    popMatrix();

    //color c = samplePixelArea(25,25,50);

    setAverages(9);



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

void keyPressed() {
  if (key == ' ') {
    println("pressed space");
    //use space to lock all data for pixel data change
  }
}  

void setAverages(int boxWidth) {
  oldAverageTable = averageTable;

  //int numBoxes = (width / boxWidth) * (height / boxWidth);

  for (int column = 0; column <= (width / boxWidth); column++) {
    for (int row = 0; row <= ((height * 0.5) / boxWidth); row++) {
      //if (column == 1) {return;}
      int x = (column * boxWidth);
      int y = (row * boxWidth);
      color c = samplePixelArea(x + (boxWidth / 2), (y + (boxWidth / 2)), boxWidth);
      averageTable[x][y] = c;
      drawBox(x, y, boxWidth, c);
    }
  }

  for (int column = 0; column <= (width / boxWidth); column++) {
    for (int row = 0; row <= ((height * 0.5) / boxWidth); row++) {
      int x = (column * boxWidth);
      int y = (row * boxWidth);
      
      color newColor = averageTable[x][y];
      color oldColor = oldAverageTable[x][y];
      
      int rDiff = (newColor >> 16 & 0xFF) - (oldColor >> 16 & 0xFF);
      println(rDiff);
      if (rDiff > 10) {
        println("big diff");
      }
      
    }
  }
}

void drawBox(int x, int y, int w, color c) {
  fill(c);
  noStroke();
  rect(x, y, w, w);
}