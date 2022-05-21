//
//  fullscreenVC.swift
//  iosTask
//
//  Created by Maged on 21/05/2022.
//

import UIKit

class fullscreenVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var path = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(data: NSData(contentsOf:NSURL(string: path)! as URL)! as Data)
        // Do any additional setup after loading the view.
    }


    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
}
