//
//  S1DSPKernel+didChanges.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"
#import "AEArray.h"
#import "AEMessageQueue.h"
#import "S1NoteState.hpp"

void S1DSPKernel::dependentParameterDidChange(DependentParameter param) {
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueueDependentParameter,
                                              audioUnit,
                                              @selector(dependentParameterDidChange:),
                                              AEArgumentStruct(param),
                                              AEArgumentNone);
}

//can be called from within the render loop
void S1DSPKernel::beatCounterDidChange() {
    S1ArpBeatCounter beatCounter = {sequencer.getArpBeatCount(), heldNoteNumbersAE.count};
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueueBeatCounter,
                                              audioUnit,
                                              @selector(arpBeatCounterDidChange:),
                                              AEArgumentStruct(beatCounter),
                                              AEArgumentNone);
}


///can be called from within the render loop
void S1DSPKernel::playingNotesDidChange() {
    aePlayingNotes.polyphony = S1_MAX_POLYPHONY;
    if (parameters[isMono] > 0.f) {
        aePlayingNotes.playingNotes[0] = { monoNote->rootNoteNumber, monoNote->transpose, monoNote->velocity, monoNote->amp };
        for(int i = 1; i<S1_MAX_POLYPHONY; i++) {
            aePlayingNotes.playingNotes[i] = { -1, -1, -1, -1 };
        }
    } else {
        for(int i=0; i<S1_MAX_POLYPHONY; i++) {
            const auto& note = (*noteStates)[i];
            aePlayingNotes.playingNotes[i] = { note.rootNoteNumber, note.transpose, note.velocity, note.amp };
        }
    }
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueuePlayingNotes,
                                              audioUnit,
                                              @selector(playingNotesDidChange:),
                                              AEArgumentStruct(aePlayingNotes),
                                              AEArgumentNone);
}

///can be called from within the render loop
void S1DSPKernel::heldNotesDidChange() {
    for(int i = 0; i<S1_NUM_MIDI_NOTES; i++)
        aeHeldNotes.heldNotes[i] = false;
    int count = 0;
    AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, note) {
        const int nn = note->noteNumber;
        aeHeldNotes.heldNotes[nn] = true;
        ++count;
    }
    aeHeldNotes.heldNotesCount = count;
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueueHeldNotes,
                                              audioUnit,
                                              @selector(heldNotesDidChange:),
                                              AEArgumentStruct(aeHeldNotes),
                                              AEArgumentNone);
}

// detects if there was a change in the playing notes, for the purpose of
// updating the UI
bool S1DSPKernel::playingNotesChanged() {
    bool changed = false;
    for (int i = 0; i < S1_MAX_POLYPHONY; i++) {
        int rootNoteNumber = (*noteStates)[i].rootNoteNumber;
        int transpose =  (*noteStates)[i].transpose;
        int velocity = (*noteStates)[i].velocity;
        if (rootNoteNumber != lastPlayingNotes[i][0]) {
            lastPlayingNotes[i][0] = rootNoteNumber;
            changed = true;
        }
        if (transpose != lastPlayingNotes[i][1]) {
            lastPlayingNotes[i][1] = transpose;
            changed = true;
        }
        if (velocity != lastPlayingNotes[i][2]) {
            lastPlayingNotes[i][2] = velocity;
            changed = true;
        }
    }
    return changed;
}

