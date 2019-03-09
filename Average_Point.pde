import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;

PImage img;

float y_diff_thresh = 100;

float minThresh = 700; 
float maxThresh = 850;

float ylist[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
float ylist_sec[] = new float[60];

int frame_counter = 0;
int main_counter = 0;

//find average of array, exclude NaN and zeros
float array_average(float array[]) {
  float arr_avg = 0;
  int valid_count = 0;
  for (int i = 0; i < array.length; i++) {
    if (Float.isNaN(array[i])) array[i] = 0;
    if (array[i] != 0) {
      arr_avg += array[i]; 
      valid_count++;
    }
  }
  return arr_avg / valid_count;
}

void setup() {
  size(640, 480);
  kinect = new Kinect(this);
  kinect.initDepth();
  img = createImage(kinect.width, kinect.height, RGB);
}

void draw() {
  background(0);
  
  img.loadPixels();
  
  //for calibrating threshold with mouse
  //minThresh = map(mouseX, 0, width, 0, 4500);
  //maxThresh = map(mouseY, 0, height, 0, 4500);
  
  int[] depth = kinect.getRawDepth();
  
  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;
  
  for (int x = 0; x < kinect.width; x++) {
    for (int y = 0; y < kinect.height; y++) {
      int offset = x + y * kinect.width;
      int d = depth[offset];
      
      if (d > minThresh && d < maxThresh) {
        img.pixels[offset] = color(255, 0, 150);
        
        sumX += x;
        sumY += y;
        totalPixels++;
      }
      else {
        img.pixels[offset] = color(0); 
      }
    }
  }
  
  img.updatePixels();
  image(img, 0, 0);
  
  //output threshold onto screen
  fill(255);
  textSize(18);
  text("minThresh: " + minThresh + "\nmaxThresh: " + maxThresh, 10, 64);

  //output time onto screen
  int s = second(); 
  int m = minute(); 
  int h = hour(); 
  text(h + ":" + m + ":" + s, 400, 64);
  
  //Calculate average X and Y position
  float avgX = sumX / totalPixels;
  float avgY = sumY / totalPixels;
  
  //draw an allipse for the average position
  fill(150, 0, 255);
  ellipse(avgX, avgY, 64, 64);
  
  if (avgY > 460 || avgY < 20) ylist_sec[frame_counter] = 0;
  else ylist_sec[frame_counter] = avgY;
  
  if (frame_counter == 59) {
    
    //calculate average of ylist_sec
    float ylist_sec_avg = array_average(ylist_sec);
    println("ylist_sec_avg: " + ylist_sec_avg);
    
    ylist[main_counter] = ylist_sec_avg;
    
    //calculate average of ylist
    float ylist_avg = array_average(ylist);
    println("ylist_avg: " + ylist_avg);
    
    if ((ylist_sec_avg - ylist_avg) > y_diff_thresh && ylist_sec_avg > 400) { 
      println("Fall Detected. Sending Email");
      
      //Enabling the following line to send emails
      launch("/Users/inffzy/Desktop/Kinect/Auto_Email_Generator.app");
    }
    
    main_counter++;
    main_counter %= 10;
  }
  
  frame_counter++;
  frame_counter %= 60;
}
