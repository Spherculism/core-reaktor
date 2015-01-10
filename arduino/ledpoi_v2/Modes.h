/*
  Header file Available modes
*/
#ifndef Modes_h
#define Modes_h

#include "WProgram.h"
#include "MyTypes.h"

#include "Colour.h"
#include "Senses.h"

class Modes
{
  public:
    Modes(byte pointless);
//    void setMode(byte mode_id);
    void playMode(System &system, RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    
    void bank1_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank1_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank1_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank1_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    
    void bank2_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank2_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank2_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank2_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    
    void bank3_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank3_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank3_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank3_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    
    void bank4_mode1(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank4_mode2(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank4_mode3(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
    void bank4_mode4(RGBHSV &ledA, RGBHSV &ledB, Sensors &sensors, Colour &colour);
  private:
};

#endif

