/*
  Library for all sensor stuff
*/
#include "WProgram.h"
#include "MyTypes.h"
#include "Senses.h"

//pins
#define X_ACC_PIN 5
#define Y_ACC_PIN 6
#define Z_ACC_PIN 7
#define Y_GYR_PIN 4
#define Z_GYR_PIN 3

Senses::Senses(Sensors &sensors) {
  analogReference(EXTERNAL);
  startTag = 0xDEAD; // for graphing
  _index = 0;
  _indexN = 1;
  _indexP = avgN;
  //storeCalibration(); // this line must NOT be left activated
  calibrate(sensors);
}

void Senses::calibrate(Sensors &sensors){
  // do not touch the 50; it is an offset as EEPROM data is always positive.
  sensors.xAcc.offset = EEPROM.read(0) - 50;
  sensors.yAcc.offset = EEPROM.read(1) - 50;
  sensors.zAcc.offset = EEPROM.read(2) - 50;
  sensors.yGyr.offset = EEPROM.read(3) - 50;
  sensors.zGyr.offset = EEPROM.read(4) - 50;  
}
void Senses::storeCalibration(){
  // do not touch the 50; it is an offset as EEPROM data is always positive.
  EEPROM.write(0,50 - 6);
  EEPROM.write(1,50 - 18);
  EEPROM.write(2,50 - 11);
  EEPROM.write(3,50 - 3);
  EEPROM.write(4,50 - 2);
}
void Senses::update(Sensors &sensors){
  sensors.xAcc.raw = analogRead(X_ACC_PIN);
  sensors.yAcc.raw = analogRead(Y_ACC_PIN);
  sensors.zAcc.raw = analogRead(Z_ACC_PIN);
  sensors.yGyr.raw = analogRead(Y_GYR_PIN);
  sensors.zGyr.raw = analogRead(Z_GYR_PIN);
  sensors.times.raw= micros();
  //matt
  sensors.times.seconds = sensors.times.raw/1000000;


// calculate stuff
  sensors.times.array[_index] = sensors.times.raw;
  sensors.times.totDelta     = sensors.times.array[_index] - sensors.times.array[_indexN];
  sensors.times.lastDelta    = sensors.times.array[_index] - sensors.times.array[_indexP];
  //times.lastDelta = 5000;
  //times.totDelta = 5000 * avgN - 5000;
  sensors.xAcc.array[_index]    = averageSense(sensors.xAcc.array[_index], sensors.xAcc.raw, sensors.xAcc.tot, sensors.xAcc.avg);
  sensors.xAcc.array[_index] = sensors.xAcc.raw;
  sensors.xAccD.raw          = (sensors.xAcc.array[_index] - sensors.xAcc.array[_indexN]);
  sensors.xAccD.array[_index]   = averageSense(sensors.xAccD.array[_index], sensors.xAccD.raw, sensors.xAccD.tot, sensors.xAccD.avg);
  sensors.xAccDD.raw         = (sensors.xAccD.array[_index] - sensors.xAccD.array[_indexN]);
  sensors.xAccDD.array[_index]  = averageSense(sensors.xAccDD.array[_index], sensors.xAccDD.raw, sensors.xAccDD.tot, sensors.xAccDD.avg);
  
  sensors.yzAcc.raw          = sqrt(pow((sensors.yAcc.raw-532),2)+pow((sensors.zAcc.raw-518),2));
  sensors.yzAcc.array[_index]   = averageSense(sensors.yzAcc.array[_index], sensors.yzAcc.raw, sensors.yzAcc.tot, sensors.yzAcc.avg);
  sensors.yzAccD.raw         = (sensors.yzAcc.array[_index] - sensors.yzAcc.array[_indexN]);
  sensors.yzAccD.array[_index]  = averageSense(sensors.yzAccD.array[_index], sensors.yzAccD.raw, sensors.yzAccD.tot, sensors.yzAccD.avg);
  sensors.yzAccDD.raw        = (sensors.yzAccD.array[_index] - sensors.yzAccD.array[_indexN]);
  sensors.yzAccDD.array[_index] = averageSense(sensors.yzAccDD.array[_index], sensors.yzAccDD.raw, sensors.yzAccDD.tot, sensors.yzAccDD.avg);

  sensors.xyzAcc.raw         = sqrt(pow((sensors.xAcc.raw-519),2)+pow((sensors.yAcc.raw-532),2)+pow((sensors.zAcc.raw-518),2));
  sensors.xyzAcc.array[_index]  = averageSense(sensors.xyzAcc.array[_index], sensors.xyzAcc.raw, sensors.xyzAcc.tot, sensors.xyzAcc.avg);

  sensors.yzGyr.raw          = sqrt(pow((sensors.yGyr.raw-385),2)+pow((sensors.zGyr.raw-384),2));
  sensors.yzGyr.array[_index]   = averageSense(sensors.yzGyr.array[_index], sensors.yzGyr.raw, sensors.yzGyr.tot, sensors.yzGyr.avg);
  sensors.yzGyrD.raw         = (sensors.yzGyr.array[_index] - sensors.yzGyr.array[_indexN]);
  sensors.yzGyrD.array[_index]  = averageSense(sensors.yzGyrD.array[_index], sensors.yzGyrD.raw, sensors.yzGyrD.tot, sensors.yzGyrD.avg);
  sensors.yzGyrDD.raw        = (sensors.yzGyrD.array[_index] - sensors.yzGyrD.array[_indexN]);
  sensors.yzGyrDD.array[_index] = averageSense(sensors.yzGyrDD.array[_index], sensors.yzGyrDD.raw, sensors.yzGyrDD.tot, sensors.yzGyrDD.avg);



  //distance calculations
  // notes: direction change isn't great. 6 o'clock trigger could be better.
  sensors.distance.delta = (sensors.yzGyr.array[_index]+sensors.yzGyr.array[_indexP])*sensors.distance.factor*sensors.times.lastDelta*0.000001;
  //if (abs(xAngD.avg) > 500) { minsensors.distance.total = 0.6;} else {minsensors.distance.total = 0.1;}
  if (!activeStall) {
    activeStall = (sensors.yzGyr.raw < 15); //(sensors.distance.delta < sensors.distance.minDist);
  } else {
    activeStall =  (sensors.yzGyr.raw < 30); //(sensors.distance.delta < (sensors.distance.minDist *1.2));
  }
  if (activeStall) {
    sensors.distance.delta = 0;
    //this next line does more harm than good.
    //xAng.raw  = xAng.raw + (xAngD.avg/(avgN-1) + 0.5);
  } else { //if: Gyration is high enough to be decisive, calculate angle of poi about x
    sensors.xAng.raw        = atan2((sensors.yGyr.raw-385.001)+0.0001,(sensors.zGyr.raw-384.001)+0.0001) * 180/3.14159 +  180;
  }
  if (sensors.xAng.raw > 500 || sensors.xAng.raw < -500) {sensors.xAng.raw = sensors.xAng.array[_indexP] ;}
  // bring angle back between 360 and 0
  if (sensors.xAng.raw >= 360)  { sensors.xAng.raw = sensors.xAng.raw - 360;}
  if (sensors.xAng.raw < 0   )  { sensors.xAng.raw = sensors.xAng.raw + 360;}
  sensors.xAng.array[_index]   = averageSense(sensors.xAng.array[_index], sensors.xAng.raw, sensors.xAng.tot, sensors.xAng.avg);

  //if (!activeStall) {
    sensors.xAngD.raw         = (sensors.xAng.array[_index] - sensors.xAng.array[_indexN]);
    // bring delta angle back between - 180 and 180
    if (sensors.xAngD.raw > 180)  { sensors.xAngD.raw = sensors.xAngD.raw - 360;}
    if (sensors.xAngD.raw < -180) { sensors.xAngD.raw = sensors.xAngD.raw + 360;}
    
  //} else { 
  //  sensors.xAngD.raw = sensors.xAngD.avg;
  //}
  sensors.xAngD.array[_index]  = averageSense(sensors.xAngD.array[_index], sensors.xAngD.raw, sensors.xAngD.tot, sensors.xAngD.avg);
  
  if (!activeStall && abs(sensors.xAng.raw-sensors.xAng.array[_indexP]) > 30 && abs(sensors.xAng.raw-sensors.xAng.array[_indexP]) < 330) {
    //sensors.distance.dir=-sensors.distance.dir; // 1 or -1
    //todo: turn dir back on
    sensors.distance.dir=sensors.distance.dir; // 1 or -1
  }
  sensors.distance.total = sensors.distance.total + sensors.distance.delta*sensors.distance.dir;
  sensors.distance.array[_index] = sensors.distance.total;
  sensors.distance.error = 0;
  
  // bring distance back between 360 and 0
  if (sensors.distance.total >= 360) { sensors.distance.total = sensors.distance.total - 360;}
  if (sensors.distance.total < 0   ) { sensors.distance.total = sensors.distance.total + 360;}
  
  if (sensors.xAcc.raw > 600 && sensors.xAccD.avg < 0 && sensors.xAccD.avgLast > 0 && sensors.xAccDD.avg < 0){
    sensors.distance.error = (int(180+sensors.distance.array[_indexN])%360)-180;
    sensors.distance.total = sensors.distance.total - sensors.distance.error;
    // bring distance back between 360 and 0
    if (sensors.distance.total >= 360) { sensors.distance.total = sensors.distance.total - 360;}
    if (sensors.distance.total < 0   ) { sensors.distance.total = sensors.distance.total + 360;}
  }
  if (sensors.distance.array[_indexP] < 10 && sensors.distance.total > 350) {
    sensors.distance.circleCount++;
  } else if (sensors.distance.array[_indexP] > 350 && sensors.distance.total < 10) {
    sensors.distance.circleCount--;
  }
  if (sensors.distance.circleCount < 0) { sensors.distance.circleCount = 4 ;}
  if (sensors.distance.circleCount > 4) { sensors.distance.circleCount = 0 ;}
  // end sensors.distance.totalance stuff
  

  // bump sensors
  sensors.yzGyr.avgLast    = sensors.yzGyr.avg;
  sensors.yzGyrD.avgLast   = sensors.yzGyrD.avg;
  sensors.yzGyrDD.avgLast  = sensors.yzGyrDD.avg;
  sensors.xAcc.avgLast     = sensors.xAcc.avg;
  sensors.xAccD.avgLast    = sensors.xAccD.avg;
  sensors.xAccDD.avgLast   = sensors.xAccDD.avg;
  sensors.yzAcc.avgLast    = sensors.yzAcc.avg;
  sensors.yzAccD.avgLast   = sensors.yzAccD.avg;
  sensors.yzAccDD.avgLast  = sensors.yzAccDD.avg;
  sensors.xAng.avgLast     = sensors.xAng.avg;
  sensors.xAngD.avgLast    = sensors.xAngD.avg;
  sensors.times.lastDeltaLast = sensors.times.lastDelta;

  _index++;
  if (_index >= avgN)  { _index = 0; }
  _indexN++;
  if (_indexN >= avgN) { _indexN = 0; }
  _indexP++;
  if (_indexP >= avgN) { _indexP = 0; }
  //end bumping
  
  
  Serial.begin(115200);
  outputData[0] = sensors.xAcc.raw;
  outputData[1] = sensors.distance.total;
  outputData[2] = sensors.yzGyr.raw;
  outputData[3] = 255;//colR;
  outputData[4] = 255;//colG;
  outputData[5] = 255;//colB;
  outputData[6] = int(512+sensors.xAccD.raw);
  outputData[7] = int(512+sensors.xAccDD.raw);
  outputData[8] = 512+256*sensors.distance.dir;//xMag.raw; 
  outputData[9] = 0;//xMagD.raw+512;
  outputData[10]= sensors.xAng.raw;
  outputData[11]= sensors.xAngD.raw+512;
  outputData[12] = int(512+sensors.yzGyrD.raw);
  outputData[13] = int(512+sensors.yzGyrDD.raw);

//  Serial.write((unsigned byte*)&startTag, 2);
//  for (byte i=0; i<=13; i++) {
//    Serial.write((unsigned byte*)&outputData[i], 2);
//  }
/*
//for serial monitor
   Serial.print("     ");
   Serial.print(sensors.xAcc.raw,DEC);
   Serial.print("     ");
   Serial.print(sensors.yAcc.raw,DEC);
   Serial.print("     ");
   Serial.print(sensors.zAcc.raw,DEC);
   Serial.print("     ");
   Serial.print(sensors.yGyr.raw,DEC);
   Serial.print("     ");
   Serial.print(sensors.zGyr.raw,DEC);
   Serial.println(" ");
   */
}

int Senses::averageSense(int n_index, int n_new, long &n_tot, float &n_avg){
  n_tot = n_tot - n_index;
  n_tot = n_tot + n_new;
  n_avg = n_tot / float(avgN);
  return n_new;
}



