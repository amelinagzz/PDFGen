//
//  ViewController.swift
//  PDFswift
//
//  Created by Adriana Gonzalez on 2/25/16.
//  Copyright © 2016 Adriana Gonzalez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let PADDING: CGFloat = 20.0
    var pagesize : CGSize!
    let data = NSMutableData()
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var txtInfo: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.clipsToBounds = true
        txtInfo.delegate = self
        txtInfo.autocapitalizationType = .Sentences
        self.title = "PDF Generator"
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imageView.userInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: "selectImg")
        imageView.addGestureRecognizer(gesture)

    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "PDFGenerator"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func makePdfFromScratch(sender: AnyObject) {
        let pdfName = "pdfFromScratch"
        setupPDFDocumentNamed(pdfName, width: 600, height: 800)
        beginPDFpage()
        finishPDF()
        openPdf(pdfName, pdfData: nil)
    }
    
    @IBAction func makePdfWithView(sender: AnyObject) {
        let pdfName = "pdfFromView"
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, self.view.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        self.view.layer.renderInContext(pdfContext)
        UIGraphicsEndPDFContext()
        let newPDFName = "\(pdfName).pdf"
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let pdfPath = documentsDirectory.stringByAppendingPathComponent(newPDFName)
        pdfData.writeToFile(pdfPath, atomically: true)

        openPdf(pdfName, pdfData: nil)

    }
    
    @IBAction func makePdfFromTemplate(sender: AnyObject) {
        
        let pdf = CGPDFDocumentCreateWithURL(NSBundle.mainBundle().URLForResource("demo", withExtension: "pdf"))
        let numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)
        let pdfName = "pdfFromTemplate"

        let newPDFName = "\(pdfName).pdf"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pdfPath = documentsPath.stringByAppendingPathComponent(newPDFName)
        print(pdfPath)
        
        //UIGraphicsBeginPDFContextToData(data, CGRectZero, nil)
        UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil)
      
        for(var page = 1; page <= numberOfPages; page++)
        {
            //	Get the current page and page frame
            let pdfPage = CGPDFDocumentGetPage(pdf, page)
            let pageFrame = CGPDFPageGetBoxRect(pdfPage, .CropBox)
            
            UIGraphicsBeginPDFPageWithInfo(pageFrame, nil)
            
            //	Draw the page (flipped)
            let ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx)
            CGContextScaleCTM(ctx, 1, -1)
            CGContextTranslateCTM(ctx, 0, -pageFrame.size.height)
            CGContextDrawPDFPage(ctx, pdfPage)
            CGContextRestoreGState(ctx)
            
            if(page == 1) {
                //	Draw
                UIColor(red: 166.0/255.0, green: 89.0/255.0, blue: 155.0/255.0, alpha: 1).set()
                UIRectFill(CGRectMake(22, 65, 42, 60))
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .Left
                
                let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 26)!, NSParagraphStyleAttributeName: paragraphStyle]
                
                let string = "Adriana Gzz"
                string.drawWithRect(CGRect(x: 75, y: 65, width: 448, height: 448), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)

            }
            
        }
        
        UIGraphicsEndPDFContext()
        //let dataProvider = CGDataProviderCreateWithCFData(data)
        //let newpdf = CGPDFDocumentCreateWithProvider(dataProvider)
        
        openPdf(pdfName, pdfData: nil)
    }
    
    func setupPDFDocumentNamed(name: NSString, width: CGFloat, height: CGFloat) {
        
        pagesize = CGSizeMake(width, height)
        
        let newPDFName = "\(name).pdf"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pdfPath = documentsPath.stringByAppendingPathComponent(newPDFName)
        print(pdfPath)
        
        UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil)
        
    }
    
    func beginPDFpage() {
        
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pagesize.width, pagesize.height), nil)
        let anImage: UIImage!
        
        if(imageView.image != nil) {
            anImage = imageView.image
        }else{
             anImage = UIImage(named: "cactus")
        }
        
        let imageRect = self.addImage(anImage!, atPoint: CGPointMake((pagesize.width/2)-(imageView!.frame.size.width/2), CGFloat(20.0 + PADDING)))
        let lineRect = addLineWithFrame(CGRectMake(PADDING, imageRect.origin.y + imageRect.size.height + PADDING, pagesize.width - PADDING*2, 4), withColor: UIColor(red: 166.0/255.0, green: 89.0/255.0, blue: 155.0/255.0, alpha: 1))

        var textToPdf = "Hello"
        
        if txtInfo.text != "" {
            textToPdf = txtInfo.text!
        }
        
        addText(textToPdf, withFrame: CGRectMake(PADDING, lineRect.origin.y + lineRect.size.height + PADDING, pagesize.width - PADDING*2, 60), fontSize: 24)
        
    }
    
    
    func finishPDF(){
    
        UIGraphicsEndPDFContext()
    
    }

    func addText(text: NSString, withFrame frame: CGRect, fontSize: CGFloat) -> CGRect{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: fontSize)!, NSParagraphStyleAttributeName: paragraphStyle]
        let string = text
        
        string.drawWithRect(frame, options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        return frame
    }
    

    func addLineWithFrame(frame: CGRect, withColor color: UIColor) -> CGRect {
       
        let currentContext = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(currentContext, color.CGColor)
        CGContextSetLineWidth(currentContext, frame.size.height)
        
        let startPoint = frame.origin
        let endPoint = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y)
        CGContextBeginPath(currentContext)
        CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y)
        CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y)
        
        CGContextClosePath(currentContext)
        CGContextDrawPath(currentContext, .FillStroke)
        
        return frame
    }
    

    func addImage(image: UIImage, atPoint point:CGPoint) -> CGRect {
        let imageFrame = CGRectMake(point.x, point.y, imageView.frame.size.width, imageView.frame.size.height)
        image.drawInRectAspectFill(imageFrame)
        return imageFrame
    }

    func selectImg() {
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
    }
    
    func openPdf(name: String?, pdfData: NSData?) {
        
        let vc = PDFViewController()
        if name != "" && name != nil {
            vc.name = name
        }
        if pdfData != nil {
            vc.fileData = data
        }
        
        self.title = ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
}

extension UIImage {
    func drawInRectAspectFill(rect: CGRect) {
        let targetSize = rect.size
        let scaledImage: UIImage
        if targetSize == CGSizeZero {
            scaledImage = self
        } else {
            let aspectRatio = self.size.width / self.size.height
            let scalingFactor = targetSize.width / self.size.width > targetSize.height / self.size.height ? targetSize.width / self.size.width : targetSize.height / self.size.height
            let newSize = CGSize(width: self.size.width * scalingFactor, height: self.size.height * scalingFactor)
            UIGraphicsBeginImageContext(targetSize)
            self.drawInRect(CGRect(origin: CGPoint(x: (targetSize.width - newSize.width) / 2, y: (targetSize.height - newSize.height) / 2), size: newSize))
            scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        scaledImage.drawInRect(rect)
    }
}
