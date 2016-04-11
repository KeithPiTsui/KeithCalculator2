//
//  DemoViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 4/11/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

final class DemoViewController: UIViewController {

    var picName: String
    
    private weak var pic: UIImageView! {
        didSet{
            pic.translatesAutoresizingMaskIntoConstraints = false
            pic.contentMode = .ScaleAspectFit
            view.addConstraint(NSLayoutConstraint(item: pic, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: pic, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: pic, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: pic, attribute: .Bottom, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0))
        }
    }
    
    init(Demo demo:String) {
        picName = demo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        let iv = UIImageView()
        view.addSubview(iv)
        pic = iv
        pic.image = UIImage(named:"\(picName)")
        
        let btn = UIButton()
        btn.setTitle("X", forState: .Normal)
        btn.addTarget(self, action: #selector(DemoViewController.done), forControlEvents: .TouchUpInside)
        btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btn)
        view.addConstraint(NSLayoutConstraint(item: btn, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: btn, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        
    }
    
    func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
