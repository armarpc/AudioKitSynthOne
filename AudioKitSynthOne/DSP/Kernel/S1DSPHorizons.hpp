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
    int defaultFrameCount = 480001;
    
public:
    int phaserFrameCount = 128;
    
    int moogladderFrameCount = 8;
    
    int vdelayTime = 10;
    int vdelayFrameCount = defaultFrameCount;
    
    int pan2Duration = 10;
    int pan2FrameCount = defaultFrameCount;
    
    int oscDuration = pan2Duration; // Pan oscilator
    int oscFrameCount = defaultFrameCount;
    
    int buthpFrameCount = 8;
    
    int butbpFrameCount = 8;
    
    int compressorDuration = 0.5;
    int compressorFrameCount = defaultFrameCount;
    
    int revscDuration = 5;
    int revscFrameCount = defaultFrameCount;
    
    
private:
    int durationToFrameCount(double duration);
};

#endif /* S1DSPHorizons_hpp */
