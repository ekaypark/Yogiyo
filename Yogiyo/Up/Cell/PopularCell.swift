

import UIKit
import Alamofire
import AlamofireImage
import Foundation

protocol MyCellDelegate {
    func cellWasPressed()
}
class PopularCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    final let url = URL(string: "https://jogiyo.co.kr/restaurants/api/restaurant/?ordering=-review_avg")
    
    var delegate: MyCellDelegate?
    var delegate2: SendDataDelegate?
    lazy var restaurantData: [FoodlistElement] = {
        var restaurants = [FoodlistElement]()
        return restaurants
    }()
    
    
    var restList: [FoodlistElement] = []
    
   
    var cellLabel: UILabel!
    
    var images: [String]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var titleLabel: [String]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 30
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
        
    }()
    
    let cellId = "cellId"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        //        downloadJSON()
        testJSON()
        //        getData()
    }
    
    
    func testJSON() {
        guard let url = URL(string: "https://jogiyo.co.kr/restaurants/api/restaurant/?ordering=-review_avg") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
                
                for dic in jsonArray{
                    guard let name = dic["name"] as? String else { return }
                    print(name)
                }
                
                
                let decoder = JSONDecoder()
                let result = try decoder.decode(Foodlist.self, from:
                    dataResponse)
                self.restaurantData = result
                let arraySlice = self.restaurantData[..<5]
                //            let restList = Array(arraySlice)
                self.restList = Array(arraySlice)
                print(self.restList.count)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } catch let parsingError {
                print("Error here", parsingError)
            }
        }
        task.resume()
        
        
    }
    
    
    
    func setup() {
        let label = UILabel(frame: CGRect(x:0, y:0, width:150,height: 50))
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        
        label.textAlignment = .left
        label.addTextWithImage(text: "인기맛집!", image: UIImage(named: "yogiyo")!, imageBehindText: false, keepPreviousText: true)
        addSubview(label)
        addSubview(collectionView)
        label.setAnchor(top: topAnchor, left: leftAnchor, bottom: collectionView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 40, paddingRight: 0)
        collectionView.setAnchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 50, paddingLeft: 10, paddingBottom: 0, paddingRight: 0)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(IconsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.showsHorizontalScrollIndicator = false
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return restList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! IconsCell
        
        
        var labelName = UILabel(frame: CGRect(x:0, y:14.0, width:100.0, height:30.0))
        labelName.text = restList[indexPath.row].name
        cell.contentView.addSubview(labelName)
        cell.id = restList[indexPath.row].id
        let url = restList[indexPath.row].logoURL ?? ""
        Alamofire.request(url).responseImage { response in
            switch response.result {
            case .success(_): if let image = response.result.value {
                let img = image
                
                //                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                cell.imageView.image = img
                cell.imageView.clipsToBounds = true
                cell.imageView.contentMode = .scaleAspectFit
                //                            }
                
                }
            case .failure(let err) : print("에러: \(err)")
            }
            //            let data = try? Data(contentsOf: imageURL) {
            //
            //            DispatchQueue.global().async {
            //                let data = try? Data(contentsOf: imageURL)
            //                if let data = data {
            //                    let image = UIImage(data: data)
            //                    DispatchQueue.main.async {
            //                        cell.imageView.image = image
            //                    }
            //                }
            //            }
            
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? IconsCell
        SettingData.shared.resturantId = cell?.id
         self.delegate?.cellWasPressed()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private class IconsCell: UICollectionViewCell {
        
        let imageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            iv.clipsToBounds = true
            return iv
        }()
        
        var id = 0
        let textView = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
            
        }
        
        func setup() {
            addSubview(imageView)
            imageView.setAnchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
            
        }
        
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    
    
}
