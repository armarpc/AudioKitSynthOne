//
//  S1DSPHorizons.cpp
//  AudioKitSynthOne
//
//  Created by Carlos Gómez on 12/6/21.
//  Copyright © 2021 AudioKit. All rights reserved.
//

#include "S1DSPHorizons.hpp"

S1DSPHorizons::S1DSPHorizons(double sampleRate) {
    calculateFrameCounts(sampleRate);
}

void S1DSPHorizons::calculateFrameCounts(double sampleRate) {
    vdelayFrameCount = durationToFrameCount(sampleRate, vdelayDuration);
    pan2FrameCount = durationToFrameCount(sampleRate, pan2Duration);
    oscFrameCount = durationToFrameCount(sampleRate, oscDuration);
    compressorFrameCount = durationToFrameCount(sampleRate, compressorDuration);
    revscFrameCount = durationToFrameCount(sampleRate, revscDuration);
    widenFrameCount = durationToFrameCount(sampleRate, widenDuration);
}

int S1DSPHorizons::durationToFrameCount(double sampleRate, double duration) {
    // Add 1 to accomodate for rounding errors (see sp_vdelay_init)
    return duration * sampleRate + 1;
}
