/*
  Header for RGB and HSV colour settings of two LEDs.
*/

#ifndef Colour_h
#define Colour_h

#include "WProgram.h"
#include "MyTypes.h"

struct Col { 
  byte R;
  byte G;
  byte B;
};

class Colour
{
  public:
    Colour(byte pointless);
    void byRGB(RGBHSV input);
    void byHSV(RGBHSV &input);
    void setRGB(RGBHSV &input, byte red, byte grn, byte blu);
    void setHSV(RGBHSV &input, int hue, byte sat, byte val);
    void setCOL(RGBHSV &input, Col col);
    
    Col black;
    Col white;
    Col red;
    Col yellow;
    Col green;
    Col cyan;
    Col blue;
    Col magenta;

  private:
    byte _dim_curve[256];
    byte val;
    byte sat;
};

#endif

