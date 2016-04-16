//
//  DemoViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 4/11/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - A view Controller called DemoViewController which holds a UIImageView for displaying a demostrated pic

final class DemoViewController: UIViewController {

    /**
     a file path of a specific demo picture
     */
    let picName: String
    
    /**
     An UIImage View for display a demostrated picture
     */
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
    
    /**
     Initializer with picture's file path
     */
    init(Demo demo:String) {
        picName = demo
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
     required initializer that has not implemented yet
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Customized view heirarchy of this controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        let iv = UIImageView()
        view.addSubview(iv)
        pic = iv
        pic.image = UIImage(named:"\(picName)")

        let tap = UITapGestureRecognizer(target: self, action: #selector(DemoViewController.done))
        view.addGestureRecognizer(tap)
        
    }
    
    /**
     When user tap on pic, this controller dismisses presentation.
     */
    func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
