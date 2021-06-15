//
//  PostViewController.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/15.
//

import UIKit

class PostViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
}
