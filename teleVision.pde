import oscP5.*;  
import netP5.*;

PImage worldMapImage;
MercatorMap mercatorMap;

OscP5 oscP5;
NetAddress myRemoteLocation;

int bufferSize = 10000;

int varName;

float x;
float y;
int c;

boolean pushx = false;
boolean pushy = false;
boolean pushc = false;


Queue queue = new Queue();

public class Queue {
  final int capacity = bufferSize;
  
  float xarr[] = new float[capacity];
  float yarr[] = new float[capacity];
  float sarr[] = new float[capacity];
  int carr[] = new int[capacity];
  
  int top = -1;
  int rear = 0;
 
  public void push(float x, float y, int c) {
    if (top < capacity - 1) {
      top++;
      PVector input = new PVector(x, y);
      PVector tmp = mercatorMap.getScreenLocation(input);
      xarr[top] = tmp.x;
      yarr[top] = tmp.y;
      carr[top] = c;
      sarr[top] = 60; // Dot size
  }
  else
  {
      top = -1;
      rear = 0;
    
      println("out of space");
  }
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
        colorMode(HSB, 1000);
        if (carr[i] <= 1024){
          c = int(map(carr[i], 0, 1024, 0, 1000));
          fill(c, 1000, 1000);
        }
        else
        {
          fill(c, 0, 1000);
        }
        ellipse(xarr[i], yarr[i], sarr[i], sarr[i]);
        colorMode(RGB, 100);
        fill(0,0,0);
        String s =  str(carr[i]);
        float cw = textWidth(s);
        textSize(sarr[i]/4);
        text(s, xarr[i]-(cw/2), yarr[i]+((sarr[i]/4)/2)) ;
        if (sarr[i] > 0){
          sarr[i] = sarr[i] - 0.5;
        }
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
  
  colorMode(HSB, 100);
  
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
  if (theOscMessage.checkAddrPattern("/freq")==true)
  {
    c = theOscMessage.get(0).intValue();
    pushc = true;
  }
  if ((pushx == true) && (pushy == true) && (pushc == true))
  {
    queue.push(x, y, c);
    pushc = false;
    pushx = false;
    pushy = false;
  }
}
