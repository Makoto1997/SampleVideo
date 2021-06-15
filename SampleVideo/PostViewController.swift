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
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func share(_ sender: Any) {
        //アラートを出す
        let alert: UIAlertController = UIAlertController(title: "シェアしました。", message: "", preferredStyle:  .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
