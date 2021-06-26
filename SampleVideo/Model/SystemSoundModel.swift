//
//  SoundModel.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/26.
//

import AVFoundation

enum SystemSound: UInt32 {
    
    case startRecording = 1117
    case stopRecording = 1118
    
    var systemSoundID: SystemSoundID {
        self.rawValue as SystemSoundID
    }
}
