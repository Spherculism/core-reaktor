/*
  Available modes
*/

#include "WProgram.h"
#include "Modes.h"
#include "MyTypes.h"

#include "Colour.h"
#include "Senses.h"



// Code that gets called on import of mode class
Modes::Modes(byte pointless) // needs an input 
{  
  
}

//void Modes::setMode(byte mode_id){
//  
//}
// set LED to RGB
void Modes::playMode(System &system, RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour) { 
  switch (system.bank){
    
    case 1:
      switch (system.mode){
        case 1:
          bank1_mode1(ledA, ledB, sensors, colour);
          break;
        case 2:
          bank1_mode2(ledA, ledB, sensors, colour);
          break;
        case 3:
          bank1_mode3(ledA, ledB, sensors, colour);
          break;
        case 4:
          bank1_mode4(ledA, ledB, sensors, colour);
          break;
        default:
          system.mode = 1;
          break;
      }
      break;
    
    case 2:
      switch (system.mode){
        case 1:
          bank2_mode1(ledA, ledB, sensors, colour);
          break;
        case 2:
          bank2_mode2(ledA, ledB, sensors, colour);
          break;
        case 3:
          bank2_mode3(ledA, ledB, sensors, colour);
          break;
        case 4:
          bank2_mode4(ledA, ledB, sensors, colour);
          break;
        default:
          system.mode = 1;
          break;
      }
      break;
    
    case 3:
      switch (system.mode){
        case 1:
          bank3_mode1(ledA, ledB, sensors, colour);
          break;
        case 2:
          bank3_mode2(ledA, ledB, sensors, colour);
          break;
        case 3:
          bank3_mode3(ledA, ledB, sensors, colour);
          break;
        case 4:
          bank3_mode4(ledA, ledB, sensors, colour);
          break;
        default:
          system.mode = 1;
          break;
      }
      break;
    
    case 4:
      switch (system.mode){
        case 1:
          bank4_mode1(ledA, ledB, sensors, colour);
          break;
        case 2:
          bank4_mode2(ledA, ledB, sensors, colour);
          break;
        case 3:
          bank4_mode3(ledA, ledB, sensors, colour);
          break;
        case 4:
          bank4_mode4(ledA, ledB, sensors, colour);
          break;
        default:
          system.mode = 1;
          break;
      }
      break;
    
    default:
      system.bank = 1;
      system.mode = 1;
      break;
  }
      
  //offset
  ledA.H += system.hueA;
  ledB.H += system.hueB;
  colour.byHSV(ledA);
  colour.byHSV(ledB);
}


/**
  BANK 1 - SIMPLE MODES?
*/
void Modes::bank1_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
    //both leds same, as you spin one shifts positive, the other negative
  ledA.H = sensors.yzGyr.avg/3;
  ledB.H = -sensors.yzGyr.avg/3;
}

void Modes::bank1_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //flicker
  ledA.H = 2*random(20);
  ledB.H = 2*random(20);
  ledA.V = 255 - random(20);
  ledB.V = 255 - random(20);
}

void Modes::bank1_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //outer color limited fade, inner split compliment flash
  ledA.H = (int)sensors.distance.total;
  if((int)sensors.distance.total % 50 < 25){
     ledB.H = ledA.H+210;
  } else {
     ledB.H = ledA.H-150;
  }
}
void Modes::bank1_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //tick tock fade
  if((int)sensors.distance.total % 120 < 60){
    ledA.H = (int)sensors.distance.total % 60;
    ledB.H = 60-(int)sensors.distance.total % 60;
  } else {
    ledA.H = 60-(int)sensors.distance.total % 60;
    ledB.H = (int)sensors.distance.total % 60;
  }
}


/**
  BANK 2 - SOLID COLOR CHANGES
*/
void Modes::bank2_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //toggle colours in 1 circle - kinda works, the thirds are a bit big
  if (sensors.distance.total >= 0 && sensors.distance.total < 120){
    ledA.H = 0;
    ledB.H = 60;
  }
  if (sensors.distance.total >= 120 && sensors.distance.total < 240){
    ledA.H = 120;
    ledB.H = 180;
  }
  if (sensors.distance.total >= 240 && sensors.distance.total < 360){
    ledA.H = 240;
    ledB.H = 300;
  }
}
void Modes::bank2_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //switch colours each beat -- very random results, not as accurate as used to be ???
  switch(sensors.distance.circleCount){
    case 0:
      ledA.H = 0;
      ledB.H = 20;
      break;
    case 1:
      ledA.H = 90;
      ledB.H = 110;
      break;
    case 2:
      ledA.H = 180;
      ledB.H = 200;
      break;
    case 3:
      ledA.H = 270;
      ledB.H = 290;
      break;
    default:
      ledA.H = 0;
      ledB.H = 20;
      break;
  }
}

void Modes::bank2_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //outer color limited fade, inner split analogous flash
  ledA.H = 180+(int)sensors.distance.total % 120;
  ledA.H = (int)sensors.distance.total;
  if((int)sensors.distance.total % 50 < 25){
     ledB.H = ledA.H+30;
  } else {
     ledB.H = ledA.H-30;
  }
}


void Modes::bank2_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //switch colours each beat -- needs edit...
  switch(sensors.distance.circleCount){
    case 0:
      ledA.H = 20;
      ledB.H = 200;
      break;
    case 1:
      ledA.H = 110;
      ledB.H = 290;
      break;
    case 2:
      ledA.H = 200;
      ledB.H = 20;
      break;
    case 3:
      ledA.H = 290;
      ledB.H = 110;
      break;
    default:
      ledA.H = 20;
      ledB.H = 200;
      break;
  }
}







/**
  BANK 3 - RAINBOWS
*/
void Modes::bank3_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
   //muli rainbows
  ledA.H = sensors.distance.total/6;
  ledB.H = -sensors.distance.total/3;
}

void Modes::bank3_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //inner fade rgb, outer toggle rainbow - like it
  if((int)sensors.distance.total % 60 == 1){
    ledA.H = sensors.distance.total;
  }
  ledB.H = sensors.distance.total;
}

void Modes::bank3_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  // petal fade hue - bit lame
  ledA.H = (int)sensors.distance.total % 60/2;
  ledB.H = (int)sensors.distance.total % 60/2;
  if((int)sensors.distance.total % 120 < 60){
    ledA.H = (int)sensors.distance.total % 60;
    ledB.S = 120-2*((int)sensors.distance.total % 60);
    
  } else {
    ledA.H = 60-(int)sensors.distance.total % 60;
    ledB.S = 2*((int)sensors.distance.total % 60);
  }
}
void Modes::bank3_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
   //muli rainbows needs edit ...
  ledA.H = sensors.distance.total/2;
  ledB.H = ledA.H - 45;
}



/**
  BANK 4 - FLASHY
*/
void Modes::bank4_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //flashy colors based on distance - works
  if((int)sensors.distance.total % 60 < 30){
    ledA.H = 0;
    ledB.H = 0;
  } else {
     ledA.H = 310;
     ledB.H = 230;
  }
}

void Modes::bank4_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //flashy colors based on distance - needs edit ...
  if((int)sensors.distance.total % 90 < 45){
    ledA.H = 0;
    ledB.H = 0;
  } else {
     ledA.H = 20;
     ledB.H = 340;
  }
}
void Modes::bank4_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //flashy colors based on distance - needs edit ...
  if((int)sensors.distance.total % 120 < 60){
    ledA.H = 0+sensors.distance.total;
    ledB.H = 0-sensors.distance.total;
  } else {
     ledA.H = 20-sensors.distance.total;
     ledB.H = 340+sensors.distance.total;
  }
  
  
  //ledB.H = ledB.H+1;
  //ledA.H = ledB.H+120;
  
  //ledA.H = 80+(sensors.xAcc.avg  - 512);
  //ledB.H = sensors.yzGyr.avg + 240;
  
  //colour.setCOL(ledA,colour.blue);
  //colour.setCOL(ledB,colour.red);
  //colour.byRGB(ledA);
  //colour.byHSV(ledB);
  //colour.byRGB(ledB);
  
  //...based on micros() - does strange things, i think because the whole code is time limited
//  if(micros() % 100 < 50){
//    ledA.H = 0;
//    ledB.H = 20;
//  } else {
//     ledA.H = 180;
//     ledB.H = 200;
//  }
}
void Modes::bank4_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour){
  //flashy colors based on distance - needs edit ...
  if((int)sensors.distance.total % 30 < 10){
    ledA.H = 0;
    ledB.H = 0;
  } else {
    if((int)sensors.distance.total % 30 < 20){ 
      ledA.H = 120;
      ledB.H = 120;
    } else {
      ledA.H = 240;
      ledB.H = 240;
    }
  }
}
