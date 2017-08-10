//
//  TableViewController.swift
//  Project
//
//  Created by ketis on 2017. 6. 28..
//  Copyright © 2017년 ketis. All rights reserved.
//

import UIKit
public var return_value:Int = 0
public struct cellData{
    var cell:Int!
    var text_up_detail : String!
    var text_down_detail : String!
    var station_name : String!
    var image1:UIImage!
    var image2:UIImage!
    var id:Int!
}
public var mv_locationarray = [Int]()
public var mv_Trainarray = [String:Int]()
public var mv_arrival = [String]()
public var mv_workarray = [String:Int]()
public var mv_avg_temp = [String:Int]()
public var mv_avg_hum = [String:Int]()

public var trainnum:Int = 0
public var arrayofcelldata = [cellData]()

class TableViewController: UITableViewController {
    var station_name = ["녹동","소태","학동증심사입구","남광주","문화전당","금남로4가", "금남로5가","양동시장","돌고개", "농성","화정","쌍촌","운천","상무","김대중컨벤션센터","공항","송정공원","광주송정역","도산","평동"]       //1호선 배열 20개 항목
    override func viewDidLoad() {
        making_cell()
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        if(isInternetAvailable() == true){
            self.init_cell()
            self.ParsingJsonURL()
        }
        else{
            let dialog = UIAlertController(title: "Error Message", message: "\n" + Errormsg_internet, preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog.addAction(action)
            present(dialog, animated:true, completion: nil)
        }
        print("<<<<< Finish Main")
    }
    
    // 각각 테이블 셀 초기화 함수
    func making_cell(){
        arrayofcelldata.removeAll()
        arrayofcelldata=[cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil, image1:#imageLiteral(resourceName: "sta010"),image2:#imageLiteral(resourceName: "sta010"),id:100),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:101),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:102),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:103),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:104),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:105),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:106),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:107),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:108),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:109),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:110),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:111),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:112),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:113),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:114),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:115),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:116),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:117),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta020"),image2:#imageLiteral(resourceName: "sta020"),id:118),
                         cellData(cell:2, text_up_detail:"", text_down_detail:"",station_name:nil,image1:#imageLiteral(resourceName: "sta030"),image2:#imageLiteral(resourceName: "sta030"),id:119)]
        for i in 0...(arrayofcelldata.count-1){
            arrayofcelldata[i].station_name = station_name[i]
        }
    }
    
    // 초기 받아온 값을 토대로 테이블 뷰에 설정하는 함수
    func init_cell(){
        //중간 라벨에 역 이름 설정
        if(!arrival.isEmpty) {
            for i in 0...(arrayofcelldata.count-1){
                for j in 0...(arrival.count-1){
                    if(arrival[j] == arrayofcelldata[i].station_name)
                    {
                        if(workarray[arrival[j]] == 1){
                            arrayofcelldata[i].cell = 1
                            if(avg_temp[arrival[j]]! != 0){
                                arrayofcelldata[i].text_up_detail = "[ \(avg_temp[arrival[j]]!)℃ / \(avg_hum[arrival[j]]!)% ]"
                            }
                            switch(arrayofcelldata[i].station_name){
                            case "녹동":
                                arrayofcelldata[i].image1 = #imageLiteral(resourceName: "sta110")
                                break
                            case "평동":
                                arrayofcelldata[i].image1 = #imageLiteral(resourceName: "sta130")
                                break
                            default:
                                arrayofcelldata[i].image1 = #imageLiteral(resourceName: "sta120")
                                break
                            }
                        }
                        else if(workarray[arrival[j]] == 0){
                            arrayofcelldata[i].cell = 0
                            if(avg_temp[arrival[j]]! != 0){
                                arrayofcelldata[i].text_down_detail = "[ \(avg_temp[arrival[j]]!)℃ / \(avg_hum[arrival[j]]!)% ]"
                            }

                            switch(arrayofcelldata[i].station_name){
                            case "녹동":
                                arrayofcelldata[i].image2 = #imageLiteral(resourceName: "sta014")
                                break
                            case "평동":
                                arrayofcelldata[i].image2 = #imageLiteral(resourceName: "sta034")
                                break
                            default:
                                arrayofcelldata[i].image2 = #imageLiteral(resourceName: "sta024")
                                break
                            }
                        }
                        else{
                            arrayofcelldata[i].cell = 2
                            switch(arrayofcelldata[i].station_name){
                            case "녹동":
                                arrayofcelldata[i].image2 = #imageLiteral(resourceName: "sta014")
                                break
                            case "평동":
                                arrayofcelldata[i].image2 = #imageLiteral(resourceName: "sta034")
                                break
                            default:
                                arrayofcelldata[i].image2 = #imageLiteral(resourceName: "sta024")
                                break
                            }
                        }
                    }
                }
            }
        } else {//if(!arrival.isEmpty) {
            let dialog = UIAlertController(title: "알림", message: "\n" + "운행 중인 차량이 없습니다", preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog.addAction(action)
            present(dialog, animated:true, completion: nil)
        }
    }
    
    //Refreshing 기능
    func handleRefresh(_ refreshControl: UIRefreshControl)
    {
        if(isInternetAvailable()==true){
            mv_locationarray.removeAll()
            mv_Trainarray.removeAll()
            mv_workarray.removeAll()
            mv_arrival.removeAll()
            mv_avg_hum.removeAll()
            mv_avg_temp.removeAll()
            let url = NSURL(string: urlstring)
            URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data,response,error)->Void in
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary{
                    if let areaarray = jsonObj!.value(forKey: "subway") as? NSArray{
                        for area in areaarray{
                            if let areaDict = area as? NSDictionary{
                                if let location = areaDict.value(forKey:"Location"),
                                    let train = areaDict.value(forKey:"Train"),
                                    let T1TEMP = areaDict.value(forKey:"T1TEMP"),
                                    let T2TEMP = areaDict.value(forKey:"T2TEMP"),
                                    let T3TEMP = areaDict.value(forKey:"T3TEMP"),
                                    let T4TEMP = areaDict.value(forKey:"T4TEMP"),
                                    let T1HUM = areaDict.value(forKey:"T1HUM"),
                                    let T2HUM = areaDict.value(forKey:"T2HUM"),
                                    let T3HUM = areaDict.value(forKey:"T3HUM"),
                                    let T4HUM = areaDict.value(forKey:"T4HUM"),
                                    let work = areaDict.value(forKey: "work")
                                    {
                                        mv_locationarray.append(location as! Int)
                                        mv_Trainarray[translocation[location as! Int]!] = train as? Int
                                        mv_workarray[translocation[location as! Int]!] = work as? Int
                                        mv_arrival.append(translocation[location as! Int]!)
                                        mv_avg_temp[translocation[location as! Int]!] = (T1TEMP as! Int)
                                        mv_avg_hum[translocation[location as! Int]!] = (T1HUM as! Int)
                                
                                        make_train_temparray["\(train)-1"] = (T1TEMP as! Int)
                                        make_train_temparray["\(train)-2"] = (T2TEMP as! Int)
                                        make_train_temparray["\(train)-3"] = (T3TEMP as! Int)
                                        make_train_temparray["\(train)-4"] = (T4TEMP as! Int)
                                        make_train_humarray["\(train)-1"] = (T1HUM as! Int)
                                        make_train_humarray["\(train)-2"] = (T2HUM as! Int)
                                        make_train_humarray["\(train)-3"] = (T3HUM as! Int)
                                        make_train_humarray["\(train)-4"] = (T4HUM as! Int)
                                        arrival = mv_arrival
                                        locationarray = mv_locationarray
                                        Trainarray = mv_Trainarray
                                        workarray = mv_workarray
                                        avg_hum = mv_avg_hum
                                        avg_temp = mv_avg_temp
                                }
                            }
                        }
                    }
                }
            }).resume()
            self.making_cell()
            self.init_cell()
            print(arrival)
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
        else{
            let dialog = UIAlertController(title: "Error Message", message: "\n" + Errormsg_internet, preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default)
            dialog.addAction(action)
            present(dialog, animated:true, completion: nil)
            self.tableView.reloadData()
            refreshControl.endRefreshing()

        }
        refreshControl.endRefreshing()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayofcelldata.count;
    }

    //cell 만드는 곳
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell1", owner: self, options: nil)?.first as! TableViewCell1
            cell.direction_up_img.image = arrayofcelldata[indexPath.row].image1
            cell.direction_down_img.image=arrayofcelldata[indexPath.row].image2
            cell.direction_upbt.setTitle(arrayofcelldata[indexPath.row].text_up_detail, for: .normal)
            cell.direction_upbt.tag = arrayofcelldata[indexPath.row].id
            cell.direction_downbt.tag = arrayofcelldata[indexPath.row].id
            cell.direction_downbt.setTitle(arrayofcelldata[indexPath.row].text_down_detail, for: .normal)
            cell.line_name.text = arrayofcelldata[indexPath.row].station_name
            cell.direction_upbt.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
            cell.direction_downbt.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        return cell
    }
    
    //button click event
    @objc private func buttonClicked(){
        // 버튼이 빈 공간일 때 오류 해결 코드
       if(select_trainnum != ""){
            for i in 0...(locationarray.count-1){
                if(Trainarray[translocation[locationarray[i]]!]! == Int(select_trainnum)!){
                    print(translocation[locationarray[i]]!)
                    if(avg_temp[translocation[locationarray[i]]!] != 0){
                        make_num.removeAll()
                        make_num.append(select_trainnum.substring(to: select_trainnum.index(after: select_trainnum.startIndex)) + "0" + select_trainnum.substring(from: select_trainnum.index(after: select_trainnum.startIndex)))
                        make_num.append(select_trainnum.substring(to: select_trainnum.index(after: select_trainnum.startIndex)) + "1" + select_trainnum.substring(from: select_trainnum.index(after: select_trainnum.startIndex)))
                        make_num.append(select_trainnum.substring(to: select_trainnum.index(after: select_trainnum.startIndex)) + "2" + select_trainnum.substring(from: select_trainnum.index(after: select_trainnum.startIndex)))
                        make_num.append(select_trainnum.substring(to: select_trainnum.index(after: select_trainnum.startIndex)) + "7" + select_trainnum.substring(from: select_trainnum.index(after: select_trainnum.startIndex)))
                        self.performSegue(withIdentifier: "claimview", sender: self)
                        break
                    }
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func ParsingJsonURL(){
        let url = NSURL(string: urlstring)
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data,response,error)->Void in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary{
                if let areaarray = jsonObj!.value(forKey: "subway") as? NSArray{
                    for area in areaarray{
                        if let areaDict = area as? NSDictionary{
                            if let train = areaDict.value(forKey:"Train"),
                                let T1TEMP = areaDict.value(forKey:"T1TEMP"),
                                let T2TEMP = areaDict.value(forKey:"T2TEMP"),
                                let T3TEMP = areaDict.value(forKey:"T3TEMP"),
                                let T4TEMP = areaDict.value(forKey:"T4TEMP"),
                                let T1HUM = areaDict.value(forKey:"T1HUM"),
                                let T2HUM = areaDict.value(forKey:"T2HUM"),
                                let T3HUM = areaDict.value(forKey:"T3HUM"),
                                let T4HUM = areaDict.value(forKey:"T4HUM")
                            {
                                make_train_temparray["\(train)-1"] = (T1TEMP as! Int)
                                make_train_temparray["\(train)-2"] = (T2TEMP as! Int)
                                make_train_temparray["\(train)-3"] = (T3TEMP as! Int)
                                make_train_temparray["\(train)-4"] = (T4TEMP as! Int)
                                make_train_humarray["\(train)-1"] = (T1HUM as! Int)
                                make_train_humarray["\(train)-2"] = (T2HUM as! Int)
                                make_train_humarray["\(train)-3"] = (T3HUM as! Int)
                                make_train_humarray["\(train)-4"] = (T4HUM as! Int)
                            }
                        }
                    }
                    
                }
            }
            
        }).resume()
    }
}
