//
//  ClaimView.swift
//  Project
//
//  Created by ketis on 2017. 1. 19..
//  Copyright © 2017년 ketis. All rights reserved.
//

import UIKit
import MessageUI
public var server_message:String = " "
public var minwon_call = "01074884268"
public var urlToRequest = "http://energy.openlab.kr:4000"

class ClaimView: UIViewController, UITextFieldDelegate, UITextViewDelegate,MFMessageComposeViewControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet var hum_label: UILabel!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var complain: UILabel!
    @IBOutlet weak var temp_label: UILabel!
    @IBOutlet weak var hope_label: UILabel!
    @IBOutlet var train_label: UILabel!

    var textview_contents:String = ""
    var trainnum = [Int]()
    var iftemp:Int = 0
    var ifhum:Int = 0
    var msg_trainnum:String = " "
    var compare_temp = [String:Int]()
    var type:Int = 1
    // 날짜 설정
    var time = Date()
    //JSON 파일로 전송하기 위한 변수설정
    var current_temp:Int=0
    var hope_temp:Int=0
    var msg:String="Hello.Rustam"
    @IBOutlet var pickerView: UIPickerView!
    
    // pickerView 데이터 바인딩 선언
    var pickerDataSource = [
        "차량 : " + make_num[0] + ", 온도 : \(make_train_temparray[select_trainnum + "-1"]!), 습도 : \(make_train_humarray[select_trainnum + "-1"]!)",
        "차량 : " + make_num[1] + ", 온도 : \(make_train_temparray[select_trainnum + "-2"]!), 습도 : \(make_train_humarray[select_trainnum + "-2"]!)",
        "차량 : " + make_num[2] + ", 온도 : \(make_train_temparray[select_trainnum + "-3"]!), 습도 : \(make_train_humarray[select_trainnum + "-3"]!)",
        "차량 : " + make_num[3] + ", 온도 : \(make_train_temparray[select_trainnum + "-4"]!), 습도 : \(make_train_humarray[select_trainnum + "-4"]!)"]
    
    
    // Pusik
    @IBAction func gobackbutton(_ sender: UIButton) {
        // Move to First scene
        //_ = navigationController?.popToRootViewController(animated: true)
        
        // Move to Previous scene
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendbutton(_ sender: UIButton) {
        self.type = 3
        if (msg_trainnum == " ")
        {
            msg_trainnum = make_num[0]
        }
        self.msg = self.textview.text! // server로 전송할 민원 저장
        let dict = ["complaint": self.complain.text!, "trainID":self.msg_trainnum, "cur_temp":"\(self.iftemp)","cur_hum":"\(self.ifhum)","message":self.msg, "type":self.type] as [String : Any]
        print(dict)
        // Server로 message 전송
/*        if let jsonData = try?JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted){
            let url = NSURL(string:"http://energy.openlab.kr:4000")!
            let request = NSMutableURLRequest(url:url as URL)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request as URLRequest)
            task.resume()
        }*/
        // Server Communication
        func dataRequest() {
            let url4 = URL(string: urlToRequest)!
            let session4 = URLSession.shared
            let request = NSMutableURLRequest(url: url4)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let jsondata = try?JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            request.httpBody = jsondata
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = session4.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let _: Data = data, let _: URLResponse = response, error == nil else {
                    print("*****error")
                    return
                }
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(dataString!) //JSONSerialization
                server_message = dataString! as String
            }
            task.resume()
        }
        dataRequest()
        print(server_message)
        
        let dialog = UIAlertController(title:"안내", message: "\n" + "정부의 에너지 정책 기준에 의해 현재 냉방기가 가동 중에 있습니다.\n조금 불편하시더라도 양해바랍니다.", preferredStyle:.alert)
        let cancelact = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (result : UIAlertAction) -> Void in
                print("cancel")
        }
        let okact = UIAlertAction(title: "보내기", style: UIAlertActionStyle.default){(reslut: UIAlertAction) -> Void in
            self.type = 1
            self.msg = self.textview.text! // server로 전송할 민원 저장
            let dict = ["complaint": self.complain.text!, "trainID":self.msg_trainnum, "cur_temp":"\(self.iftemp)","cur_hum":"\(self.ifhum)","message":self.msg, "type":self.type] as [String : Any]
            print(dict)
            // Server로 message 전송
            dataRequest()
            
            /* Removed by Pusik
            let dialog = UIAlertController(title: "Message", message: server_message, preferredStyle:.alert)
            let action = UIAlertAction(title:"확인", style: UIAlertActionStyle.default){(result: UIAlertAction) -> Void in
                // 사용자에게 sms 전송
                if(setting_num == 1){
                    if(MFMessageComposeViewController.canSendText()){
                        let controller = MFMessageComposeViewController()
                        controller.body = self.textview!.text
                        controller.recipients = [minwon_call]
                        controller.messageComposeDelegate = self
                        self.present(controller, animated:true, completion:nil)
                    }
                }
            }
            dialog.addAction(action)
            self.present(dialog, animated:true, completion: nil)

            self.presentingViewController?.dismiss(animated: true, completion: nil)
             */
        }
        dialog.addAction(okact)
        dialog.addAction(cancelact)
        self.present(dialog, animated:true, completion: nil)
        
    }
    @IBAction func slider(_ sender: UISlider) {
        hope_label.isHidden = false
        complain.isHidden = false //희망온도와 추워요,더워요 메세지 나타내기
        
        hope_temp = Int(sender.value) // server로 희망온도 전송
        
        hope_label.text = String(Int(sender.value)) // 희망온도를 문자화 시켜서 출력
        if Int(sender.value) > iftemp {
            complain.text = "cool"
        }
        else if Int(sender.value) == iftemp {
            complain.text = "normal"
        }
        else{
            complain.text = "hot"
        }
    }
    func textView(_ textView:UITextView, shouldChangeTextIn range: NSRange, replacementText text:String)->Bool{
        if(text == "\n")
        {
            view.endEditing(true)
            return false
        }
        else
        {
            return true
        }
    }
    let placeholder_text = "열차번호 입력"
    let placeholder_text2 = "민원을 입력하세요"
    override func viewDidLoad() {
        super.viewDidLoad()
        train_label.text = select_trainnum + " 번"
        iftemp = make_train_temparray[select_trainnum+"-1"]!
        ifhum = make_train_humarray[select_trainnum+"-1"]!
        hum_label.text = "\(ifhum)"
        temp_label.text = "\(iftemp)"
        hope_label.text = "\(iftemp)"
        complain.text = "normal"
        self.pickerView.dataSource=self
        self.pickerView.delegate = self
        //self.view.addSubview(textview!)
        textview.delegate=self
        //textview.text = "민원 내용을 입력하세요."
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row{
        case 0:
            temp_label.text = "\(make_train_temparray[select_trainnum + "-1"]!)"
            iftemp = make_train_temparray[select_trainnum+"-1"]!
            ifhum = make_train_humarray[select_trainnum+"-1"]!
            hum_label.text = "\(ifhum)"
            hope_label.text = "\(iftemp)"
            complain.text = "normal"
            msg_trainnum = make_num[0]
            break
        case 1:
            temp_label.text = "\(make_train_temparray[select_trainnum + "-2"]!)"
            iftemp = make_train_temparray[select_trainnum+"-2"]!
            ifhum = make_train_humarray[select_trainnum+"-2"]!
            hum_label.text = "\(ifhum)"
            hope_label.text = "\(iftemp)"
            complain.text = "normal"
            msg_trainnum = make_num[1]
            break
        case 2:
            temp_label.text = "\(make_train_temparray[select_trainnum + "-3"]!)"
            iftemp = make_train_temparray[select_trainnum+"-3"]!
            ifhum = make_train_humarray[select_trainnum+"-3"]!
            hum_label.text = "\(ifhum)"
            hope_label.text = "\(iftemp)"
            complain.text = "normal"
            msg_trainnum = make_num[2]
            break
        case 3:
            temp_label.text = "\(make_train_temparray[select_trainnum + "-4"]!)"
            iftemp = make_train_temparray[select_trainnum+"-4"]!
            ifhum = make_train_humarray[select_trainnum+"-4"]!
            hum_label.text = "\(ifhum)"
            hope_label.text = "\(iftemp)"
            complain.text = "normal"
            msg_trainnum = make_num[3]
            break
        default:
            msg_trainnum = make_num[0]
            break
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil{
            label = UILabel()
        }
        let data = pickerDataSource[row]
        let title = NSAttributedString(string: data, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    func messageComposeViewController(_ controller:MFMessageComposeViewController,didFinishWith result: MessageComposeResult){
        self.dismiss(animated: true, completion: nil)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden=false
    }
    override func viewDidAppear(_ animated: Bool) {
        textview.isScrollEnabled = true
    }
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
}
