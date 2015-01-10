/*
  Header for all sensor stuff
*/

#ifndef Senses_h
#define Senses_h

#include "WProgram.h"
#include "MyTypes.h"
#include "EEPROM.h"

class Senses
{
  public:
    Senses(Sensors &sensors);
    void update(Sensors &sensors);
    void calibrate(Sensors &sensors);
    void storeCalibration();
    void monitor();
    int averageSense(int n_index, int n_new, long &n_tot, float &n_avg);
  private:
    byte _index;
    byte _indexN;
    byte _indexP;
    boolean activeStall;
    unsigned int outputData[14];
    unsigned int startTag;
};

#endif
