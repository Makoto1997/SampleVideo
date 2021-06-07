//
//  CameraViewController.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/05.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {
    
    // カメラやマイクの入力情報と、画像や動画、オーディオなどの出力データの管理を行うクラス
    var captureSession = AVCaptureSession()

    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?

    // 出力形式を管理
    var captureOutput = AVCaptureMovieFileOutput()

    // Capture Preview
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
    // ビデオの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }
    
    // デバイスの設定
    func setupDevice() {
        
        // カメラデバイスのプロパティ設定
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
            // プロパティの条件を満たしたカメラデバイスの取得
            let devices = deviceDiscoverySession.devices
        
        for device in devices {
                if device.position == AVCaptureDevice.Position.back {
                    mainCamera = device
                } else if device.position == AVCaptureDevice.Position.front {
                    innerCamera = device
                }
            }
            // 起動時のカメラを設定
            currentDevice = mainCamera
    }
}
