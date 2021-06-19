//
//  S1NoteState.hpp
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 4/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//
//  Atomic unit of a "note"; managed by S1DSPKernel

#pragma once

#import <vector>
#import <list>
#import <string>
#import "AudioKit/AKSoundpipeKernel.hpp"
#import "S1AudioUnit.h"
#import "S1Parameter.h"
#import "S1Rate.hpp"
#import "S1DSPFilterCrossfade.hpp"

#ifdef __cplusplus

class S1DSPKernel;

struct S1NoteState {

    // kernel
    S1DSPKernel* kernel;

    // stage
    enum NoteStateStage { stageOff, stageOn, stageRelease };
    NoteStateStage stage = stageOff;

    // gate
    float internalGate = 0;

    // velocity stores the original velocity...not used in "process"
    int velocity;

    // amp is a transform of velocity and is used in "process"
    float amp = 0;

    // filter envelope value
    float filter = 0;

    // -1 denotes an invalid note number
    int rootNoteNumber = 0;

    // used for frequency look up and UI
    int transpose = 0;
    
    //Amplitude ADSR
    sp_adsr *adsr;
    
    //Filter Cutoff Frequency ADSR
    sp_adsr *fadsr;
    
    //Morphing Oscillator 1 & 2
    sp_oscmorph2d *oscmorph1;
    sp_oscmorph2d *oscmorph2;

    // osc crossfade
    sp_crossfade *morphCrossFade;
    
    //Subwoofer OSC
    sp_osc *subOsc;
    
    //FM OSC
    sp_fosc *fmOsc;
    
    //NOISE OSC
    sp_noise *noise;
    
    //FILTERS
    sp_moogladder *loPass;
    sp_buthp *hiPass;
    sp_butbp *bandPass;
    S1DSPFilterCrossfade s1FilterCrossfade;
    sp_crossfade *filterCrossFade;

    // methods
    inline float getParam(S1Parameter param);
    inline int sampleRate() const;
    void startNoteHelper(int noteNumber, int velocity, float frequency);
    void init();
    void destroy();
    void clear();
    void run(int frameIndex, float *outL, float *outR);
};

#endif
