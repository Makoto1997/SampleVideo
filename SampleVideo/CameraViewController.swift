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
    private let captureSession = AVCaptureSession()
    // 出力形式を管理
    let fileOutput = AVCaptureMovieFileOutput()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // Capture Preview
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var recordButton: UIButton!
    
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.setUpCamera()
    }
    
    // デバイスの設定
    private func setUpCamera() {
        
        // デバイスの初期化・ビデオのインプット設定
        let videoDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        // デバイスの初期化・音声のインプット設定
        let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)
        
        captureSession.addOutput(fileOutput)
        captureSession.startRunning()
        
        // ビデオ表示
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = CGRect(x: 0, y: 0, width: Int(view.bounds.width), height: Int(view.bounds.height - 85))
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        
        // 録画ボタン
        self.recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        self.recordButton.backgroundColor = .white
        self.recordButton.layer.masksToBounds = true
        self.recordButton.layer.cornerRadius = 80 / 2
        self.recordButton.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height - 150)
        self.recordButton.addTarget(self, action: #selector(self.tappedRecordButton(sender:)), for: .touchUpInside)
        self.view.addSubview(recordButton)
    }
    
    @objc func tappedRecordButton(sender: UIButton) {
        
        if self.fileOutput.isRecording {
            // 録画終了
            fileOutput.stopRecording()
            
            self.recordButton.backgroundColor = .white
        } else {
            // 録画開始
            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mov")
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
            
            self.recordButton.backgroundColor = .red
        }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        let storyboard = UIStoryboard(name: "Preview", bundle: nil)
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        videoURL = outputFileURL
        previewViewController.url = videoURL
        self.present(previewViewController, animated: true, completion: nil)
    }
}
