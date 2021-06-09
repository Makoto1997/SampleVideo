//
//  CameraViewController.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/05.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {
    
    // 入力デバイスから出力へのデータの流れを管理するクラス
    // セッションのインスタンス化
    var captureSession = AVCaptureSession()
    
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    
    // 出力形式を管理
    var fileOutput = AVCaptureMovieFileOutput()
    
    // Capture Preview
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
    var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.setUpCamera()
    }
    
    // ビデオの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }

    // デバイスの設定
    func setUpCamera() {

        // デバイスの初期化
        let videoDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
        let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)

        // video input setting
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)

        // audio input setting
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)

        captureSession.addOutput(fileOutput)

        captureSession.startRunning()
        
        // video preview layer
                let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoLayer.frame = self.view.bounds
                videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.view.layer.addSublayer(videoLayer)

                // recording button
                self.recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
                self.recordButton.backgroundColor = .white
                self.recordButton.layer.masksToBounds = true
                self.recordButton.layer.cornerRadius = 80 / 2
                self.recordButton.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height - 120)
                self.recordButton.addTarget(self, action: #selector(self.onClickRecordButton(sender:)), for: .touchUpInside)
                self.view.addSubview(recordButton)
    }

    @objc func onClickRecordButton(sender: UIButton) {
            if self.fileOutput.isRecording {
                // stop recording
                fileOutput.stopRecording()

                self.recordButton.backgroundColor = .white
            } else {
                // start recording
                let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
                let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mov")
                fileOutput.startRecording(to: fileURL, recordingDelegate: self)

                self.recordButton.backgroundColor = .red
            }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        //アラートを出す
        let alert: UIAlertController = UIAlertController(title: "Recorded!", message: outputFileURL.absoluteString, preferredStyle:  .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
