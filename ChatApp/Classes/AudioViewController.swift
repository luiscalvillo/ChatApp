//
//  AudioViewController.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/19/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import Foundation
import IQAudioRecorderController


class AudioViewController  {
    
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target: UIViewController) {
        
        let controller = IQAudioRecorderViewController()
        
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}
