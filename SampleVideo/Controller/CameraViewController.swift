//
//  CameraViewController.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/05.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {
    
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    
    var videoDevice: AVCaptureDevice?
    let fileOutput = AVCaptureMovieFileOutput()
    private var baseZoomFanctor: CGFloat = 1.0
    var url: URL?
    
    private var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.setUpCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = true
    }
    
    // デバイスの設定
    private func setUpCamera() {
        
        // 入力デバイスから出力へのデータの流れを管理するクラス
        let captureSession = AVCaptureSession()
        self.videoDevice = self.defaultCamera()
        let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)
        
        // ビデオのインプット設定
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        // 音声のインプット設定
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)
        
        captureSession.addOutput(fileOutput)
        
        //最大録画時間
        fileOutput.maxRecordedDuration = CMTimeMake(value: 15, timescale: 1)
        //手ぶれ補正
        if(fileOutput.connection(with: AVMediaType.video)?.isVideoStabilizationSupported)! {
            if #available(iOS 13.0, *) {
                // iOS13以降だと「cinematicExtended」というさらなる手ブレ補正モードが存在する
                fileOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.cinematicExtended
            } else {
                // そうでなければ「cinematic」モードを指定する
                fileOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.cinematic
            }
        }
        
        //ビデオ品質
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = .hd4K3840x2160
        } else if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        }
        captureSession.commitConfiguration()
        
        captureSession.startRunning()
        
        // ビデオ表示
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = CGRect(x: 0, y: 0, width: Int(view.bounds.width), height: Int(view.bounds.height - 85))
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        self.setupGestureRecognizer()
        
        // 録画ボタン
        self.recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        self.recordButton.backgroundColor = .white
        self.recordButton.layer.masksToBounds = true
        self.recordButton.layer.cornerRadius = 80 / 2
        self.recordButton.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height - 150)
        self.recordButton.addTarget(self, action: #selector(self.tappedRecordButton(sender:)), for: .touchUpInside)
        self.view.addSubview(recordButton)
    }
    
    func defaultCamera() -> AVCaptureDevice? {
        
        if let device = AVCaptureDevice.default(.builtInTripleCamera, for: AVMediaType.video, position: .back) {
            
            return device
        } else if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
            
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            
            return device
        } else {
            
            return nil
        }
    }
    
    private func setupGestureRecognizer() {
        // フォーカス用のタップジェスチャー
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        // ズーム用のピンチイン・ピンチアウトジェスチャー
        let pinchGestureRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture(_:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
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
    
    @objc private func tapGesture(_ sender: UITapGestureRecognizer) {
        
        do {
            try videoDevice?.lockForConfiguration()
            videoDevice?.focusMode = AVCaptureDevice.FocusMode.autoFocus
            videoDevice?.unlockForConfiguration()
        }
        catch {
            print("error")
        }
    }
    
    @objc private func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        //scaleにてピンチジェスチャー開始時を基準とした拡縮倍率
        //baseZoomFanctorにピンチジェスチャー開始時の拡縮倍率を格納
        if sender.state == .began {
            self.baseZoomFanctor = (self.videoDevice?.videoZoomFactor)!
        }
        //基準の拡縮倍率とジェスチャーによる拡縮倍率をかけ合わせ、新しい拡縮倍率を計算(tempZoomFactor)
        let tempZoomFactor: CGFloat = self.baseZoomFanctor * sender.scale
        //拡縮倍率の下限と上限の範囲内に収まるように調整する(newZoomFactdor)
        let newZoomFactdor: CGFloat
        if tempZoomFactor < (self.videoDevice?.minAvailableVideoZoomFactor)! {
            newZoomFactdor = (self.videoDevice?.minAvailableVideoZoomFactor)!
        } else if (self.videoDevice?.maxAvailableVideoZoomFactor)! < tempZoomFactor {
            newZoomFactdor = (self.videoDevice?.maxAvailableVideoZoomFactor)!
        } else {
            newZoomFactdor = tempZoomFactor
        }
        //newZoomFactdorを新たな拡縮倍率として、ズーム処理を行う
        do {
            try self.videoDevice?.lockForConfiguration()
            self.videoDevice?.ramp(toVideoZoomFactor: newZoomFactdor, withRate: 30.0)
            self.videoDevice?.unlockForConfiguration()
        } catch {
            print("ズーム率の変更に失敗しました。")
        }
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
