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
#include <math.h>
#include <array>
#include <AudioKit/soundpipe.h>

enum S1FilterType { noFilter, lowPassFilter, bandPassFilter, highPassFilter };

class S1DSPFilterCrossfade {
public:
    S1DSPFilterCrossfade() {
        for (int i = 0; i < crossfadeFrameCount; i++) {
            crossfadeCurve[i] = sin(M_PI * (double)i / (double)crossfadeFrameCount);
        }
    };
    
    void startCrossfade(S1FilterType previousFilter, S1FilterType nextFilter) {
        currentFrame = 0;
        this->previousFilter = previousFilter;
        this->nextFilter = nextFilter;
    }
    
    void compute(sp_data *sp, sp_moogladder *loPass, sp_buthp *hiPass, sp_butbp *bandPass, float *in, float *out) {
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
        float inputMultiplier = getCurveValue(currentFrame++);
        *out = inputMultiplier * (*in) + (1 - inputMultiplier) * filterOut;
    }
    
private:
    static const int crossfadeFrameCount = 20;
    const int halfDuration = crossfadeFrameCount / 2;
    int currentFrame = 0;
    
    std::array<float, crossfadeFrameCount> crossfadeCurve{};
    
    S1FilterType previousFilter = noFilter;
    S1FilterType nextFilter = noFilter;
    
    float getCurveValue(int index) {
        return (index < crossfadeFrameCount) ? crossfadeCurve[index] : 0.f;
    }
};

#endif /* S1DSPFilterCrossfade_hpp */
