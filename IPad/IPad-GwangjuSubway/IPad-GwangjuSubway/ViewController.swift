//
//  ViewController.swift
//  IPad-GwangjuSubway
//
//  Created by ketis on 2017. 8. 7..
//  Copyright © 2017년 ketis. All rights reserved.
//

import UIKit
import SystemConfiguration

public let urlstring:String = "varp://energy.openlab.kr:3003"
public var Train = [Int]()
public var compare_Train = [Int]()
public var train_temp = [String:Int]()
public var train_hum = [String:Int]()
public var train_1:String = ""
public var train_2:String = ""
public var train_3:String = ""
public var train_4:String = ""
public var complain:String = ""
public var str:String = ""
public var input_text:String = ""
public var server_message:String = ""
public var train:Int = 0
public var selected_train = ""
public var train_data = [""]
public var train_data2 = [""]
public var images = ["1","2","3","4","5"]
public var buttonCounter = [Int]()
public var timer:Timer?


//인터넷 연결 확인하는 함수
public func isInternetAvailable() -> Bool
{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}
public func SendtoServer(){
    if(str != "")
    {
        if (buttonCounter.count != 0){
            let dict = ["type":"100", "complaint": complain, "trainID":selected_train, "cur_temp":train_temp[str]!, "cur_hum":train_hum[str]!,"message":"test"] as [String : Any]
            print(dict)
            let url = NSURL(string: "http://energy.openlab.kr:4000")
            let session = URLSession.shared
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            //HTTP Headers
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(dataString!)
                server_message = dataString! as String
                
                guard let data = data else {
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                        print(json)
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
            })
            task.resume()
        }
    }
}
//main start
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UIPickerViewDelegate{
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerView2: UIPickerView!
    
    @IBOutlet weak var hum_label: UILabel!
    @IBOutlet weak var temp_label: UILabel!
    // Json파일 Parsing 하는 함수
    public func ParseJson(){
        if Train.count != 0 {
            print("Train 배열 : ")
            print(Train)
            if compare_Train.count != 0 {
                if compare_Train != Train {
                    temp_label.text = "0"
                    hum_label.text = "0"
                    refresh()
                }
                else {
                    compare_Train.removeAll()
                }
            }
            compare_Train = Train
        }
        Train.removeAll()
        train_temp.removeAll()
        train_hum.removeAll()
        if(isInternetAvailable() == true){
            let url = URL(string: "http://energy.openlab.kr:3003")
            URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    let subway = json["subway"] as? [[String: Any]] ?? []
                    for subways in subway{
                        Train.append(subways["Train"] as! Int)
                        train = subways["Train"] as! Int
                        train_1 = String(describing: train).substring(to: String(describing: train).index(after: String(describing: train).startIndex)) + "0" +
                            String(describing: train).substring(from: String(describing: train).index(after:String(describing: train).startIndex))
                        train_2 = String(describing: train).substring(to: String(describing: train).index(after: String(describing: train).startIndex)) + "1" +
                            String(describing: train).substring(from: String(describing: train).index(after:String(describing: train).startIndex))
                        train_3 = String(describing: train).substring(to: String(describing: train).index(after: String(describing: train).startIndex)) + "2" +
                            String(describing: train).substring(from: String(describing: train).index(after:String(describing: train).startIndex))
                        train_4 = String(describing: train).substring(to: String(describing: train).index(after: String(describing: train).startIndex)) + "7" +
                            String(describing: train).substring(from: String(describing: train).index(after:String(describing: train).startIndex))
                        train_temp[train_1] = (subways["T1TEMP"] as! Int )
                        train_temp[train_2] = (subways["T2TEMP"] as! Int )
                        train_temp[train_3] = (subways["T3TEMP"] as! Int )
                        train_temp[train_4] = (subways["T4TEMP"] as! Int )
                        train_hum[train_1] = (subways["T1HUM"] as! Int)
                        train_hum[train_2] = (subways["T2HUM"] as! Int)
                        train_hum[train_3] = (subways["T3HUM"] as! Int)
                        train_hum[train_4] = (subways["T4HUM"] as! Int)
                        
                    }
                } catch let error as NSError {
                    print(error)
                }
            }).resume()
        }
        else{
            print("Internet is not connected")
        }
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ParseJson), userInfo: nil, repeats: true)
        }
    }
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    func refresh(){
        train_data.removeAll()
        train_data2.removeAll()
        for i in 0...(Train.count-1) {
            train_data.append(String(Train[i]))
        }
        print(train_data)
        pickerView.reloadAllComponents()
        train_data2.append(String(describing: train_data[0]).substring(to: String(describing: train_data[0]).index(after: String(describing: train_data[0]).startIndex)) + "0" +
            String(describing: train_data[0]).substring(from: String(describing: train_data[0]).index(after:String(describing: train_data[0]).startIndex)))
        train_data2.append(String(describing: train_data[0]).substring(to: String(describing: train_data[0]).index(after: String(describing: train_data[0]).startIndex)) + "1" +
            String(describing: train_data[0]).substring(from: String(describing: train_data[0]).index(after:String(describing: train_data[0]).startIndex)))
        train_data2.append(String(describing: train_data[0]).substring(to: String(describing: train_data[0]).index(after: String(describing: train_data[0]).startIndex)) + "2" +
            String(describing: train_data[0]).substring(from: String(describing: train_data[0]).index(after:String(describing: train_data[0]).startIndex)))
        train_data2.append(String(describing: train_data[0]).substring(to: String(describing: train_data[0]).index(after: String(describing: train_data[0]).startIndex)) + "7" +
            String(describing: train_data[0]).substring(from: String(describing: train_data[0]).index(after:String(describing: train_data[0]).startIndex)))
        pickerView2.reloadAllComponents()
    }
    //pickerView2 data binding
    func make_trainnum(){
        train_data2.removeAll()
        train_data2.append(selected_train.substring(to: selected_train.index(after: selected_train.startIndex)) + "0" +
            selected_train.substring(from: selected_train.index(after:selected_train.startIndex)))
        train_data2.append(selected_train.substring(to: selected_train.index(after: selected_train.startIndex)) + "1" +
            selected_train.substring(from: selected_train.index(after:selected_train.startIndex)))
        train_data2.append(selected_train.substring(to: selected_train.index(after: selected_train.startIndex)) + "2" +
            selected_train.substring(from: selected_train.index(after:selected_train.startIndex)))
        train_data2.append(selected_train.substring(to: selected_train.index(after: selected_train.startIndex)) + "7" +
            selected_train.substring(from: selected_train.index(after:selected_train.startIndex)))
        pickerView2.reloadAllComponents()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ParseJson()
        startTimer()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.dataSource = self as? UIPickerViewDataSource
        self.pickerView2.delegate = self
        self.pickerView2.dataSource = self as? UIPickerViewDataSource
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        let dialog = UIAlertController(title: "Message", message: "Starting IPad App", preferredStyle:.alert)
        let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default){(result : UIAlertAction)-> Void in
            self.refresh()
        }
        dialog.addAction(action)
        present(dialog, animated:true, completion: nil)
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Image binding 과정
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Customcell", for: indexPath) as! SurveyCollectionViewCell
        cell.myImage.image = UIImage(named: images[indexPath.row])
        if buttonCounter.contains(indexPath.row){
            cell.myImage.layer.borderColor = UIColor.yellow.cgColor
            cell.myImage.layer.borderWidth = 3
        }
        else{
            cell.myImage.layer.borderColor = UIColor.clear.cgColor
            cell.myImage.layer.borderWidth = 0
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row) selected")
        buttonCounter.removeAll()
        buttonCounter.append(indexPath.row)
        switch(indexPath.row){
        case 0:
            complain = "bad"
            break
        case 1:
            complain = "not bad"
            break
        case 2:
            complain = "normal"
            break
        case 3:
            complain = "good"
            break
        case 4:
            complain = "very good"
            break
        default :
            complain = "normal"
            break
        }
        let dialog = UIAlertController(title: "Survey Message", message: complain, preferredStyle:.alert)
        let cancelact = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){(result: UIAlertAction)->Void in
            print("cancel")
        }
        let okact = UIAlertAction(title:"민원 보내기", style:UIAlertActionStyle.default){(result:UIAlertAction)->Void in
            SendtoServer()
            if(server_message != ""){
                let dialog1 = UIAlertController(title: "Message", message: server_message, preferredStyle:.alert)
                let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
                dialog1.addAction(action)
                self.present(dialog1, animated:true, completion: nil)
            }
        }
        dialog.addAction(cancelact)
        dialog.addAction(okact)
        self.present(dialog, animated:true, completion: nil)
        collectionView.reloadData()
        print(buttonCounter)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerView2{
            print("select pickerview2")
            str = train_data2[row]
            let dialog1 = UIAlertController(title: "차량 선택", message: "\(str)을 선택하셨습니다.", preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog1.addAction(action)
            self.present(dialog1, animated:true, completion: nil)
            for i in 0...(Train.count-1){
                if(String(Train[i]) == train_data[row]){
                    print(train_temp[str]!)
                    self.temp_label.text = "\(train_temp[str]!)"
                    self.hum_label.text = "\(train_hum[str]!)"
                    
                }
                else{
                }
            }
            
        }
        else{
            print("select pickerview1")
            selected_train = train_data[row]
            make_trainnum()
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil{
            label = UILabel()
        }
        var data = ""
        if pickerView == pickerView2{
            data = train_data2[row]
        }
        else{
            data = train_data[row]
        }
        let title = NSAttributedString(string: data, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerView2{
            return train_data2.count
        }
        else{
            return train_data.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerView2{
            return train_data2[row]
        }
        else{
            return train_data[row]
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

