//
//  SystemSoundPlayer.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/26.
//

import AVFoundation

public class SystemSoundPlayer {
    
    func play(systemSoundID: UInt32) {
        var soundIdRing: SystemSoundID = systemSoundID
        if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil) {
            AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
            AudioServicesPlaySystemSound(soundIdRing)
        }
    }
    
    func play(systemSound: SystemSound) {
        self.play(systemSoundID: systemSound.systemSoundID)
    }
}
