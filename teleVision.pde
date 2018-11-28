import oscP5.*;  
import netP5.*;

PImage worldMapImage;
MercatorMap mercatorMap;

OscP5 oscP5;
NetAddress myRemoteLocation;

int bufferSize = 100;

int varName;

float x;
float y;

boolean pushx = false;
boolean pushy = false;

Queue queue = new Queue();

public class Queue {
  final int capacity = bufferSize;
  
  float xarr[] = new float[capacity];
  float yarr[] = new float[capacity];
  float sarr[] = new float[capacity];
  
  int top = -1;
  int rear = 0;
 
  public void push(float x, float y) {
    if (top < capacity - 1) {
      top++;
      PVector input = new PVector(x, y);
      PVector tmp = mercatorMap.getScreenLocation(input);
      xarr[top] = tmp.x;
      yarr[top] = tmp.y;
      sarr[top] = 50; // Dot size
  }
 
  public void pop() {
    if (top >= rear) {
      rear++;
      top--;
    }
  }
 
  public void display() {
    if (top >= rear) {
      for (int i = rear; i <= top; i++) {
        //print(arr[i]);
        ellipse(xarr[i], yarr[i], sarr[i], sarr[i]);
        sarr[i] = sarr[i] - 0.1;
      }
    for (int i = rear; i <= top; i++) {
      if (sarr[i] <= 0){
        pop();
     }
    }
  }
}
}

void setup() {
  size(1382, 1070);
  smooth();
  
  // World map from http://en.wikipedia.org/wiki/File:Mercator-projection.jpg 
  worldMapImage = loadImage("Mercator_projection_smaller.jpg");
  mercatorMap = new MercatorMap(1382, 1070);
  oscP5 = new OscP5(this, 7400);   //listening
}


void draw() {
  image(worldMapImage, 0, 0, width, height);

  noStroke();
  fill(255, 0, 0, 200);
  
  queue.display();
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/lat")==true)
  {
    x = theOscMessage.get(0).floatValue();
    pushx = true;
  }
    if (theOscMessage.checkAddrPattern("/lon")==true)
  {
    y = theOscMessage.get(0).floatValue();   
    pushy = true;
  }
  if ((pushx == true) && (pushy == true))
  {
    queue.push(x, y);
    pushx = false;
    pushy = false;
  }
}
