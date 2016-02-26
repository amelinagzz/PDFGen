//
//  PDFViewController.swift
//  PDFswift
//
//  Created by Adriana Gonzalez on 2/25/16.
//  Copyright © 2016 Adriana Gonzalez. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class PDFViewController: UIViewController, MFMailComposeViewControllerDelegate {
    let mailComposer = MFMailComposeViewController()
    

    var name: String!
    var fileData: NSData!
    
    override func viewDidLoad() {
        
        let shareBar: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.Action, target: self, action: Selector("shareTapped"))
        
        self.navigationItem.rightBarButtonItem = shareBar
        
        self.title = "New PDF"
        super.viewDidLoad()
            
        let webView = WKWebView()
        webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.view.addSubview(webView)

        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let filePath = "\(documentsPath)/\(name).pdf"
        
        fileData = NSData(contentsOfFile: filePath)
        webView.loadData(fileData!, MIMEType: "application/pdf", characterEncodingName: "utf-8", baseURL:NSURL())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shareTapped() {
        if( MFMailComposeViewController.canSendMail() ) {
            
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setSubject("New PDF")
            mailComposer.setMessageBody("Here is the generated PDF.", isHTML: false)
            
            mailComposer.addAttachmentData(fileData, mimeType: "application/pdf", fileName: name)
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
