/*
 LED Reactor Lights v2
  - danny thomas
  - matt terry
  - license .... GPL?
  - version 4
  - 1st January 2011
*/

#include "MyTypes.h"
#include "Colour.h"
#include "Senses.h"
#include "Modes.h"
Colour colour(1);
RGBHSV ledA;
RGBHSV ledB;
//Senses senses(1);
//Sensors sensors;
//matt
Sensors sensors;
Senses senses(sensors);

Modes modes(1);
System system;

void setup() {
  
  system.bank = 0;
  system.mode = 0;
  system.bankToggle = false;
  system.modeToggle = false;
  system.bootSequence = 0;
  
  
  //prepare led initial states
  ledA.e = true;  //inner led
  ledB.e = false;   //outer led
  colour.setHSV(ledA,0,0,0);
  colour.setHSV(ledB,0,0,0);
//
  //short startup sequence//
//  for (int i=0; i<=240; i+=1) {
//    ledA.H=i; ledB.H=i;
//    colour.byHSV(ledA);
//    colour.byHSV(ledB);
//    delay(5);
//  }
  for (int i=0; i<=7; i++) {
    ledA.V = 255*(i % 2);
    ledB.V = 255*(i % 2);
    colour.byHSV(ledA);
    colour.byHSV(ledB);
    delay(100);
  }
  
  //colour.setRGB(ledA,255,0,0);
  //colour.setRGB(ledB,0,0,255);
  //colour.byRGB(ledA);
  //colour.byRGB(ledB);
//  delay(100);
 
  sensors.distance.minDist = 1.0;
  sensors.distance.factor=3.07;
  sensors.distance.dir=1;
  
//   delay(1000);
}

void loop(){
  senses.update(sensors);
  switch (system.bootSequence){
    case 0:
      if (sensors.xAcc.raw > 545){ //hanging
        //just jump to play mode
        ledA.S = 255; ledA.V = 255;
        ledB.S = 255; ledB.V = 255;
        system.hueA = 30;
        system.hueB = 60;
        system.bootSequence = 10;
        // on default mode we scroll through all modes / banks
        system.bankToggle = true;
        system.modeToggle = true;
      }
      if (sensors.xAcc.raw > 502 && sensors.xAcc.raw < 522){ // horizontal
        //go through setup
        system.bootSequence = 7;
      }
      if (sensors.xAcc.raw < 490){ //upside down{
        //go through setup
        system.bootSequence++;
      }
      break;
    
    case 1: //MODES: wait until turn to hanging
      if (sensors.xAcc.raw > 545){ //hanging
        system.bootSequence++; // wait to start
      }
      break;  
      
    case 2://set bank (ledA)
      if (sensors.xAcc.raw > 545){ //hanging
        ledA.S = 255;
        ledA.V = 255;
//        if (millis() % 10 < 5){
//          ledA.V = 255;
//        } else {
//          ledA.V = 0;
//        }
        ledB.S = 0; ledB.V = 0;
        
        system.bank++;
        if (system.bank > 4){
          system.bank = 1; 
        }
        ledA.H = 80*(system.bank-1);
        colour.byHSV(ledA);
        colour.byHSV(ledB);
        delay(1000);
        }
      if (sensors.xAcc.raw < 490){ //upside down
        system.bootSequence++;
        delay(100);
      }
      break;
    
    case 3://set mode (ledB)
      if (sensors.xAcc.raw < 490){ //upside down
        ledA.S = 255;
        ledA.V = 255;
        ledB.S = 255;
        ledB.V = 255;
        //flash
//        if (millis() % 10 < 5){
//          ledA.V = 255;
//          ledB.V = 0;
//        } else {
//          ledA.V = 0;
//          ledA.V = 255;
//        }
        system.mode++;
        if (system.mode > 4){
          system.mode = 1; 
        }
        ledB.H = 80*(system.mode-1);
        colour.byHSV(ledA);
        colour.byHSV(ledB);
        delay(1000);
        }
      if (sensors.xAcc.raw > 545){ //hanging
        system.bootSequence = 7;
        ledA.H = 0;
        ledB.H = 0;
        delay(100);
      }
      break;
    
    case 7://COLOURS: wait until turn to hanging
      if (sensors.xAcc.raw > 545){ //hanging
        system.bootSequence++; // wait to start
      }
      break;
      
    case 8://set colour A
      if (sensors.xAcc.raw > 545){ //hanging
        ledA.S = 255; ledA.V = 255;
        ledB.S = 0; ledB.V = 0;
        ledA.H += 30;
        colour.byHSV(ledA);
        colour.byHSV(ledB);
        delay(750);
      }
      if (sensors.xAcc.raw < 490){ //upside down
        system.bootSequence++;
        system.hueA = ledA.H;
        delay(100);
      }
      break;
      
    case 9: //set colour B
      if (sensors.xAcc.raw < 490){ //upside down
        ledA.S = 255; ledA.V = 255;
        ledB.S = 255; ledB.V = 255;
        ledB.H += 30;
//        colour.byHSV(ledA);
        colour.byHSV(ledB);
        delay(750);
      }
      if (sensors.xAcc.raw > 545){ //hanging
        system.bootSequence++;
        system.hueB = ledB.H;
        delay(100);
      }
      break;
      
      
    case 10:
      //play
      modes.playMode(system, ledA, ledB, sensors, colour);
      
      // first mode ALWAYS scrolls through modes
      if (system.mode == 1){
        system.modeToggle = true;
      }
      // bump the modes / banks every ten seconds
      if (sensors.times.seconds % 10 == 0 && sensors.times.secondsLatch == true){
        sensors.times.secondsLatch = false;
      if (system.modeToggle) {
        system.mode++; // bump the mode every 10 seconds
        if(system.mode > 4){ 
          system.mode = 1;
          if (system.bankToggle) {
            system.bank++; // bump the bank every 4 modes
            if(system.bank > 4){ 
              system.bank = 1;
            }
          }
        }
      }
        
      }
      if (sensors.times.seconds % 10 == 5) {
        sensors.times.secondsLatch = true;
      }
      break;
      
    default:
      break;
  }
  Serial.print("     ");
  Serial.print(system.bank,DEC);
  Serial.print("     ");
  Serial.print(system.mode,DEC);
  Serial.print("     ");
  Serial.print(system.bankToggle,DEC);
  Serial.print("     ");
  Serial.print(system.modeToggle,DEC);
  Serial.println();
  //delay(20);
  delayMicroseconds(6000 - micros()%6000);
}
