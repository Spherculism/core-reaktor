/*
  LED reactor lights (working title :)
   - danny thomas
   - matt terry
   - license......GPL?

   - Version 3.3
   - 29th November 2010
*/

// the main functions of the poi
//int mode = 0;
//int mode = 1;
//int mode = 2;
//int mode = 3;
//int mode = 4;
//int mode = 5;
//int mode = 6;
//int mode = 7;
int mode = 8;
//int mode = 9;
/*0:poiModeFade();
  1:poiModeFadeAcc();
  2:poiModeFadeMag();
  3:poiModeToggle();
  4:poiModeToggleAcc();
  5:poiModePie();
  6:poiModeHueSelect();
  7:poiModeTriggerTest();
  8:customMode();
  9:poiModeFadeDist();
*/

// flicker the saturation or value to add texture
struct Pattern {
  byte    maxValue;
  int     time; //millis (code revolutions currently) to reduce by 1
  byte    qty;
  byte    nextValue;
  int     timeCount;
  byte    qtyCount;
  boolean start;
  boolean active;
};

Pattern pulseFade = {255, 4, 5, 0, 0, 0, 0, true};

// does work, but the idea is that you set a byte array like 00110101000 and that sequence plays through somewhere
//byte sequence = B0;
// output some values to the monitor
boolean debugOutput = 0;
// or send data to processing graph
boolean graphOutput = 1;
// Harmonies
// alters the color based on color harmonies
int harmony = 0, harmonyShift = 0, harmonyKey = 0, harmonyTimer = 0, harmonyTimerMax = 40, harmonyMax = 4;
  int harmony1[4] = {0, 30, 0, -30};  // Analogous
  int harmony2[4] = {0, 150, 0, -150}; // Split complements
  int harmony3[4] = {0, 180, 0, -180}; //Complement
  int harmony4[4] = {0, 120, 0, -120}; //Triadic

/*******************
  global constants
*******************/
//input
#define X_ACC_PIN 0
#define Y_ACC_PIN 1
#define Z_ACC_PIN 2
#define Y_ROT_PIN 3
#define Z_ROT_PIN 4
#define X_MAG_PIN 5
#define ZERO_G_PIN 7
//output
#define RED_PIN 11
#define GRN_PIN 10
#define BLU_PIN 9
#define pi 3.14159

/*******************
  Graphing
*******************/

unsigned int startTag = 0xDEAD;  // Analog port maxes at 1023 so this is a safe termination value
// If this is defined it prints out the FPS that we can send a
// complete set of data over the serial port.
//#define CHECK_FPS
#ifdef CHECK_FPS
  unsigned long startTime, endTime;
  startTime = millis();
#endif
/*******************
  global variables
*******************/

// output
byte colR = 255, colG = 1, colB = 1, H = 0, S = 255, V = 255;

// control
int colToggle = 0;
float decay = 0, hueShift = 0;
int spread = 30;
// distance calculation
float dist = 0;
float deltaDist = 0;
float distFactor = 3.07;
float distError = 0;
int distDir = 1;
byte circleCount = 0;
float minDist = 0.2;

// Radius calculation
float radius = 0;

// Beat detection
long time;
long lastBeatTime = micros();
int numBeats;
int beatIndex = 0;
const int beatAvgN = 4;

// which way is north?
float angN  = 0;
float angA = 0;
int xMagMax = 0;
int xMagMin = 0;
int magmax = 0;
int magavg = 0;

//output graphs
int output1 = 0, output2 = 0, output3 = 0, output4 = 0, output5 = 0, output6 = 0;
int output7 = 0, output8 = 0, output9 = 0, output10 = 0, output11 = 0, output12 = 0;
int output13 = 0, output14 = 0;

// loops
const int avgN = 13;
int index = 0;
int indexN = 1;
int indexP = avgN;

// sensor STRUCT
struct Sensor {
  int raw;
  long tot;
  float avg;
  float avgLast;
};


// rotation
Sensor yRot    = {0, 0, 0, 0};
Sensor zRot    = {0, 0, 0, 0};
Sensor yzRot   = {0, 0, 0, 0};
Sensor yzRotD  = {0, 0, 0, 0};
Sensor yzRotDD = {0, 0, 0, 0};
Sensor xAng    = {0, 0, 0, 0};
Sensor xAngD   = {0, 0, 0, 0};

// acceleration
Sensor xAcc    = {0, 0, 0, 0};
Sensor xAccD   = {0, 0, 0, 0};
Sensor xAccDD  = {0, 0, 0, 0};
Sensor yAcc    = {0, 0, 0, 0};
Sensor zAcc    = {0, 0, 0, 0};
Sensor yzAcc   = {0, 0, 0, 0};
Sensor yzAccD  = {0, 0, 0, 0};
Sensor yzAccDD = {0, 0, 0, 0};
Sensor xyzAcc  = {0, 0, 0, 0};
// acceleration, free fall
int zeroG = 0; // note: reading of zeroG will be a HIGH or a LOW
// compass
Sensor xMag    = {0, 0, 0, 0};
Sensor xMagD   = {0, 0, 0, 0};
Sensor xMagDD  = {0, 0, 0, 0};

// average arrays
int yzRot_arr[avgN];
int yzRotD_arr[avgN];
int yzRotDD_arr[avgN];
int xAng_arr[avgN];
int xAngD_arr[avgN];
int xAcc_arr[avgN];
int xAccD_arr[avgN];
int xAccDD_arr[avgN];
int yzAcc_arr[avgN];
int yzAccD_arr[avgN];
int yzAccDD_arr[avgN];
int xyzAcc_arr[avgN];
int xMag_arr[avgN];
int xMagD_arr[avgN];
int xMagDD_arr[avgN];
long times_arr[avgN];
long duration_arr[beatAvgN];
int dist_arr[avgN];

// for testing maximum values
int testMax = 0;

// for time
struct SensorT {
  long raw;
  long lastDelta;
  long totDelta;
  long lastDeltaLast;
};

SensorT times   =  {0, 0, 0, 0};

//for beats
struct SensorB {
  float raw;
  float tot;
  float avg;
  float avgLast;
};
SensorB duration = {10000000,10000000*beatAvgN,10000000,10000000};

//triggers t
struct Trigger {
  int startPoint;
  int finishPoint; //currently not used
  boolean active;
  boolean activeLast;
  boolean start;
  boolean finish;
};
boolean activeStall = false;

Trigger tFlick     = {4, 3, 0, 0, 0, 0};  // yzRotD HIGH
Trigger tStall     = {30, 3, 0, 0, 0, 0}; // yzRot LOW
Trigger tStallUp   = {20, 3, 0, 0, 0, 0};
Trigger tStallDown = {20, 3, 0, 0, 0, 0};
Trigger tWrap      = {300, 5, 0, 0, 0, 0}; // yzAcc HIGH
Trigger tThrow     = {10, 5, 0, 0, 0, 0}; // yzRot HIGH and zeroG


/*
  used for saturation and value to make them look prettierer
*/
//changed first value to 1 else error...?
//#include  <avr/pgmspace.h>
//PROGMEM prog_uchar dim_curve[] = {
const byte dim_curve[] = {
    1,   1,   1,   2,   2,   2,   2,   2,   2,   3,   3,   3,   3,   3,   3,   3,
    3,   3,   3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   4,   4,   4,   4,
    4,   4,   4,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   6,   6,   6,
    6,   6,   6,   6,   6,   7,   7,   7,   7,   7,   7,   7,   8,   8,   8,   8,
    8,   8,   9,   9,   9,   9,   9,   9,   10,  10,  10,  10,  10,  11,  11,  11,
    11,  11,  12,  12,  12,  12,  12,  13,  13,  13,  13,  14,  14,  14,  14,  15,
    15,  15,  16,  16,  16,  16,  17,  17,  17,  18,  18,  18,  19,  19,  19,  20,
    20,  20,  21,  21,  22,  22,  22,  23,  23,  24,  24,  25,  25,  25,  26,  26,
    27,  27,  28,  28,  29,  29,  30,  30,  31,  32,  32,  33,  33,  34,  35,  35,
    36,  36,  37,  38,  38,  39,  40,  40,  41,  42,  43,  43,  44,  45,  46,  47,
    48,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,
    63,  64,  65,  66,  68,  69,  70,  71,  73,  74,  75,  76,  78,  79,  81,  82,
    83,  85,  86,  88,  90,  91,  93,  94,  96,  98,  99,  101, 103, 105, 107, 109,
    110, 112, 114, 116, 118, 121, 123, 125, 127, 129, 132, 134, 136, 139, 141, 144,
    146, 149, 151, 154, 157, 159, 162, 165, 168, 171, 174, 177, 180, 183, 186, 190,
    193, 196, 200, 203, 207, 211, 214, 218, 222, 226, 230, 234, 238, 242, 248, 255,
};

/*******************
  SETUP
*******************/
void setup() {
  analogReference(EXTERNAL);
  //Serial.begin(19200);
  Serial.begin(115200);
  // initialize all the array to 0:
  for (int thisReading = 0; thisReading < avgN; thisReading++){
    yzRot_arr[thisReading]   = 0;
    yzRotD_arr[thisReading]   = 0;
    yzRotDD_arr[thisReading]  = 0;
    xAcc_arr[thisReading]    = 0;
    xAccD_arr[thisReading]   = 0;
    xAccDD_arr[thisReading]  = 0;
    yzAcc_arr[thisReading]   = 0;
    yzAccD_arr[thisReading]  = 0;
    yzAccDD_arr[thisReading] = 0;
    xyzAcc_arr[thisReading]  = 0;
    xMag_arr[thisReading]    = 0;
    xMagD_arr[thisReading]   = 0;
    xMagDD_arr[thisReading]  = 0;
    times_arr[thisReading]   = 0;
    xAng_arr[thisReading]    = 0;
    xAngD_arr[thisReading]   = 0;
  }
  for (int i = 0; i <= beatAvgN; i++) {duration_arr[i]=10000000;}
  // Output pins
  pinMode(RED_PIN, OUTPUT);
  pinMode(GRN_PIN, OUTPUT);
  pinMode(BLU_PIN, OUTPUT);
  //zero g doesn't work so putting it here:
  pinMode(ZERO_G_PIN, INPUT);
}

/*******************
  LOOP
*******************/
void loop(){
  poiRead();
  poiCalcStuff();
  poiCalcDistance();
  poiCalcNorth();
  poiCalcTrigger();
  poiCalcHarmony();
  switch (mode){
    case 0:
      poiModeFade();
      break;
    case 1:
      poiModeFadeAcc();
      break;
    case 2:
      poiModeFadeMag();
      break;
    case 3:
      poiModeToggle();
      break;
    case 4:
      poiModeToggleAcc();
      break;
    case 5:
      poiModePie();
      break;
    case 6:
      poiModeHueSelect();
      break;
    case 7:
      poiModeTriggerTest();
      break;
    case 8:
      customMode();
      break;
    case 9:
      poiModeFadeDist();
      break;
  }
  poiSetPattern();
  poiWrite();
  poiBumpSensors();
  if (debugOutput){
    poiDebugOutput();
  }
  if (graphOutput){
     poiGraphOutput();
  }
//  if (debugOutput == 0) {
    delayMicroseconds(6000 - micros()%6000);
  //}
}

/*******************
  INPUT
*******************/
/*
  Read the input sensors
*/
void poiRead(){
  xAcc.raw = analogRead(X_ACC_PIN);
  yAcc.raw = analogRead(Y_ACC_PIN);
  zAcc.raw = analogRead(Z_ACC_PIN);
  yRot.raw = analogRead(Y_ROT_PIN);
  zRot.raw = analogRead(Z_ROT_PIN);
  xMag.raw = analogRead(X_MAG_PIN);
  zeroG = digitalRead(ZERO_G_PIN);
  times.raw=micros();
}

/*******************
  OUTPUT
*******************/
/*
  Display colors
*/
void poiWrite(){
  analogWrite(RED_PIN, 255-colR);
  analogWrite(GRN_PIN, 255-colG);
  analogWrite(BLU_PIN, 255-colB);
}

/*******************
  CALCULATIONS
*******************/
/*
  Smoothing: Store last n values and set the average
*/
int poiCalcAverage(int n_index, int n_new, long &n_tot, float &n_avg){
  n_tot = n_tot - n_index;
  n_tot = n_tot + n_new;
  n_avg = n_tot / float(avgN);
  return n_new;
}
/*
   Calculate stuff
*/
void poiCalcStuff(){
  times_arr[index]   = times.raw;
  times.totDelta     = times_arr[index] - times_arr[indexN];
  times.lastDelta    = times_arr[index] - times_arr[indexP];
  //times.lastDelta = 5000;
  //times.totDelta = 5000 * avgN - 5000;
  xAcc_arr[index]    = poiCalcAverage(xAcc_arr[index], xAcc.raw, xAcc.tot, xAcc.avg);
  xAcc_arr[index] = xAcc.raw;
  xAccD.raw          = (xAcc_arr[index] - xAcc_arr[indexN]);//* (1000000.0/times.totDelta);
  xAccD_arr[index]   = poiCalcAverage(xAccD_arr[index], xAccD.raw, xAccD.tot, xAccD.avg);
  xAccDD.raw         = (xAccD_arr[index] - xAccD_arr[indexN]);//* (1000000.0/times.totDelta);
  xAccDD_arr[index]  = poiCalcAverage(xAccDD_arr[index], xAccDD.raw, xAccDD.tot, xAccDD.avg);
  
  yzAcc.raw          = sqrt(pow((yAcc.raw-532),2)+pow((zAcc.raw-518),2));
  yzAcc_arr[index]   = poiCalcAverage(yzAcc_arr[index], yzAcc.raw, yzAcc.tot, yzAcc.avg);
  yzAccD.raw         = (yzAcc_arr[index] - yzAcc_arr[indexN]);//* (1000000.0/times.totDelta);
  yzAccD_arr[index]  = poiCalcAverage(yzAccD_arr[index], yzAccD.raw, yzAccD.tot, yzAccD.avg);
  yzAccDD.raw        = (yzAccD_arr[index] - yzAccD_arr[indexN]);//* (1000000.0/times.totDelta);
  yzAccDD_arr[index] = poiCalcAverage(yzAccDD_arr[index], yzAccDD.raw, yzAccDD.tot, yzAccDD.avg);

  xyzAcc.raw         = sqrt(pow((xAcc.raw-529),2)+pow((yAcc.raw-532),2)+pow((zAcc.raw-518),2));
  xyzAcc_arr[index]  = poiCalcAverage(xyzAcc_arr[index], xyzAcc.raw, xyzAcc.tot, xyzAcc.avg);

  yzRot.raw          = sqrt(pow((yRot.raw-386),2)+pow((zRot.raw-387),2));
  yzRot_arr[index]   = poiCalcAverage(yzRot_arr[index], yzRot.raw, yzRot.tot, yzRot.avg);
  yzRotD.raw         = (yzRot_arr[index] - yzRot_arr[indexN]);//* (1000000.0/times.totDelta);
  yzRotD_arr[index]  = poiCalcAverage(yzRotD_arr[index], yzRotD.raw, yzRotD.tot, yzRotD.avg);
  yzRotDD.raw        = (yzRotD_arr[index] - yzRotD_arr[indexN]);//* (100000.0/times.totDelta);
  yzRotDD_arr[index] = poiCalcAverage(yzRotDD_arr[index], yzRotDD.raw, yzRotDD.tot, yzRotDD.avg);

  xMag_arr[index]    = poiCalcAverage(xMag_arr[index], xMag.raw, xMag.tot, xMag.avg);
  xMagD.raw          = (xMag_arr[index] - xMag_arr[indexN]);//* (1000000.0/times.totDelta);
  xMagD_arr[index]   = poiCalcAverage(xMagD_arr[index], xMagD.raw, xMagD.tot, xMagD.avg);
  xMagDD.raw          = (xMagD_arr[index] - xMagD_arr[indexN]);//* (1000000.0/times.totDelta);
  xMagDD_arr[index]  = poiCalcAverage(xMagDD_arr[index], xMagDD.raw, xMagDD.tot, xMagDD.avg);
}

void poiBumpSensors(){

  yzRot.avgLast    = yzRot.avg;
  yzRotD.avgLast   = yzRotD.avg;
  yzRotDD.avgLast  = yzRotDD.avg;
  xAcc.avgLast     = xAcc.avg;
  xAccD.avgLast    = xAccD.avg;
  xAccDD.avgLast   = xAccDD.avg;
  yzAcc.avgLast    = yzAcc.avg;
  yzAccD.avgLast   = yzAccD.avg;
  yzAccDD.avgLast  = yzAccDD.avg;
  xAng.avgLast    = xAng.avg;
  xAngD.avgLast   = xAngD.avg;
  xMag.avgLast     = xAcc.avg;
  xMagD.avgLast    = xAccD.avg;
  xMagDD.avgLast   = xAccDD.avg;
  times.lastDeltaLast = times.lastDelta;

  index++;
  if (index >= avgN)  { index = 0; }
  indexN++;
  if (indexN >= avgN) { indexN = 0; }
  indexP++;
  if (indexP >= avgN) { indexP = 0; }
}


/*
  Distance around the circle (based on gyro)
*/
void poiCalcDistance(){
  // notes: direction change isn't great. 6 o'clock trigger could be better.
  deltaDist = (yzRot_arr[index]+yzRot_arr[indexP])*distFactor*times.lastDelta*0.000001;
  //if (abs(xAngD.avg) > 500) { minDist = 0.6;} else {minDist = 0.1;}
  if (!activeStall) {
    activeStall = (deltaDist < minDist);
  } else {
    activeStall = (deltaDist < (minDist *1.2));
  }
  if (activeStall) {
    deltaDist = 0;
    //this next line does more harm than good.
    //xAng.raw  = xAng.raw + (xAngD.avg/(avgN-1) + 0.5);
  } else {
//  if (yzAcc.raw > 20) { // if: rotation is high enough to be decisive, calculate angle of poi about x
    xAng.raw        = atan2((yRot.raw-386)+0.0001,(zRot.raw-387.001)+0.0001) * 180/3.14159 +  180;
  }
  if (xAng.raw > 500 || xAng.raw < -500) {xAng.raw = xAng_arr[indexP] ;}
  if (xAng.raw >= 360)  { xAng.raw = xAng.raw - 360;}
  if (xAng.raw < 0   )  { xAng.raw = xAng.raw + 360;}
  xAng_arr[index]   = poiCalcAverage(xAng_arr[index], xAng.raw, xAng.tot, xAng.avg);

  if (!activeStall) {
    xAngD.raw         = (xAng_arr[index] - xAng_arr[indexN]);
    if (xAngD.raw > 180)  { xAngD.raw = xAngD.raw - 360;}
    if (xAngD.raw < -180) { xAngD.raw = xAngD.raw + 360;}
  } else { xAngD.raw = xAngD.avg;}
  //xAngD.raw = xAngD.raw* (1000000.0/times.totDelta);
  xAngD_arr[index]  = poiCalcAverage(xAngD_arr[index], xAngD.raw, xAngD.tot, xAngD.avg);
  
  
  if (abs(xAng.raw-xAng_arr[indexP]) > 30 && abs(xAng.raw-xAng_arr[indexP]) < 330) {
  //if (abs(xAngD.avg > 10) && (xAngD.avgLast < 10)) {
    distDir=-distDir; // 1 or -1
  }


  dist = dist + deltaDist*distDir;
  dist_arr[index] = dist;
  distError = 0;
  if (dist >= 360) { dist = dist - 360;}
  if (dist < 0   ) { dist = dist + 360;}
  //if (xAcc.raw > 600 && xAccD.avg < 0 && xAccD.avgLast > 0 && xAccDD.avg < 0 && dist > 0 && dist < 120){
 if (xAcc.raw > 600 && xAccD.avg < 0 && xAccD.avgLast > 0 && xAccDD.avg < 0){
    colToggle = !colToggle;
    distError = ((180+dist_arr[indexN])%360)-180;
    //dist = dist - dist_arr[indexN];
    dist = dist - distError;
    if (dist >= 360) { dist = dist - 360;}
    if (dist < 0   ) { dist = dist + 360;}



    //dist = (360.0+dist)%360.0;
//    if (dist < 40 || dist > 320){
//      if (dist < 0){
//        dist = dist+360;
//      }
//      distFactor = distFactor*360/(360+distError/3);
//    }
  }
    if (dist_arr[indexP] < 10 && dist > 350) {
      circleCount++;
    } else if (dist_arr[indexP] > 350 && dist < 10) {
      circleCount--;
    }
    if (circleCount < 0) { circleCount = 4 ;}
    if (circleCount > 4) { circleCount = 0 ;}

}
/*
  Calc angle of north from horizontal
*/
void poiCalcNorth(){
//  if (millis()%5000 < 5){
//    //reset
//    xMagMax = 0;
//    xMagMin = 1000;
//  }
  if (xMag.raw > xMagMax){
    xMagMax = xMag.raw;
  }

  if (xMag.raw < xMagMin){
    xMagMin = xMag.raw;
    if (dist > 180) {
      angN = -dist+270;
    } else {
      angN = -90+dist;
    }
  }

  magavg = (xMagMax - xMagMin)/2;
  magmax = magavg - xMagMin;

  angA = -((magavg - xMag.raw)*1.0/(1.0*magmax) -cos(dist*3.14159/180)*sin(angN*3.14159/180));
  angA = angA/(sin(dist*3.14159/180)*cos(angN*3.14159/180));
  angA = acos(angA);
  angA = angA*180 / 3.14159;

}

/*
  Register Trigger events
*/
void poiCalcTrigger(){
  //trigger Flick
  tFlick.active = (yzRotD.avg > tFlick.startPoint);
  tFlick.start  = (tFlick.active && !tFlick.activeLast);
  tFlick.finish = (!tFlick.active && tFlick.activeLast);
  tFlick.activeLast = tFlick.active;

  //trigger Stall
  tStall.active = (yzRot.raw < tStall.startPoint);
  tStall.start  = (tStall.active && !tStall.activeLast);
  tStall.finish = (!tStall.active && tStall.activeLast);
  tStall.activeLast = tStall.active;

  //trigger StallUp
  tStallUp.active = (yzRot.raw < tStallUp.startPoint && (dist > 135 && dist < 225));
  tStallUp.start  = (tStallUp.active && !tStallUp.activeLast);
  tStallUp.finish = (!tStallUp.active && tStallUp.activeLast);
  tStallUp.activeLast = tStallUp.active;

  //trigger StallDown
  tStallDown.active = (yzRot.raw < tStallDown.startPoint && (dist > 315 || dist < 45));
  tStallDown.start  = (tStallDown.active && !tStallDown.activeLast);
  tStallDown.finish = (!tStallDown.active && tStallDown.activeLast);
  tStallDown.activeLast = tStallDown.active;

  //t_Wrap
  tWrap.active = (yzAcc.raw > tWrap.startPoint);
  tWrap.start  = (tWrap.active && !tWrap.activeLast);
  tWrap.finish = (!tWrap.active && tWrap.activeLast);
  tWrap.activeLast = tWrap.active;

  //t_Throw
  //tThrow.active = (yzRot.avg > tThrow.startPoint);
  //tThrow.active = (zeroG);
  tThrow.active = (xyzAcc.avg < 2 && xyzAcc.avg > -2);
  tThrow.start  = (tThrow.active && !tThrow.activeLast);
  tThrow.finish = (!tThrow.active && tThrow.activeLast);
  tThrow.activeLast = tThrow.active;
}
/*
  Harmony - alters hue based on color harmonies
*/
void poiCalcHarmony(){
  if (harmony >= harmonyMax){
     harmony = 0;
  }
  if (harmony > 0){
    switch(harmony){
      case 1:
        harmonyShift = harmony1[harmonyKey];
        break;
      case 2:
        harmonyShift = harmony2[harmonyKey];
        break;
      case 3:
        harmonyShift = harmony3[harmonyKey];
        break;
      case 4:
        harmonyShift = harmony4[harmonyKey];
        break;
    }
    harmonyTimer+=1;
    //delay(100);
    if (harmonyTimer > harmonyTimerMax){
      harmonyTimer = 0;
      harmonyKey+=1;
      if (harmonyKey >= 4){
        harmonyKey = 0;
      }
    }
  }else {
    harmonyShift = 0;
  }
}
/*******************
  MODES
********************/
/*
  Fade green > blue > red as you spin faster
*/
void poiModeFade(){
  //cut off lowest values
  if (yzRot.avg > 3){
    poiSetHSV(60+yzRot.avg, 255, 255);
  } else {
    poiSetHSV(60, 255, 255);
  }
}
/*
  Fade green > blue > red based on accelerometer
*/
void poiModeFadeAcc(){
//  if (xAcc.avg-512 > 360){
//
//    H ++;
//    if (H >= 360){
//      H = 360;
//    }
//  } else {
//    H--;
//    if (H <= 0){
//      H = 0;
//    }
//  }
  //H = (xAcc - 512)*(360/512);
  H = (xAcc.avg-512)*0.7;
  H = constrain(H, 0, 360);
  poiSetHSV(H, 255, 255);
}
/*
  Fade green > blue > red based on magnemometer
*/
void poiModeFadeMag(){
  H = (xMag.avg-450)*3.6;
  H = constrain(H, 0, 360);
  poiSetHSV(H, 255, 255);
}

/*
  Toggle green > red > blue
*/
void poiModeToggle(){
  if (tFlick.start == true){
    colToggle += 1;
    decay = 0;
    if (colToggle > 2){
      colToggle = 0;
      harmony++;    //next harmony
    }
  }

  if (tStall.active){
    hueShift += 0.005;
    //constrain(hueShift, 0, 360);
    if (hueShift > 360){
      hueShift = 0;
    }
    decay += 0;
    if (decay > 255){
      decay = 255;
    }
  } else {
//    hueShift = 0;
    decay = 0;
  }

  switch (colToggle){
    case 0:
      if (tStall.start){
        poiSetHSV(0+hueShift, 10, 255); // flash of stall start
      } else {
        poiSetHSV(0+hueShift, 255, 255);
      }
      break;
    case 1:
      if (tStall.start){
        poiSetHSV(120+hueShift, 10, 255); // flash of stall start
      } else {
        poiSetHSV(120+hueShift, 255, 255);
      }
      break;
    case 2:
      if (tStall.start){
        poiSetHSV(240+hueShift, 10, 255); // flash of stall start
      } else {
        poiSetHSV(240+hueShift, 255, 255);
      }
      break;
  }
}

/*
  Toggle green > red > blue --- based on yz acc Wrap
*/
void poiModeToggleAcc(){
  if (tWrap.finish){
    colToggle += 1;
    decay = 0;
    if (colToggle > 2){
      colToggle = 0;
      harmony++;    //next harmony
    }
  }

  switch (colToggle){
    case 0:
      poiSetHSV(0, 255, 255); // flash of stall start
      break;
    case 1:
      poiSetHSV(120, 255, 255); // flash of stall start
      break;
    case 2:
      poiSetHSV(240, 255, 255); // flash of stall start
      break;
  }
}

/*
  Toggle green > red > blue
*/
void poiModeHueSelect(){
  if (yzRot.avg < 15){
    hueShift += 1.2;
    //constrain(hueShift, 0, 360);
    if (hueShift > 360){
      hueShift = 0;
    }
    decay += 1;
    if (decay > 255){
      decay = 255;
    }
  } else {
//    hueShift = 0;
    decay = 0;
  }
  poiSetHSV(0, 1, 255-decay);
}

/*
  Change color based on degrees around the circle
*/
void poiModePie(){
//  poiSetHSV(dist,255,255);
//  if (tFlick.active == 0){
//    if (yzRotD.avg > 10){
//      tFlick.active = 1;
//      dist = 0;
//    }
//  } else {
//    if (yzRotD.avg < 5){
//      t_FlickActive = 0;
//    }
//  }

//  colR = 0;
//  colG = 0;
//  colB = 0;
  //spokes

  H=0;
  S=255;
  V=20;
//  if (dist >= 30 && dist < 90 && colToggle){
//    H=0;
//    V=255;
//  }
//  if (dist > 150 && dist < 210 && !colToggle){
//    H=0;
//    V=255;
//  }
//  if (dist > 270 && dist < 330 && colToggle){
//    H=0;
//    V=255;
//  }

  if (dist >= 60-spread && dist < 60+spread){
    H=120;
    V=255;
  }
  if (dist >= 540-spread && dist < 540+spread){
    H=120;
    V=255;
  }
  if (dist >= 300-spread && dist < 300+spread){
    H=120;
    V=255;
  }


  poiSetHSV(H,S,V);
}
void poiModeTriggerTest(){
  if (tStall.start){
    hueShift = 0;
  }
  if (tWrap.start){
    hueShift = 60;
  }
//  if (tFlick.start){
//    hueShift = 120;
//  }
//  if (tThrow.active){
//    hueShift = 180;
//  } else {
//    hueShift = 0;
//  }
  poiSetHSV(hueShift, 255, 255);
}
/****************
  PATTERNS
****************/
void poiSetPattern(){

  //testing
  if (tStall.start){
    pulseFade.active = true;
  }

   if (pulseFade.active){
     //initialise
     if (pulseFade.start == true){
        //pulseFade.startTime = millis();
        pulseFade.start = false;
        pulseFade.timeCount = pulseFade.time;
        S = pulseFade.nextValue;
        //S=0;
     }
     //
     pulseFade.timeCount--;
     if (pulseFade.timeCount <= 0){
       //should be going other way...
       S += pulseFade.qty - pulseFade.qtyCount;
       S = constrain(S, 0, 255);
       pulseFade.timeCount = pulseFade.time;

       if (S >= 255){
         pulseFade.qtyCount++;
         pulseFade.nextValue = (1.0*pulseFade.maxValue*pulseFade.qtyCount)/pulseFade.qty;
         if (pulseFade.qtyCount < pulseFade.qty){
           //repeat
           pulseFade.start = true;
         } else {
           pulseFade.active = false;
           S = 255;
           pulseFade.qtyCount = 0;
           //pulseFade.timeCount = pulseFade.time;
         }
       }
     }
  }
}



/****************
  COLORS
****************/
/*
  set red, green, blue
*/
void poiSetRGB(int r, int g, int b){
   colR = r;
   colG = g;
   colB = b;
}

/*
  set hue, saturation, value (brightness)
*/
void poiSetHSV(int hue, int sat, int val){
  hue += harmonyShift;
  if (hue > 360){
    hue = hue-360;
  }

  val = dim_curve[val];
  sat = 255-dim_curve[255-sat];
//  val = pgm_read_word_near(dim_curve + val);
//  sat = 255 - pgm_read_word_near(dim_curve + 128);
  int base;
  if (sat == 0) { // Acromatic color (gray). Hue doesn't mind.
    colR = val;
    colG = val;
    colB = val;
  } else  {
    base = ((255 - sat) * val)>>8;
    switch(hue/60) {
    case 0:
      colR = val;
      colG = (((val-base)*hue)/60)+base;
      colB = base;
      break;
    case 1:
      colR = (((val-base)*(60-(hue%60)))/60)+base;
      colG = val;
      colB = base;
      break;
    case 2:
      colR = base;
      colG = val;
      colB = (((val-base)*(hue%60))/60)+base;
      break;
    case 3:
      colR = base;
      colG = (((val-base)*(60-(hue%60)))/60)+base;
      colB = val;
      break;
    case 4:
      colR = (((val-base)*(hue%60))/60)+base;
      colG = base;
      colB = val;
      break;
    case 5:
      colR = val;
      colG = base;
      colB = (((val-base)*(60-(hue%60)))/60)+base;
      break;
    }
  }
}


void customMode() {
  /* how isolated? doesn't quite work
  //radius 0 = head iso, 1 = normal, 2 = long arm
  //est radius from
  radius = (xAcc.avg*9.81*0.8/46.5)/pow(yzRot.avg*6.23*6.28/360,2);
  if (radius > 2) {radius = 2;}
  poiSetHSV(radius*180,255,255);
 */

// just testing things
// if (xAcc.avg > 580) {

// if (xAccDD.avg > 0) {
//   poiSetHSV(120,255,255);
// }
// else if (xAccDD.avg < 0){
//   poiSetHSV(0,255,255);
// }

 //poiSetHSV(dist,255,255);

// if (colToggle == 1){
//   //poiSetHSV(0,255,255);
//   poiSetHSV(dist,255,255);
// } else {
//   //poiSetHSV(240,255,255);
//   poiSetHSV(360-dist,255,255);
// }


// }
 //if (xyzAcc.raw < 30) {poiSetHSV(240,255,255);}

 // beat detection! tap 5 times to set the beat.
// if (yzAcc.avg > 50 && yzAcc.avgLast < 50) {
//   duration.raw = times_arr[index] - lastBeatTime;
//   lastBeatTime = times_arr[index];
//   numBeats = int(duration.raw/duration.avg + 0.5);
//   if (numBeats == 0) {numBeats = 1;}
//   duration.raw = duration.raw / numBeats;
//   duration.tot = duration.tot - duration_arr[beatIndex];
//   duration_arr[beatIndex] = duration.raw;
//   duration.tot = duration.tot + duration.raw;
//   duration.avg = duration.tot / beatAvgN;
//   beatIndex++;
//   if (beatIndex >= beatAvgN){ beatIndex = 0; }
//
// // reset
// if (duration.raw < 200000) {
//   duration.raw = 10000000;
//   duration.tot = 10000000*beatAvgN;
//   duration.avg = 10000000;
//   duration.avgLast = 10000000;
//   for (int i = 0; i <= beatAvgN; i++) {
//     duration_arr[i]=10000000;
//   }
// }
// }
// numBeats = int((micros()-lastBeatTime)/duration.avg + 0.5);
// //S = 255;
// S = 63*(numBeats%4);
// H=int(360*((micros()-lastBeatTime) % long(duration.avg))/duration.avg);
// if (H < 180) {
//   poiSetHSV(120,S,255);
// }
// else {
//   poiSetHSV(120,255,255-S);
// }
// poiSetHSV(H,S,V);
 // end beat detection


//  if (dist < 180){
//    poiSetHSV(0,255,255);
//  } else {
//    poiSetHSV(180,255,255);
//  }

//  poiSetRGB(0, 0, 255);
//  if (tStallUp.active){
//    poiSetRGB(255, 0, 0);
//  }
//  if (tStallDown.active){
//    poiSetRGB(0, 255, 0);
//  }

//  if (tStall.active){
//    poiSetRGB(255, 255, 255);
//  }

// north?
//  poiSetRGB(4*angN, 255, 255);
//    if (angA > 1) {poiSetHSV(int(angA*2),255,255);}

poiSetHSV((60+distDir*59),255,255);
}

/**
 * fade colors based on our distance calculation
 */
void poiModeFadeDist(){
  //temporary
  //poiSetHSV(dist, S, V);
  poiSetHSV(circleCount*72,S,V);
}

/*
  Print values to screen
*/
void poiDebugOutput(){
  Serial.print(" ang:");
  Serial.print(distDir, DEC);
  Serial.print(" ");
  Serial.print(xAng.raw, DEC);
  Serial.print(" ");
  Serial.print(xAngD.avg, DEC);
  Serial.println(" ");
}

void poiGraphOutput(){
  //xAcc=xAcc*3 - 1024;
  //yzAcc=(yzAcc+512)*3 - 1024;
  //yzRot=(yzRot+512)*3 - 1024;
  //
  //xAcc.avg_int=xAcc.avg*3 - 1024;
  //yzAcc.avg_int=(yzAcc.avdig+512)*3 - 1024;
  //yzRot.avg_int=(yzRot.avg+512)*3 - 1024;

  output1 = xAcc.raw-17;
  output2 = dist;
  output3 = yzRot.raw;
  output4 = colR;
  output5 = colG;
  output6 = colB;
  output7 = int(512+xAccD.raw);
  output8 = int(512+xAccDD.raw);
  output9 = yRot.raw - 386 + 512; 
  output10= zRot.raw - 387 + 512;
  output11= xAng.raw;
  output12= xAngD.raw+512;
  output13 = int(512+yzRotD.raw);
  output14 = int(512+yzRotDD.raw);

  Serial.write((unsigned byte*)&startTag, 2);
  Serial.write((unsigned byte*)&output1, 2);
  Serial.write((unsigned byte*)&output2, 2);
  Serial.write((unsigned byte*)&output3, 2);
  Serial.write((unsigned byte*)&output4, 2);
  Serial.write((unsigned byte*)&output5, 2);
  Serial.write((unsigned byte*)&output6, 2);
  Serial.write((unsigned byte*)&output7, 2);
  Serial.write((unsigned byte*)&output8, 2);
  Serial.write((unsigned byte*)&output9, 2);
  Serial.write((unsigned byte*)&output10, 2);
  Serial.write((unsigned byte*)&output11, 2);
  Serial.write((unsigned byte*)&output12, 2);
  Serial.write((unsigned byte*)&output13, 2);
  Serial.write((unsigned byte*)&output14, 2);

  #ifdef CHECK_FPS
    endTime = millis();
    Serial.print(" - FPS: ");
    Serial.println(1.f / (endTime-startTime) * 1000);
  #endif
}

