/*
  Library for RGB and HSV colour settings of two LEDs.
  Input is in form of a struct, {R, G, B, H, S, V, end}
*/

#include "WProgram.h"
#include "Colour.h"
#include "MyTypes.h"

// Code that gets called on import of colour class
Colour::Colour(byte pointless) // needs an input 
{  
  // prepare pins for output - DO NOT CHANGE
  // these pins are also used in function byRGB
  pinMode(10, OUTPUT);//red, a
  pinMode(9, OUTPUT);//green, a
  pinMode(6, OUTPUT);//blue, a
  pinMode(5, OUTPUT);//red, b
  pinMode(11, OUTPUT);//green, b
  pinMode(3, OUTPUT);//blue, b
  
  // dim curve, as eyes don't perceive brightness linearly
  byte dim_curve[] = {
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
  for (int i=1; i <= 256; i++) {_dim_curve[i]=dim_curve[i];}
  
  //set default colour values
  Col black = {0,0,0};
  Col white = {255,255,255};
  Col red = {255,0,0};
  Col yellow = {255,255,0};
  Col green = {0,255,0};
  Col cyan = {0,255,255};
  Col blue = {0,0,255};
  Col magenta = {255,0,255};
}

// set LED to RGB
void Colour::byRGB(RGBHSV input) { 
  if (!input.e) {
    analogWrite(10, 255-_dim_curve[input.R]);
    analogWrite(9 , 255-_dim_curve[input.G]);
    analogWrite(6 , 255-_dim_curve[input.B]);
  } else {
    analogWrite(5 , 255-_dim_curve[input.R]);
    analogWrite(11, 255-_dim_curve[input.G]);
    analogWrite(3 , 255-_dim_curve[input.B]);
  }
}

// set LED to HSV
void Colour::byHSV(RGBHSV &input) {   
  if (input.H > 360){
    input.H = input.H-360;
  } else if (input.H < 0){
    input.H=input.H+360;
  }
//  sat = input.S;
//  val = input.V;
  val = _dim_curve[input.V];
  sat = 255-_dim_curve[255-input.S];
  int base;
  if (sat == 0) { // Acromatic color (gray). Hue doesn't mind.
    input.R = val;
    input.G = val;
    input.B = val;
  } else  {
    base = ((255 - sat) * val)>>8;
    switch(input.H/60) {
    case 0:
      input.R = val;
      input.G = (((val-base)*input.H)/60)+base;
      input.B = base;
      break;
    case 1:
      input.R = (((val-base)*(60-(input.H%60)))/60)+base;
      input.G = val;
      input.B = base;
      break;
    case 2:
      input.R = base;
      input.G = val;
      input.B = (((val-base)*(input.H%60))/60)+base;
      break;
    case 3:
      input.R = base;
      input.G = (((val-base)*(60-(input.H%60)))/60)+base;
      input.B = val;
      break;
    case 4:
      input.R = (((val-base)*(input.H%60))/60)+base;
      input.G = base;
      input.B = val;
      break;
    case 5:
      input.R = val;
      input.G = base;
      input.B = (((val-base)*(60-(input.H%60)))/60)+base;
      break;
    }
  }
  byRGB(input);
}

// set RGB to triplet
void Colour::setRGB(RGBHSV &input, byte red, byte grn, byte blu) {
 input.R = red;
 input.G = grn;
 input.B = blu;
}

// set HSV to triplet
void Colour::setHSV(RGBHSV &input, int hue, byte sat, byte val) {
  input.H = hue;
  input.S = sat;
  input.V = val;
}

// set RGB to triplet
void Colour::setCOL(RGBHSV &input, Col col) {
 input.R = col.R;
 input.G = col.G;
 input.B = col.B;
}


