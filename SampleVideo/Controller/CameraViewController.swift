//
//  CameraViewController.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/05.
//

import UIKit
import AVFoundation
import AudioToolbox

final class CameraViewController: UIViewController {
    
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    // 入力デバイスから出力へのデータの流れを管理するクラス
    private let captureSession = AVCaptureSession()
    // ビデオを表示するためのサブクラス
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    // 出力形式を管理
    let fileOutput = AVCaptureMovieFileOutput()
    // デバイスの初期化
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    //ビデオのURL
    var url: URL?
    
    private var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.setUpCamera()
    }
    
    // デバイスの設定
    private func setUpCamera() {
        
        // ビデオのインプット設定
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        // 音声のインプット設定
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)
        
        captureSession.addOutput(fileOutput)
        captureSession.startRunning()
        
        // ビデオ表示
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = CGRect(x: 0, y: 0, width: Int(view.bounds.width), height: Int(view.bounds.height - 85))
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        
        //最大録画時間
        fileOutput.maxRecordedDuration = CMTimeMake(value: 15, timescale: 1)
        
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
            self.albumButton.isHidden = false
            self.flashButton.isHidden = false
            self.changeCameraButton.isHidden = false
            //録画終了サウンド
            let systemSoundPlayer = SystemSoundPlayer()
            systemSoundPlayer.play(systemSound: .stopRecording)
        } else {
            // 録画開始
            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mov")
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
            self.recordButton.backgroundColor = .red
            self.albumButton.isHidden = true
            self.flashButton.isHidden = true
            self.changeCameraButton.isHidden = true
            //録画開始サウンド
            let systemSoundPlayer = SystemSoundPlayer()
            systemSoundPlayer.play(systemSound: .startRecording)
        }
    }
    
    func flashSwitch() {
        // LED点灯・消灯
        guard let device = videoDevice else { return }
        
        if device.hasTorch {
            let torchOn = !device.isTorchActive
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            device.torchMode = torchOn ? .on : .off
            device.unlockForConfiguration()
        }
    }
    
    @IBAction func openAlbum(_ sender: Any) {
        
        album()
    }
    
    @IBAction func flash(_ sender: Any) {
        
        flashSwitch()
    }
    
    @IBAction func changeCamera(_ sender: Any) {
        
        
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        let storyboard = UIStoryboard(name: "Preview", bundle: nil)
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        url = outputFileURL
        previewViewController.videoURL = url
        self.present(previewViewController, animated: true, completion: nil)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func album() {
        //動画のみが閲覧できるアルバムを起動。
        let imagePickerController = UIImagePickerController()
        //デリゲートを指定する。
        imagePickerController.delegate = self
        //タイプはアルバム。
        imagePickerController.sourceType = .savedPhotosAlbum
        //動画だけを抽出。
        imagePickerController.mediaTypes = ["public.movie"]
        //編集不可にする。
        imagePickerController.allowsEditing = false
        //インスタンスを出力。
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //アルバムを閉じる。
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaURL = info[.mediaURL] as? URL
        url = mediaURL
        
        picker.dismiss(animated: true, completion: nil)
        
        //値を渡しながら画面遷移。
        let storyboard = UIStoryboard(name: "Preview", bundle: nil)
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        previewViewController.videoURL = url
        self.present(previewViewController, animated: true, completion: nil)
    }
}
