//
//  S1DSPHorizons.hpp
//  AudioKitSynthOne
//
//  Created by Carlos Gómez on 12/6/21.
//  Copyright © 2021 AudioKit. All rights reserved.
//

#ifndef S1DSPHorizons_hpp
#define S1DSPHorizons_hpp

#include <stdio.h>

class S1DSPHorizons {
private:
    int defaultFrameCount = 480001; // 48000 * 10 + 1
    
public:
    S1DSPHorizons(double sampleRate);
    
    int phaserFrameCount = 47;
    
    int moogladderFrameCount = 8;
    
    int vdelayDuration = 10; // seconds
    int vdelayFrameCount = defaultFrameCount;
    
    int pan2Duration = 10;
    int pan2FrameCount = defaultFrameCount;
    
    int oscDuration = pan2Duration; // pan2 oscilator
    int oscFrameCount = defaultFrameCount;
    
    int buthpFrameCount = 8;
    
    int butbpFrameCount = 8;
    
    int compressorDuration = 0.5;
    int compressorFrameCount = defaultFrameCount;
    
    int revscDuration = 5;
    int revscFrameCount = defaultFrameCount;
    
    int widenDuration = 0.05;
    int widenFrameCount = defaultFrameCount;
    
    // max between moogladder, buthp, and butbp
    int filtersFrameCount = 8;
    
private:
    void calculateFrameCounts(double sampleRate);
    int durationToFrameCount(double sampleRate, double duration);
};

#endif /* S1DSPHorizons_hpp */
