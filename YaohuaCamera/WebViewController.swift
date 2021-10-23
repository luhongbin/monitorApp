//
//  WebViewController.swift
//  Created by Luhongbin on 2017/7/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

import Foundation
import MBProgressHUD
class WebViewController: UIViewController{
    
    var webView:UIWebView!
    override func viewDidLoad() {
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        self.navigationItem.title = NSLocalizedString("support", comment: "")
        
        let leftBarView = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftBarView.setImage(UIImage(named: "reback_icon"), for: UIControlState())

        leftBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WebViewController.back)))
        leftBarView.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        leftBarView.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        //左导航按钮
        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]
        webView = UIWebView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height - 64))

        //        let url = "http://www.lutec.cn/node/159"
        var url = "http://178.79.143.216:7600/support-homes?id=2073"
        //"http://178.79.143.216:7600/support-homes?id=2073"
        //"http://yaohua-site.jiyu.tech:7600/support-home"
        if let language =  Bundle.main.preferredLocalizations.first  {
            //Locale.preferredLanguages.first {
            let languageDic = NSLocale.components(fromLocaleIdentifier: language) as NSDictionary
            //let countryCode = languageDic.objectForKey("kCFLocaleCountryCodeKey")
            let languageCode = languageDic.object(forKey: "kCFLocaleLanguageCodeKey") as! String
            print("language:",languageCode)
            var lang="es"
            switch languageCode {
                case "de-de","de": lang="de"
                case "fr-fr","fr": lang="fr"
                case "es-es","es": lang="es"
                case "it-it","it": lang="it"
                case "nl-nl","nl": lang="nl"
                case "hu-hu","hu": lang="hu"
                case "sl-sl","sl": lang="sl"
                case "hr-hr","hr": lang="hr"
                case  "zh-Hans-US","zh-Hans-CN","zh","zh-TW","zh-HK","zh-Hans": lang="zh"
                //case "en-us": fallthrough
                default: lang="en"
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.mode = .text
                    hud.label.text = "["+language+"] no help file,use english."
                    hud.backgroundView.style = .solidColor
                    hud.hide(animated: true, afterDelay: 2)
               
            }
            //url = "\(url)?lang=\(lang)"
            url = "\(url)&lang=\(lang)"
        }
        webView.loadRequest(URLRequest(url: URL(string:url)!))
        self.view.addSubview(webView)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = NSLocalizedString("Refresh_State", comment: "")
        hud.backgroundView.style = .solidColor
        hud.hide(animated: true, afterDelay: 2)
    }
     
    @objc func back(){
        if webView.canGoBack {
            webView.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
