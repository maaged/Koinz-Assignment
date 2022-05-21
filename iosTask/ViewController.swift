//
//  ViewController.swift
//  iosTask
//
//  Created by Maged on 18/05/2022.
//

import UIKit
import Alamofire
import Foundation
import Kingfisher
class ViewController: UIViewController {
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var imgsTV: UITableView!
    var photo : [Photo] = []
    var pageNum = 1
    var currentpage = 1
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imgsTV.register(UINib(nibName: "mainCell", bundle: nil), forCellReuseIdentifier: "mainCell")
        imgsTV.register(UINib(nibName: "AdBannerCell", bundle: nil), forCellReuseIdentifier: "AdBannerCell")
        imgsTV.dataSource = self
        imgsTV.delegate = self
        self.loader.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.loadDate(page: pageNum)
    }
    
   
    
    
}
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photo.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let current = photo[indexPath.row]
        let vc = fullscreenVC(nibName: "fullscreenVC", bundle: nil)
        
        
            let imagePath = "https://farm" + "\(current.farm ?? 0 )" + ".staticflickr.com/" + "\(current.server ?? "0")" + "/" + "\(current.id ?? "0")" + "_" + "\(current.secret ?? "0")" + ".jpg"
            vc.path = imagePath
//        }
       
        
        self.navigationController?.present(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let current = photo[indexPath.row]
        if current.isHasAd == true {
            let Cell = imgsTV.dequeueReusableCell(withIdentifier: "AdBannerCell", for: indexPath) as! AdBannerCell
            if checkfileExit(fileName:"\(current.id ?? "0")" ){
                Cell.photoIV.image = self.getImage(fileName:"\(current.id ?? "0")" )
            }else{
                let imagePath = "https://farm" + "\(current.farm ?? 0 )" + ".staticflickr.com/" + "\(current.server ?? "0")" + "/" + "\(current.id ?? "0")" + "_" + "\(current.secret ?? "0")" + ".jpg"
                Cell.photoIV?.image = UIImage(data: NSData(contentsOf:NSURL(string: imagePath)! as URL)! as Data)
                self.saveToDocuments(filename:"\(current.id ?? "0")" , img: Cell.photoIV?.image ?? UIImage())
            }
            return Cell
        }else{
            let Cell = imgsTV.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! mainCell
            if checkfileExit(fileName:"\(current.id ?? "0")" ){
                Cell.photoIV.image = self.getImage(fileName:"\(current.id ?? "0")" )
            }else{
                let imagePath = "https://farm" + "\(current.farm ?? 0 )" + ".staticflickr.com/" + "\(current.server ?? "0")" + "/" + "\(current.id ?? "0")" + "_" + "\(current.secret ?? "0")" + ".jpg"
                Cell.photoIV?.image = UIImage(data: NSData(contentsOf:NSURL(string: imagePath)! as URL)! as Data)
                self.saveToDocuments(filename:"\(current.id ?? "0")" , img: Cell.photoIV?.image ?? UIImage())
            }
            return Cell
        }
    }
}
extension ViewController{
    
    func loadDate(page:Int)  {
        self.loader.isHidden = false
        self.imgsTV.isHidden = true
        self.loader.startAnimating()
        AF.request("https://www.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=50&text=Color&per_page=10&api_key=d17378e37e555ebef55ab86c4180e8dc", method: .get, parameters: ["page":page], encoding: URLEncoding.default, headers: nil)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    do {
                        
                        let response = try ApiResponse<FlickrModel>(data: response.data)
                        if self.currentpage == 1 {
                            self.photo = (response.entity.photos?.photo)!
                        }else{
                            for item in response.entity.photos?.photo ?? [] {
                                self.photo.append(item)
                            }
                        }
                        for (index, _) in self.photo.enumerated() {
                            if index % 5 == 0  && index != 0{
                                self.photo[index].isHasAd = true
                            }else{
                                self.photo[index].isHasAd = false
                            }
                        }
                        
                        self.currentpage = response.entity.photos?.page ?? 0
                        self.loader.stopAnimating()
                        self.loader.isHidden = true
                        self.imgsTV.isHidden = false
                        self.imgsTV.reloadData()
                        
                    } catch { // Parsing Error
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                    self.imgsTV.isHidden = false
                }
            })
        self.loader.stopAnimating()
        self.loader.isHidden = true
        self.imgsTV.isHidden = false
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        let offsetY = imgsTV.contentOffset.y
        let contentHeight = imgsTV.contentSize.height
        
        if (offsetY > contentHeight - imgsTV.frame.height * 10){
            if let lastVisibleIndexPath = imgsTV.indexPathsForVisibleRows?.last {
                let rowNumber : Int = lastVisibleIndexPath.row
                
                if (photo.count - 1 ) == rowNumber {
                    if self.currentpage == pageNum{
                        pageNum += 1
                        self.loadDate(page: pageNum)
                    }
                    
                }
                
            }
            
        }
        
    }
    func checkfileExit(fileName:String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                return true
            } else {
                print("FILE NOT AVAILABLE")
                return false
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
            return false
        }
    }
    func saveToDocuments(filename:String,img:UIImage) {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            if let data = img.jpegData(compressionQuality:  1),
               !FileManager.default.fileExists(atPath: fileURL.path) {
                try data.write(to: fileURL)
                print("file saved")
            }
        } catch {
            print("error:", error)
        }
    }
    func getImage(fileName:String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let img    = UIImage(contentsOfFile: imageURL.path)
            return img ?? UIImage()
        }
        return UIImage()
        
    }
    
}

