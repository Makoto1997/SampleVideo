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
    var videoURL: URL?
    
    private var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        videoPlayer(videoURL: videoURL!)
    }
    
    private func videoPlayer(videoURL: URL) {
        //ViewControllerを親から取り除く
        playerController?.removeFromParent()
        player = nil
        player = AVPlayer(url: videoURL)
        self.player?.volume = 1
        
        playerController = AVPlayerViewController()
        playerController?.videoGravity = .resizeAspectFill
        playerController?.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 85)
        //再生コントロールをコンテンツ上に表示
        playerController?.showsPlaybackControls = false
        playerController?.player = player!
        self.addChild(playerController!)
        self.view.addSubview((playerController?.view)!)
        self.setBackButton()
        player?.play()
        //
        _ = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak playerController] _ in
            playerController?.player?.seek(to: CMTime.zero)
            playerController?.player?.play()
        }
    }
    
    private func setBackButton() {
        
        self.backButton = UIButton(frame: CGRect(x: 20.0, y: 40.0, width: 50.0, height: 50.0))
        self.backButton.backgroundColor = .blue
        self.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    @IBAction func next(_ sender: Any) {
        
        player?.pause()
        
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        postViewController.finishedURL = videoURL
        self.present(postViewController, animated: true, completion: nil)
    }
    
    @objc func back(){
        
        self.dismiss(animated: true, completion: nil)
    }
}
