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
        
        self.view.backgroundColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        videoPlayer(url: url!)
    }
    
    func videoPlayer(url: URL) {
        //ViewControllerを親から取り除く
        playerController?.removeFromParent()
        player = nil
        player = AVPlayer(url: url)
        self.player?.volume = 1
        view.backgroundColor = .black
        
        playerController = AVPlayerViewController()
        playerController?.videoGravity = .resizeAspectFill
        playerController?.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 100)
        playerController?.showsPlaybackControls = false
        playerController?.player = player!
        self.addChild(playerController!)
        self.view.addSubview((playerController?.view)!)
        
        player?.play()
        
        _ = NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
                    queue: .main) { [weak playerController] _ in
            playerController?.player?.seek(to: CMTime.zero)
            playerController?.player?.play()
                }
    }
    
    @IBAction func next(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        //        videoURL = url
        //        previewViewController.url = videoURL
        self.present(postViewController, animated: true, completion: nil)
    }
}
