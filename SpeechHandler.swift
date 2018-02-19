//
//  SpeechHandler.swift
//  RegDocScan
//
//  Created by Barry Bryant on 2/15/18.
//  Copyright © 2018 IQVIA, Inc. All rights reserved.
//

import Foundation
import Speech

enum SpeechHandlerError: LocalizedError {
    case audioSessionInitializationError
    case audioEngineError
}

protocol SpeechHandlerDelegate: class {
    func onUtterance(_ utterance: String)
    func onFinalUtterace(_ utterance: String)
    func onError(_ error: Error)
}

final class SpeechHandler: NSObject, SFSpeechRecognitionTaskDelegate {
    
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    fileprivate var request: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    fileprivate var timer: Timer?
    fileprivate var utteranceTimeout: Int
    
    public weak var delegate: SpeechHandlerDelegate?
    
    public init(utteranceTimeout: Int = 2) {
        self.utteranceTimeout = utteranceTimeout
    }
    
    public func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            delegate?.onError(SpeechHandlerError.audioSessionInitializationError)
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        
        let node = audioEngine.inputNode
        guard let request = request else { return }
        request.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: request, delegate: self)
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            delegate?.onError(SpeechHandlerError.audioEngineError)
        }
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        self.restartTimer()
        let resultText = transcription.formattedString
        delegate?.onUtterance(resultText)
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        delegate?.onFinalUtterace(recognitionResult.bestTranscription.formattedString)
    }
    
    func restartTimer() {
        if let timer = timer { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(didFinishTalking), userInfo: nil, repeats: false)
    }
    
    @objc func didFinishTalking() {
        timer?.invalidate()
        if audioEngine.isRunning {
            audioEngine.stop()
            request?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)
            request = nil
            recognitionTask = nil
        }
    }
    
}

