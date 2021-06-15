//
//  PreviewViewController.swift
//  SampleVideo
//
//  Created by Makoto on 2021/06/15.
//

import UIKit
import AVKit

final class PreviewViewController: UIViewController {
    
    var playerController: AVPlayerViewController?
    var player: AVPlayer?
    var url:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func next(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        //        videoURL = url
        //        previewViewController.url = videoURL
        self.present(postViewController, animated: true, completion: nil)
    }
}
