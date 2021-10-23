//
//  OKViewController.swift
//
//  Created by Luhongbin on 2018/07/20.
//  Copyright © 2018年 Luhongbin. All rights reserved.
//

import UIKit

class OKViewController: UIViewController {
    var selectk = "0"
    
    @IBOutlet weak var norecordlab: UILabel!
    @IBOutlet weak var titlealert: UILabel!
    @IBOutlet weak var norecordbnt: UIButton!
    @IBOutlet weak var alertlab: UILabel!
    @IBOutlet weak var alertbnt: UIButton!
    @IBOutlet weak var continuelab: UILabel!
    @IBOutlet weak var continuebnt: UIButton!
    
    @IBOutlet weak var cntpic: UIButton!
    @IBOutlet weak var selectlab: UIButton!
    @IBOutlet weak var nopic: UIButton!
    @IBOutlet weak var alterpic: UIButton!
    
    @IBAction func selecbnt(_ sender: Any) {
        UserDefaults.standard.setValue(selectk, forKey: "ExtRecordMask")

        self.dismiss(animated: true, completion:nil)
    }

    @IBAction func countpicbnt(_ sender: Any) {
        selectk = "0"
        self.cntpic.isSelected = true
        self.alterpic.isSelected = false
        self.nopic.isSelected = false
        self.cntpic.setImage(UIImage(named: "RadionSelected"), for: .selected)
        self.nopic.setImage(UIImage(named: ""), for: .normal)
        self.alterpic.setImage(UIImage(named: ""), for: .normal)
        selectlab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        selectlab.isEnabled=true
    }
    @IBAction func alterpicbnt(_ sender: Any) {
        selectk = "4"
        self.cntpic.isSelected = false
        self.alterpic.isSelected = true
        self.nopic.isSelected = false
        self.nopic.setImage(UIImage(named: ""), for: .normal)
        self.cntpic.setImage(UIImage(named: ""), for: .normal)
        self.alterpic.setImage(UIImage(named: "RadionSelected"), for: .selected)
        selectlab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        selectlab.isEnabled=true
    }
    @IBAction func nopicbnt(_ sender: Any) {
        selectk = "7"
        self.cntpic.isSelected = false
        self.alterpic.isSelected = false
        self.nopic.isSelected = true
        self.nopic.setImage(UIImage(named: "RadionSelected"), for: .selected)
        self.cntpic.setImage(UIImage(named: ""), for: .normal)
        self.alterpic.setImage(UIImage(named: ""), for: .normal)
        selectlab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        selectlab.isEnabled=true
    }
    @IBAction func contclick(_ sender: Any) {
        selectk = "0"
        self.cntpic.isSelected = true
        self.alterpic.isSelected = false
        self.nopic.isSelected = false
        self.cntpic.setImage(UIImage(named: "RadionSelected"), for: .selected)
        self.nopic.setImage(UIImage(named: ""), for: .normal)
        self.alterpic.setImage(UIImage(named: ""), for: .normal)
        selectlab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        selectlab.isEnabled=true

    }
    @IBAction func alertclick(_ sender: Any) {
        selectk = "4"
        self.cntpic.isSelected = false
        self.alterpic.isSelected = true
        self.nopic.isSelected = false
        self.nopic.setImage(UIImage(named: ""), for: .normal)
        self.cntpic.setImage(UIImage(named: ""), for: .normal)
        self.alterpic.setImage(UIImage(named: "RadionSelected"), for: .selected)
        selectlab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        selectlab.isEnabled=true

    }
    @IBAction func norecordclick(_ sender: Any) {
        selectk = "7"
        self.cntpic.isSelected = false
        self.alterpic.isSelected = false
        self.nopic.isSelected = true
        self.nopic.setImage(UIImage(named: "RadionSelected"), for: .selected)
        self.cntpic.setImage(UIImage(named: ""), for: .normal)
        self.alterpic.setImage(UIImage(named: ""), for: .normal)
        selectlab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        selectlab.isEnabled=true

        //self.dismiss(animated: true, completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titlealert.text = NSLocalizedString("Storage mode selection", comment: "")
        alertlab.text = NSLocalizedString("Move Storage hint", comment: "")
        norecordlab.text = NSLocalizedString("No Storage hint", comment: "")
        norecordlab.numberOfLines=0
        continuelab.numberOfLines=0
        alertlab.numberOfLines=0

        norecordbnt.setTitle(NSLocalizedString("No Storage", comment: ""), for:UIControlState.normal)
        alertbnt.setTitle(NSLocalizedString("Move Storage", comment: ""), for:UIControlState.normal)
        selectlab.isEnabled=false
        continuebnt.setTitle(NSLocalizedString("Continuous Storage", comment: ""), for:UIControlState.normal)
        continuelab.text = NSLocalizedString("Continuous Storage hint", comment: "")

        selectlab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.disabled)
        self.nopic.setImage(UIImage(named: ""), for: .normal)
        self.cntpic.setImage(UIImage(named: ""), for: .normal)
        self.alterpic.setImage(UIImage(named: ""), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
