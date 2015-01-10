/*
  Struct definitions
*/

#ifndef MyTypes_h
#define MyTypes_h

#include "WProgram.h"

const byte avgN=13;

//system settings
struct System {
  byte bank;           //set initial mode group --- 1-4
  byte mode;           //set initial mode group --- 1-4
  boolean bankToggle;  //switch between different banks
  boolean modeToggle;  //switch between different modes
  byte bootSequence;   //initial setup sequence
  int hueA;            //using this to set colours
  int hueB;            //using this to set colours
};

// Struct for LEDs
struct RGBHSV {
  byte R;
  byte G;
  byte B;
  int H;
  byte S;
  byte V;
  boolean e;
};

//struct Light {
//  RGBHSV a;
//  RGBHSV b;
//};

// Struct for sensors
struct Sensor {
  byte offset;
  int raw;
  long tot;
  float avg;
  float avgLast;
  int array[avgN];
};
struct Time {
  long raw;
  long lastDelta;
  long totDelta;
  long lastDeltaLast;
  long array[avgN];
  //matt
  int seconds;
  boolean secondsLatch;
};
struct Distance {
  float total; //was dist
  float delta; //was deltaDist
  float factor; // was distFactor
  float error; //was distError
  int dir; // was distDir
  byte circleCount;
  float minDist;
  float array[avgN];
};

struct Sensors {
  // rotation
  Sensor yGyr;
  Sensor zGyr;
  Sensor yzGyr;
  Sensor yzGyrD;
  Sensor yzGyrDD;
  Sensor xAng;
  Sensor xAngD;
  // acceleration
  Sensor xAcc;
  Sensor xAccD;
  Sensor xAccDD;
  Sensor yAcc;
  Sensor zAcc;
  Sensor yzAcc;
  Sensor yzAccD;
  Sensor yzAccDD;
  Sensor xyzAcc;
  //Other
  Time times;
  Distance distance;
};


#endif
