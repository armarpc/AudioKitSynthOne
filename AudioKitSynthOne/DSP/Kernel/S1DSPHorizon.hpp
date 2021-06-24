//
//  S1DSPHorizon.hpp
//  AudioKitSynthOne
//
//  Created by Carlos Gómez on 12/6/21.
//  Copyright © 2021 AudioKit. All rights reserved.
//

#ifndef S1DSPHorizon_hpp
#define S1DSPHorizon_hpp

#include <stdio.h>

class S1DSPHorizon {
private:
    int defaultFrameCount = 480001; // 48000 * 10 + 1
    
public:
    S1DSPHorizon(double sampleRate);
    void updateSampleRate(double sampleRate);
    
    // Next are the horizon frame counts for each operation. Among the included operations,
    // osc, buthp, and widen are rather simple computationally, so there might not
    // be much advantage in optimizing them out of the process function. 
    
    int pan2Duration = 10; // seconds
    int pan2FrameCount = defaultFrameCount;
    
    int oscDuration = pan2Duration; // pan2 oscilator
    int oscFrameCount = defaultFrameCount;
    
    int phaserFrameCount = 47;
    
    int moogladderFrameCount = 8;
    
    int vdelayDuration = 10;
    int vdelayFrameCount = defaultFrameCount;
    
    int buthpFrameCount = 8;
    
    int compressorDuration = 0.5;
    int compressorFrameCount = defaultFrameCount;
    
    int revscDuration = 5;
    int revscFrameCount = defaultFrameCount;
    
    int widenDuration = 0.05;
    int widenFrameCount = defaultFrameCount;
    
    // Maximum of all horizons (which is that of vdelay and pan2)
    int maxFrameCount = defaultFrameCount;
    
private:
    void calculateFrameCounts(double sampleRate);
    int durationToFrameCount(double sampleRate, double duration);
};

#endif /* S1DSPHorizon_hpp */
