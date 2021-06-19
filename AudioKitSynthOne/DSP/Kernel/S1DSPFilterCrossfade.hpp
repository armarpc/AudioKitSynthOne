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
#include <AudioKit/soundpipe.h>

enum S1FilterType { noFilter, lowPassFilter, bandPassFilter, highPassFilter };

class S1DSPFilterCrossfade {
public:
    void compute(sp_data *sp, S1FilterType filterType, sp_moogladder *loPass, sp_buthp *hiPass, sp_butbp *bandPass, float *in, float *out) {
        if (filterType == noFilter) {
            filterType = lowPassFilter;
        }
        S1FilterType filter = (currentFrame < halfDuration) ? previousFilter : nextFilter;
        float filterOut = 0.f;
        
        switch (filter) {
            case lowPassFilter:
                sp_moogladder_compute(sp, loPass, in, &filterOut);
                break;
            case bandPassFilter:
                sp_butbp_compute(sp, bandPass, in, &filterOut);
                break;
            case highPassFilter:
                sp_buthp_compute(sp, hiPass, in, &filterOut);
                break;
            case noFilter:
                filterOut = *in;
        }
        //*out = inputMultiplier * (*in) + (1 - inputMultiplier) * filterOut;
    }
    
private:
    void startCrossfade(S1FilterType previousFilter, S1FilterType nextFilter) {
        currentFrame = 0;
        this->previousFilter = previousFilter;
        this->nextFilter = nextFilter;
    }
    
    static const int crossfadeFrameCount = 20;
    const int halfDuration = crossfadeFrameCount / 2;
    int currentFrame = 0;
    
    S1FilterType previousFilter = noFilter;
    S1FilterType nextFilter = noFilter;
};

#endif /* S1DSPFilterCrossfade_hpp */
