import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.spi.*;
import peasy.*;

int participantNumber = 0;

PeasyCam cam;
Minim minim;
AudioProcessing AP;
AudioPlayer player, playerA, playerB;

boolean recordData;

float m = 0;
int lod = 25;
float r = 200;  

Shape OuterShapeA, OuterShapeB; 
Shape InnerShapeA, InnerShapeB;
Shape star5A, star5B;

PrintWriter data;
String filename;
char condition = 'A';
int eventRecognized_tap = 0;
int eventRecognized_hold = 0;
float noiseIndex = 0;
float hue = 0;
float spin = 0;
float orbit = 0;
float amp_m, frq_m, amp_rt, frq_rt, amp_norm, frq_norm;
float minAmp, maxAmp, minFrq, maxFrq;
float brightness_rt, brightness_m, brightness_m_inner;
float orbitSpeed, rotationSpeed;

void setup() {
  println("Performing Initial Setup");
  println("Locking framerate @ 60fps");
  frameRate(60);
  fullScreen(P3D, 2);

  println("Preparing Camera");
  cam = new PeasyCam(this, 150);
  
  println("Preparing Minim");
  minim = new Minim(this);
  
  println("Initializing Audio Processing script");
  AP = new AudioProcessing(minim);

  println("Loading Audio Files");
  playerA = minim.loadFile("Audio/soundscape_A.wav");
  playerB = minim.loadFile("Audio/soundscape_B.wav");

  // Create Shapes
  println("Creating Initial Shape Parameters");

  star5A  = new Shape(5, 0.38, 1.12, 0.47);
  star5B  = new Shape(10, 0.71, 0.79, 1.12);

  InnerShapeA = new Shape(10.0, 0.79, 0.64, 1.24);
  InnerShapeB = new Shape(10.0, 2.0, 2.0, 2.0);

  OuterShapeA = new Shape(10.0, 0.79, 0.64, 1.24);
  OuterShapeB = new Shape(10.0, 2.0, 2.0, 2.0);

  println("Initializing Values for Ampitude and Frequency Calibration");
  minAmp = 999999;
  maxAmp = 0;
  minFrq = 999999;
  maxFrq = 0;

  recordData = false;
  println("Inital Setup Complete.");
  println();
  println("Please perform final checks:");
  println("-Check System Audio set to 34.");
  println("-Perform initial run to calibrate values.");
  println("-Check that Zoom recording level set to 100.");
  PrintInstructions();
  
  colorMode(HSB);
}

void draw() {
  background(0);
  lights();
  strokeWeight(2);

  MoveCamera();
  UpdateAudioParameters(condition);
  CalibrateValues();
  MapValues();

  OuterShapeA.UpdateValues(m);
  OuterShapeB.UpdateValues(m);
  star5A.UpdateValues(m);
  star5B.UpdateValues(m);

  //OuterShape
  stroke(hue % 255, 255, 255);
  fill(255-(hue % 255), 255, brightness_m);
  
  PVector[][] backgroundShape = CalculateVertices(OuterShapeA, OuterShapeB);
  PVector[][] centerShape = CalculateVertices(star5B, star5A);
  PVector[][] orbitShape = CalculateVertices(InnerShapeA, InnerShapeB);
  
  DrawShape(backgroundShape);

  //Center Shape
  pushMatrix();
  scale(0.2);
  translate(0, 0, -250);
  fill(255-(hue % 255), 255, brightness_m_inner);
  noStroke();
  DrawShape(centerShape);

  //Orbiting Shapes:
  fill(127+(hue % 255), brightness_rt, brightness_rt);  
  noStroke();
  strokeWeight(20);

  pushMatrix();
  //orbit
  rotateX(orbit);
  translate(0, 0, 250);
  //local rotation
  rotateX(spin);
  rotateY(spin);
  rotateZ(spin);
  scale(0.15);
  DrawShape(orbitShape);
  popMatrix();

  pushMatrix();
  //orbit
  rotateY(orbit);
  translate(250, 0, 0);
  //local rotation
  rotateX(spin);
  rotateY(spin);
  rotateZ(spin);
  scale(0.15);
  DrawShape(orbitShape);
  popMatrix();

  pushMatrix();
  //orbit
  rotateZ(orbit);
  translate(0, 250, 0);
  //local rotation
  rotateX(spin);
  rotateY(spin);
  rotateZ(spin);
  scale(0.15);
  DrawShape(orbitShape);
  popMatrix();

  popMatrix();

  spin += rotationSpeed;
  orbit += orbitSpeed;
  noiseIndex += 0.005;
  hue += 0.01;
  
  if (recordData)
    data.println(millis()+"," + eventRecognized_tap + "," + eventRecognized_hold + "," + frq_rt  + "," +  brightness_rt + "," + frq_m + "," + brightness_m + "," + amp_rt + "," + orbitSpeed + "," + amp_m + "," + m + "," + frameRate + "," + amp_norm + "," + frq_norm);

  eventRecognized_tap = 0;

  if (player != null) {
    if (!player.isPlaying() && recordData) {
      println("Audio File ended");
      EndTest();
    }
  }
}


void keyPressed() {
  switch(key) {
  case 'a':
    println("Starting Test");
    StartTest('A');
    break;
  case 'b':
    println("Starting Test");
    StartTest('B');
    break;
  case 'e':
    println("Ending Test");
    EndTest();
    break;
  case 'p': 
    println("Incrementing Participant Number");
    participantNumber ++;
    println("Ready to Test Participant number " + participantNumber);
  case ' ':
    println("Event Noted");
    eventRecognized_tap = 1; 
    eventRecognized_hold = 1;
    break;
  default:
    break;
  }
}


void keyReleased() {
  if (key == ' ') {
    eventRecognized_hold = 0;  
    println("End of Percievent Event");
  }
}


void StartTest(char _condition) {
  condition = _condition;
  recordData = true;
  String currentTime = "date_" + day()+ "_" +month()+ "_time_" + hour()+ "_" + minute();
  if (condition == 'A') {
    println("loading file " + condition);
    player = playerA;
    println("file loaded");
    filename = "participant_" +participantNumber + "_condition_" + condition+"_"+ currentTime+ "_data.txt";
  } else if (condition == 'B') {
    //noiseIndex = 0;
    player = playerB;
    filename = "participant_" +participantNumber + "_condition_" + condition+"_"+ currentTime+ "_data.txt";
  } else if (condition == ' ') {
    //println("Calibrating");
    //maybe replace with calibration file
    //player = minim.loadFile("Audio/soundscape_A.wav");
    //filename=("calibrataion_data.txt");
  } else {
    //error
  }
  println("Participant Number " + participantNumber + ", Condition " + condition);
  filename = "participant_" +participantNumber + "_condition_" + condition+"_"+ currentTime+ "_data.txt";
  data = createWriter("Data/"+filename);
  //data.println(fileHeader);
  println("Playing AudioFile");
  player.play();
  //logging of data occurs every frame in Draw()
}


void EndTest() { 
  if (player.isPlaying()) {
    player.pause();
  }    
  println("Rewinding Player");
  player.rewind();
  println("Saving Data to file: " + filename);
  data.flush();
  data.close();  
  recordData = false;
  println("Test Finished. Ready for Next Test.");
  condition = ' ';
  PrintInstructions();
}


void UpdateAudioParameters(char _condition) {
  if (_condition == 'A') {
    //Reactive to Mic Input
    amp_m = AP.meanAmplitude();
    amp_rt = AP.rtAmplitude();
    frq_m = AP.meanFrequency();
    frq_rt = AP.rtFrequency();
  } else if (_condition =='B') {
    //reactive to AudioFile data
    amp_m = map(noise(noiseIndex), 0, 1, minAmp*0.25, maxAmp*0.75);
    amp_rt = map(noise(noiseIndex), 0, 1, minAmp*0.25, maxAmp*0.75);
    frq_m = map(noise(noiseIndex), 0, 1, minFrq, maxFrq);
    frq_rt = map(noise(noiseIndex), 0, 1, minFrq, maxFrq);
  } else if (_condition == ' ')  {
    amp_m = 0;
    amp_rt = 0;
    frq_m = 0;
    frq_rt = 0;
  }
}


void MapValues() {
  amp_norm = map(amp_rt, 0, maxAmp, 0, 1);
  frq_norm = map(frq_rt, minFrq, maxFrq, 0, 1);
  
  brightness_rt = map(frq_rt, minFrq*0.9, maxFrq*1.1, 70, 255);
  brightness_m = map(frq_m, minFrq*0.9, maxFrq*1.1, 0, 255);
  brightness_m_inner = map(frq_m, minFrq*0.9, maxFrq*1.1, 127, 255);
  orbitSpeed = map(amp_rt, 0, maxAmp, 0.001, 0.1);
  rotationSpeed = map(amp_rt, minFrq*0.9, maxFrq*1.1, 0.001, 0.1);
  m = map(amp_m, 0, maxAmp, 0, 10);
}


float supershape(float theta, Shape S) {
  float t1 = abs((1/S.a) * cos(S.m *theta / 4));
  t1 = pow(t1, S.n2);
  float t2 = abs((1/S.b) * sin(S.m * theta / 4));
  t2 = pow(t2, S.n3);
  float t3 = t1 + t2;
  float r = pow(t3, -1/S.n1);
  return r;
}


PVector[][] CalculateVertices(Shape s1, Shape s2) {
  PVector[][] vertices = new PVector[lod + 1][lod + 1];
  for (int i = 0; i < lod+1; i++) {
    float lat = map(i, 0, lod, -HALF_PI, HALF_PI);
    float r2 = supershape(lat, s2);
    for (int j = 0; j < lod+1; j++) {
      float lon = map(j, 0, lod, -PI, PI);
      float r1 = supershape(lon, s1);
      float x = r * r1 * cos(lon) * r2 * cos(lat);
      float y = r * r1 * sin(lon) * r2 *cos(lat);
      float z = r * r2 * sin(lat);
      vertices[i][j] = new PVector(x, y, z);
    }
  }
  return vertices;
}


void DrawShape(PVector[][] v) {
  for (int i = 0; i < lod; i++) {
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < lod + 1; j++) {
      PVector v1 = v[i][j];
      PVector v2 = v[i+1][j];
      vertex(v1.x, v1.y, v1.z);
      vertex(v2.x, v2.y, v2.z);
    }
    endShape();
  }
}


void MoveCamera() {
  float angle = 10;
  cam.rotateX(cos(angle)*0.0005);
  cam.rotateZ(cos(angle)*0.001);
}


void CalibrateValues() {
  if (amp_rt > maxAmp) {
    maxAmp = amp_rt;
  }
  if (amp_rt < minAmp) {
    minAmp = amp_rt;
  }
  if (frq_rt > maxFrq) {
    maxFrq = frq_rt;
  }
  if (frq_rt < minFrq) {
    minFrq = frq_rt;
  }
}


void PrintInstructions() {
  println("--------------------------------------------------------------");
  println("Press <a> to begin condition A. Press <b> to begin condition B.");
  println("Press <p> to prepare for next participant. \nPress <e> to end test early.");
  println("--------------------------------------------------------------");
}