//
//  ViewController.swift
//  Project
//
//  Created by ketis on 2017. 1. 11..
//  Copyright © 2017년 ketis. All rights reserved.
//

import UIKit
import SystemConfiguration

// PUSIK
#if DEBUG
    public let urlstring:String = "http://energy.openlab.kr:3003"
#else
    public let urlstring:String = "http://energy.openlab.kr:3001"
#endif

public var locationarray = [Int]()
public var Trainarray_first = [Int]()
public var Trainarray = [String:Int]()
public var arrival = [String]()
public var workarray = [String:Int]()
public var avg_temp = [String:Int]()
public var avg_hum = [String:Int]()
public var setting_num:Int = 0
public let translocation: [Int:String]=[100:"녹동", 101:"소태", 102:"학동증심사입구", 103:"남광주", 104:"문화전당", 105:"금남로4가", 106:"금남로5가", 107:"양동시장", 108:"돌고개", 109:"농성", 110:"화정", 111:"쌍촌", 112:"운천", 113:"상무", 114:"김대중컨벤션센터", 115:"공항", 116:"송정공원", 117:"광주송정역", 118:"도산", 119:"평동"]

public var select_trainnum:String = " "
public var make_num=[String]()   // 선택한 기차의 차량들 만드는 배열
public var make_train_temparray=[String:Int]()
public var make_train_humarray=[String:Int]()
public var Errormsg_internet:String = "인터넷이 연결되어 있지 않습니다."

// 인터넷 연결 확인하는 함수
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

class ViewController: UIViewController
{
    // 설정 버튼 동작
    @IBAction func Settingbt(_ sender: Any) {
        if setting_num == 0 {
            let dialog = UIAlertController(title:"Message", message: "\n" + "SMS민원 보내기 기능이 설정되었습니다.", preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog.addAction(action)
            self.present(dialog, animated:true, completion: nil)
            setting_num = 1
        }
        else{
            let dialog = UIAlertController(title:"Message", message: "\n" + "SMS민원 보내기 기능이 해제되었습니다.", preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog.addAction(action)
            self.present(dialog, animated:true, completion: nil)
            setting_num = 0
        }
    }
    // 제작사 버튼 동작
    @IBAction func make_bt(_ sender: Any) {
        let dialog = UIAlertController(title:"만든기관 : 전자부품연구원", message: "\n" + "개발자 : 박부식, 김동학" + "\n\n" + "열차정보: " + urlstring, preferredStyle:.alert)
        let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
        dialog.addAction(action)
        self.present(dialog, animated:true, completion: nil)
    }
    // 계속하기 버튼 동작
    @IBAction func continue_bt(_ sender: Any) {
        if(isInternetAvailable() == true){
//            self.performSegue(withIdentifier: "detailpage", sender: AnyObject.self)
        }
        else{
            let dialog = UIAlertController(title: "Error Message", message: "\n" + Errormsg_internet, preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog.addAction(action)
            present(dialog, animated:true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dialog = UIAlertController(title: "Message", message: "\n" + "1. 이 앱은 광주광역시 지하철1호선 정보를 제공합니다.\n\n2. 이 앱의 열차 정보는 실제와 차이가 있을 수도 있으니 참조용으로만 사용하시기 바랍니다.\n\n3. 정확한 정보는 플랫폼 내 정보표시창을 이용해주시기 바랍니다.", preferredStyle:.alert)
        
        let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
        dialog.addAction(action)
        present(dialog, animated:true, completion: nil)
        if(isInternetAvailable() == true){
            self.ParsingJsonURL()
        }
        else{
            let dialog = UIAlertController(title: "Error Message", message: "\n" + Errormsg_internet, preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog.addAction(action)
            present(dialog, animated:true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func ParsingJsonURL(){
        let url = NSURL(string: urlstring)
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data,response,error)->Void in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary{
                if let areaarray = jsonObj!.value(forKey: "subway") as? NSArray{
                    for area in areaarray{
                        if let areaDict = area as? NSDictionary{
                            if let location = areaDict.value(forKey:"Location"),
                                let train = areaDict.value(forKey:"Train"),
                                let work = areaDict.value(forKey: "work"),
                                let avg_temp1 = areaDict.value(forKey: "T1TEMP"),
                                let avg_hum1 = areaDict.value(forKey: "T1HUM")
                                {
                                    locationarray.append(location as! Int)
                                    Trainarray_first.append(train as! Int)
                                    Trainarray[translocation[location as! Int]!] = train as? Int
                                    workarray[translocation[location as! Int]!] = work as? Int
                                    arrival.append(translocation[location as! Int]!)
                                    avg_temp[translocation[location as! Int]!] = (avg_temp1 as! Int)
                                    avg_hum[translocation[location as! Int]!] = (avg_hum1 as! Int)
                            }
                        }
                    }
                }
            }
            
        }).resume()
    }
}

