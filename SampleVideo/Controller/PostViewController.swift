//
//  PostViewController.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/15.
//

import UIKit
import Photos

class PostViewController: UIViewController {
    
    var finishedURL: URL?
    
    private var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackButton()
    }
    
    private func setBackButton() {
        
        self.backButton = UIButton(frame: CGRect(x: 20.0, y: 40.0, width: 50.0, height: 50.0))
        self.backButton.backgroundColor = .blue
        self.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    @IBAction func save(_ sender: Any) {
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.finishedURL!)
        } completionHandler: { (result, error) in
            
            if error != nil {
                
                print(error.debugDescription)
                return
            } else if result {
                
                //アラートを出す
                let alert: UIAlertController = UIAlertController(title: "保存しました。", message: "", preferredStyle:  .alert)
                let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func share(_ sender: Any) {
        
        //動画をシェア
        //        let activityItems = [outputFileURL as Any, "#SampleVideo"] as [Any]
        //        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        //
        //        activityController.popoverPresentationController?.sourceView = self.view
        //        activityController.popoverPresentationController?.sourceRect = self.view.frame
        //        self.present(activityController, animated: true, completion: nil)
        
        //アラートを出す
        let alert: UIAlertController = UIAlertController(title: "シェアしました。", message: "", preferredStyle:  .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func back(){
        
        self.dismiss(animated: true, completion: nil)
    }
}
