//
//  MIDISettingsViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

protocol MIDISettingsPopOverDelegate: AnyObject {
    func didChangeMIDISources(_ midiSources: [MIDIInput])
    func didSelectMIDIChannel(newChannel: Int)
    func resetMIDILearn()
    func didToggleVelocitySensitiveMIDI()
    func velocitySensitiveMIDISettingValue() -> Bool
    func didChangeVelocitySensitiveMIDISensitivity(_ value: Double)
    func didToggleBackgroundAudio(_ value: Bool)
    func didToggleNeverSleep()
    func didToggleStoreTuningWithPreset(_ value: Bool)
    func didToggleLaunchWithLastTuning(_ value: Bool)
    func didSetBuffer()
}

class MIDISettingsViewController: UIViewController {
    @IBOutlet weak var channelStepper: Stepper!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var resetButton: SynthButton!
    @IBOutlet weak var inputTable: UITableView!
    @IBOutlet weak var sleepToggle: ToggleSwitch!
    @IBOutlet weak var velocitySensitiveToggle: ToggleSwitch!
    @IBOutlet weak var velocitySensitivityKnob: Knob!
    @IBOutlet weak var saveTuningToggle: ToggleSwitch!
    @IBOutlet weak var backgroundAudioToggle: ToggleSwitch!
    @IBOutlet weak var bufferSizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var launchWithLastTuningToggle: ToggleSwitch!
    weak var delegate: MIDISettingsPopOverDelegate?
    var userChannelIn: Int = 1
    var velocitySensitive = true
    var velocitySensitivity = 0.0
    var saveTuningWithPreset = false
    var launchWithLastTuning = false
    let conductor = Conductor.sharedInstance
    var isOmniMode = true

    var midiSources = [MIDIInput]() {
        didSet {
            displayMIDIInputs()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        view.layer.borderWidth = 2

        // input table
        inputTable.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)

        // setup channel stepper
        channelStepper.maxValue = 16
        if !isOmniMode {
            userChannelIn += 1 // Internal MIDI Channels start at 0...15, Users see 1...16
        }
        channelStepper.value = Double(userChannelIn)
        updateChannelLabel()

        // Setup Callbacks
        setupCallbacks()

        // Toggles
        sleepToggle.value = conductor.neverSleep ? 1 : 0
        velocitySensitiveToggle.value = velocitySensitive ? 1 : 0
        velocitySensitivityKnob.range = -2 ... 2
        velocitySensitivityKnob.value = velocitySensitivity
        velocitySensitivityKnob.alpha = 0
        saveTuningToggle.value = saveTuningWithPreset ? 1 : 0
        launchWithLastTuningToggle.value = launchWithLastTuning ? 1 : 0
        backgroundAudioToggle.value = conductor.backgroundAudio ? 1 : 0
    }

    override func viewWillAppear(_ animated: Bool) {
        displayMIDIInputs()
        bufferSizeSegmentedControl.selectedSegmentIndex = AKSettings.bufferLength.rawValue - AKSettings.BufferLength.shortest.rawValue
        bufferSizeSegmentedControl.setNeedsDisplay()
        updateVelocitySensitivityKnob()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func displayMIDIInputs() {
        if self.isViewLoaded && (self.view.window != nil) {
            inputTable.reloadData()
        }
    }

    // MARK: - Callbacks

    func setupCallbacks() {

        // channel stepper
        channelStepper.setValueCallback = { value in
            self.userChannelIn = Int(value)
            self.updateChannelLabel()
            self.delegate?.didSelectMIDIChannel(newChannel: self.userChannelIn - 1)
        }

        // reset
        resetButton.setValueCallback = { value in
            self.delegate?.resetMIDILearn()
            self.resetButton.value = 0
            let title = NSLocalizedString("MIDI Learn Reset", comment: "Alert Title: MIDI Learn Reset")
            let message = NSLocalizedString("All MIDI learn knob assignments have been removed.",
                                            comment: "Alert Message:  MIDI Learn Reset")
            self.displayAlertController(title, message: message)
        }

        // sleep toggle
        sleepToggle.setValueCallback = { value in
            if value == 1 {
                self.conductor.neverSleep = true
                let title = NSLocalizedString("Don't Sleep Mode", comment: "Alert Title: Allows On Mode")
                let message = NSLocalizedString("This mode is great for playing live. " +
                    "Background audio will also stay on. " +
                    "Note: It will use more power and could drain your battery faster",
                                                comment: "Alert Message: Allows On Mode")

                self.displayAlertController(title, message: message)
            } else {
                self.conductor.neverSleep = false
            }
            self.delegate?.didToggleNeverSleep()
        }

        // background audio
        backgroundAudioToggle.setValueCallback = { value in
            if value == 1 {
                let title = NSLocalizedString("Important", comment: "Alert Title: Background Audio")
                let message = NSLocalizedString(
                    "Background audio will drain the battery faster. Please turn off when not in use.",
                    comment: "Alert Message: Background Audio")
                self.displayAlertController(title, message: message)
            }
            self.conductor.backgroundAudio = value == 1
            self.delegate?.didToggleBackgroundAudio(value == 1 ? true : false)
        }

        // either velocity is max 127, or is midi velocity
        velocitySensitiveToggle.setValueCallback = { _ in
            self.delegate?.didToggleVelocitySensitiveMIDI()
            self.updateVelocitySensitivityKnob()
        }

        // midi velocity sensitivity value
        velocitySensitivityKnob.setValueCallback = { value in
            self.delegate?.didChangeVelocitySensitiveMIDISensitivity(value)
        }

        // save/restore tuning with preset
        saveTuningToggle.setValueCallback = { value in
            self.delegate?.didToggleStoreTuningWithPreset(value == 1 ? true : false)
        }

        // launch with last tuning
        launchWithLastTuningToggle.setValueCallback = { value in
            self.delegate?.didToggleLaunchWithLastTuning(value == 1 ? true : false)
        }
    }

    func updateChannelLabel() {
        if isOmniMode || userChannelIn == 0 {
            self.channelLabel.text = "MIDI Channel In: Omni"
        } else {
            self.channelLabel.text = "MIDI Channel In: \(userChannelIn)"
        }
    }

    // MARK: - Actions
    
    @IBAction func bufferSizeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            conductor.updateDisplayLabel("Buffer Size: 32")
            AKSettings.bufferLength = .shortest
        case 1:
            conductor.updateDisplayLabel("Buffer Size: 64")
            AKSettings.bufferLength = .veryShort
        case 2:
            conductor.updateDisplayLabel("Buffer Size: 128")
            AKSettings.bufferLength = .short
        case 3:
            conductor.updateDisplayLabel("Buffer Size: 256")
            AKSettings.bufferLength = .medium
        case 4:
            conductor.updateDisplayLabel("Buffer Size: 512")
            AKSettings.bufferLength = .long
        case 5:
            self.conductor.updateDisplayLabel("Buffer Size: 1024")
            AKSettings.bufferLength = .veryLong
        default:
            break
        }
        do {
            try AKTry {
                try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(AKSettings.bufferLength.duration)
            }
        } catch let error as NSError {
            AKLog("AKSettings Error: Cannot set Preferred IOBufferDuration to " +
                "\(AKSettings.bufferLength.duration) ( = \(AKSettings.bufferLength.samplesCount) samples)")
            AKLog("AKSettings Error: \(error))")
        }
        
        // Save Settings
        delegate?.didSetBuffer()
    }

    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    private func updateVelocitySensitivityKnob() {
        let animationDuration = 0.5
        if let setting = delegate?.velocitySensitiveMIDISettingValue() {
            if setting == true {
                velocitySensitivityKnob.isUserInteractionEnabled = true
                UIView.animate(withDuration: animationDuration, animations: {
                    self.velocitySensitivityKnob.alpha = 1
                })
            } else {
                velocitySensitivityKnob.isUserInteractionEnabled = false
                UIView.animate(withDuration: animationDuration, animations: {
                    self.velocitySensitivityKnob.alpha = 0
                })
            }
        }
    }
}

// MARK: - TableViewDataSource

extension MIDISettingsViewController: UITableViewDataSource {

    func numberOfSections(in categoryTableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if midiSources.isEmpty {
            return 0
        } else {
            return midiSources.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MIDICell") as? MIDICell {
            let midiInput = midiSources[indexPath.row]
            cell.configureCell(midiInput: midiInput)
            return cell
        } else {
            return MIDICell()
        }
    }
}

// MARK: - TableViewDelegate

extension MIDISettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? MIDICell
        guard let midiInput = cell?.currentInput else { return }

        // Toggle Cell
        midiInput.isOpen = !midiInput.isOpen
        inputTable.reloadData()

        // Open / Close MIDI Input
        if midiInput.isOpen {
            AKManager.midi.openInput(name: midiInput.name)
        } else {
            AKManager.midi.closeInput(name: midiInput.name)
        }
        delegate?.didChangeMIDISources(midiSources)
    }

}
