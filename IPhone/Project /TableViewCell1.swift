//
//  TableViewCell1.swift
//  Project
//
//  Created by ketis on 2017. 6. 28..
//  Copyright © 2017년 ketis. All rights reserved.
//

import UIKit

class TableViewCell1:UITableViewCell{

    @IBOutlet var direction_up_img: UIImageView!
    @IBOutlet var direction_down_img: UIImageView!
    @IBOutlet var direction_upbt: UIButton!
    @IBOutlet var line_name: UILabel!
    @IBOutlet var direction_downbt: UIButton!
    var trainnum:String=""
    @IBAction func up_click(_ sender: Any) {
        let buttontitle = direction_upbt.currentTitle!
        if (buttontitle == "") {
            print("Not in value")
            select_trainnum = ""
        }
        else{
            select_trainnum = "\(Trainarray[translocation[direction_upbt.tag]!]!)"
            print(select_trainnum)
        }
    }
    @IBAction func down_click(_ sender: Any) {
        let buttontitle = direction_downbt.currentTitle!
        if (buttontitle == "") {
            print("Not in value")
            select_trainnum = ""
        }
        else{
            select_trainnum = "\(Trainarray[translocation[direction_downbt.tag]!]!)"
            print(select_trainnum)
        }
    }
}
