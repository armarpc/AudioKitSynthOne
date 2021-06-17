//
//  S1DSPFilterCrossfade.hpp
//  AudioKitSynthOne
//
//  Created by Carlos Gómez on 16/6/21.
//  Copyright © 2021 AudioKit. All rights reserved.
//

#ifndef S1DSPFilterCrossfade_hpp
#define S1DSPFilterCrossfade_hpp

#include <stdio.h>
#include <array>

enum S1FilterType { none, lowPassFilter, bandPassFilter, highPassFilter };

class S1DSPFilterCrossfade {
public:
    S1DSPFilterCrossfade(double sampleRate): sampleRate{sampleRate} {
        
    };
    
    void startCrossfade(S1FilterType previousFilter, S1FilterType nextFilter);
    void compute(float *in, float *out);
    
private:
    static const int crossfadeFrameCount = 20;
    int currentFrame = 0;
    double sampleRate;
    
    std::array<float, crossfadeFrameCount> crossfadeCurve{};
    
    S1FilterType previousFilter = none;
    S1FilterType nextFilter = none;
};

#endif /* S1DSPFilterCrossfade_hpp */
