//
//  CalculatorProtraitViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

final class CalculatorProtraitViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private struct ConstantString {
        static let collectionViewCellReusableString: String = "reusable string"
        static let collectionViewHeaderString: String = "Header String"
        static let keyKindNameScientific = "ScientificKeys"
        static let keyKindNameCommon = "CommonKeys"
        static let keyKindNameFeature = "FeatureKeys"
        static let keyKindNameTrigonometric = "TrigonometricKeys"
        static let keyKindNameExponential = "ExponentialKeys"
        static let keyKindNameOther = "OtherKeys"
        static let keyKindNames = [keyKindNameScientific, keyKindNameCommon, keyKindNameFeature, keyKindNameTrigonometric, keyKindNameExponential, keyKindNameOther]
    }
    
    private var brain = CalculatingEngine()
    
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    private var commonKeys: [Key] = [Key]() {
        didSet { commonKeys = commonKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }

    private var scientificKeys: [Key] = [Key]() {
        didSet { scientificKeys = scientificKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    private var featureKeys: [Key] = [Key]() {
        didSet { featureKeys = featureKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    private var trigonometricKeys: [Key] = [Key]() {
        didSet { trigonometricKeys = trigonometricKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    private var exponentialKeys: [Key] = [Key]() {
        didSet { exponentialKeys = exponentialKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    private var otherKeys: [Key] = [Key]() {
        didSet { otherKeys = otherKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    private var customFunctionKeys: [Key] = [Key]() {
        didSet { customFunctionKeys = customFunctionKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }

    private var recentUsedKeys: [Key] = [Key]()
    
    private var switcher: Int = 0
    
    private var landscapeKeys:[Key] {
        switch switcher {
        case 0:
            return featureKeys
        case 1:
            return featureKeys + trigonometricKeys
        case 2:
            return featureKeys + exponentialKeys
        case 3:
            return featureKeys + otherKeys
        case 4:
            return featureKeys + customFunctionKeys
        default:
            return scientificKeys
        }

    
    }
    
    private var displayStrings = [String]()
    private var lexicalStrings = [String]()
    private var displayFullString: String { return displayStrings.reduce(""){$0 + $1} }
    private var lexicalFullString: String { return lexicalStrings.reduce(""){$0+$1} }
    
    private weak var userInputDisplay: UILabel!
    private weak var userOutputDispaly: UILabel!
    private weak var portraitKeypad: UICollectionView!
    private weak var menuButton: UIButton!
    private var menuOpened = false
    private var viewTapper: UITapGestureRecognizer!
    private var offset : CGFloat {
        return menuOpened ? -50 : 50
    }
    private weak var landscapeKeypad: UICollectionView! {
        didSet{
            // configure lanscapeKeypad's layout constraints
            landscapeConstraints.append(NSLayoutConstraint(item: menuButton, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 8))
            landscapeConstraints.append(NSLayoutConstraint(item: menuButton, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            
            landscapeConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
            
            landscapeConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Right, multiplier: 1, constant: 1))
            landscapeConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            
            landscapeConstraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Top, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Bottom, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
            
            landscapeConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Left, relatedBy: .Equal, toItem: landscapeKeypad, attribute: .Right, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
            
            landscapeConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.8, constant: 0))
            landscapeConstraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.8, constant: 0))
            
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func showMenu(sender: UIButton) {
        print("HitMe")
//        menuMove()
        let effect = UIBlurEffect(style: .ExtraLight)
        let visualEffectView = UIVisualEffectView(effect: effect)
//        visualEffectView.alpha = 0.5
        //visualEffectView.contentView.addSubview(menuButton)
        
        view.addSubview(visualEffectView)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -200))
        
    }
    
    func menuMove() {
        let cp = view.center
        UIView.animateWithDuration(0.2, animations: {
            self.menuButton.hidden = true
            self.view.center = CGPoint(x: cp.x + self.offset, y: cp.y)
            self.menuOpened = !self.menuOpened
            }, completion: {
                _ in
                self.view.addGestureRecognizer(self.viewTapper)
        })
    }
    
    func viewBeHit(sender: AnyObject) {
        print("View Hit")
        view.removeGestureRecognizer(viewTapper)
        menuMove()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readKeypadSpecification()
        view.backgroundColor = UIColor.whiteColor()
        
        let menuBtn = UIButton()
        
        menuBtn.setTitle("M", forState: .Normal)
        menuBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        menuBtn.addTarget(self, action: #selector(CalculatorProtraitViewController.showMenu(_:)), forControlEvents: .TouchUpInside)
        menuBtn.sizeToFit()
        
        viewTapper = UITapGestureRecognizer(target: self, action: #selector(CalculatorProtraitViewController.viewBeHit(_:)))
        
        let inputDisplay = UILabel()
        let outputDisplay = UILabel()
        inputDisplay.textAlignment = .Right
        outputDisplay.textAlignment = .Right
        inputDisplay.textColor = UIColor.lightGrayColor()
        outputDisplay.textColor = UIColor.blackColor()
        inputDisplay.font = UIFont(name: inputDisplay.font.fontName, size: inputDisplay.font.pointSize + 20)
        outputDisplay.font = UIFont(name: inputDisplay.font.fontName, size: inputDisplay.font.pointSize + 20)
        inputDisplay.numberOfLines = 0
        inputDisplay.minimumScaleFactor = 0.5
        inputDisplay.adjustsFontSizeToFitWidth = true
        outputDisplay.numberOfLines = 0
        outputDisplay.minimumScaleFactor = 0.5
        outputDisplay.adjustsFontSizeToFitWidth = true

        
        
        let keypad = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        keypad.dataSource = self
        keypad.delegate = self
        let layout = keypad.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        keypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
        keypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
        keypad.backgroundColor = UIColor.whiteColor()
        
        userInputDisplay = inputDisplay
        userOutputDispaly = outputDisplay
        portraitKeypad = keypad
        menuButton = menuBtn
        
        view.addSubview(inputDisplay)
        view.addSubview(outputDisplay)
        view.addSubview(keypad)
        view.addSubview(menuBtn)
        
        // do autolayout
        inputDisplay.translatesAutoresizingMaskIntoConstraints = false
        outputDisplay.translatesAutoresizingMaskIntoConstraints = false
        keypad.translatesAutoresizingMaskIntoConstraints = false
        menuBtn.translatesAutoresizingMaskIntoConstraints = false
        
        portraitConstraints.append(NSLayoutConstraint(item: menuBtn, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 8))
        portraitConstraints.append(NSLayoutConstraint(item: menuBtn, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Top, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Bottom, multiplier: 1, constant: 1))
        portraitConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0))
        portraitConstraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.7, constant: 0))
        
        NSLayoutConstraint.activateConstraints(portraitConstraints)
        
        inputDisplay.setContentHuggingPriority(750, forAxis: .Vertical)
        outputDisplay.setContentHuggingPriority(700, forAxis: .Vertical)
        keypad.setContentHuggingPriority(250, forAxis: .Vertical)

        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let keys = collectionView == portraitKeypad ? commonKeys : landscapeKeys
        return keys.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ConstantString.collectionViewCellReusableString, forIndexPath: indexPath) as! KeypadCollectionViewCell
        let keys = collectionView == portraitKeypad ? commonKeys : landscapeKeys
        cell.key = keys[indexPath.item]
        
//        if switcher == 1 && keys[indexPath.item].lexicalString == "TF"
//            || switcher == 2 && keys[indexPath.item].lexicalString == "EA"
//            || switcher == 3 && keys[indexPath.item].lexicalString == "Ots"
//            || switcher == 4 && keys[indexPath.item].lexicalString == "CF"
//        {
//            cell.contentView.alpha = 1
//        } else {
//            cell.contentView.alpha = 0.5
//        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let element = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString, forIndexPath: indexPath)
        return element
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        let keys = collectionView == portraitKeypad ? commonKeys : landscapeKeys
        let key = keys[indexPath.item]
        switch key.lexicalString {
            case "=":
                userOutputDispaly.text = brain.getResultStringWithLexicalString(lexicalFullString)
            case "AC":
                displayStrings.removeAll()
                lexicalStrings.removeAll()
                userOutputDispaly.text = ""
            case "<-":
                if !displayStrings.isEmpty { displayStrings.removeLast() }
                if !lexicalStrings.isEmpty { lexicalStrings.removeLast() }
            case "TF":
                switcher = 1
                collectionView.reloadData()
            case "EA":
                switcher = 2
                collectionView.reloadData()
            case "Ots":
                switcher = 3
                collectionView.reloadData()
            case "CF":
                switcher = 4
                collectionView.reloadData()
            case "PrAns":
                break
            case "FS":
                break
            
        default:
            displayStrings.append(key.displayString)
            lexicalStrings.append(key.lexicalString)
        }
        
        userInputDisplay.text = displayFullString
        
        
        
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if landscapeKeypad == nil {
            let keypad = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
            keypad.dataSource = self
            keypad.delegate = self
            let layout = keypad.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            keypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            keypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            landscapeKeypad = keypad
            view.addSubview(keypad)
            landscapeKeypad.translatesAutoresizingMaskIntoConstraints = false
            keypad.setContentHuggingPriority(250, forAxis: .Horizontal)
            keypad.backgroundColor = UIColor.whiteColor()
        }
        
        let dynamicWidth = UIScreen.mainScreen().coordinateSpace.bounds.width
        let fixWidth = UIScreen.mainScreen().fixedCoordinateSpace.bounds.width
        
        if dynamicWidth == fixWidth {
            // portrait mode
            NSLayoutConstraint.deactivateConstraints(landscapeConstraints)
            NSLayoutConstraint.activateConstraints(portraitConstraints)
            landscapeKeypad.hidden = true
        } else {
            // landscape mode
            NSLayoutConstraint.deactivateConstraints(portraitConstraints)
            NSLayoutConstraint.activateConstraints(landscapeConstraints)
            landscapeKeypad.hidden = false
        }
        
        portraitKeypad.collectionViewLayout.invalidateLayout()
        
    }

    private var rows: CGFloat = 0
    private var columns: CGFloat = 0
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == portraitKeypad {
            rows = 5; columns = 4
        } else {
            rows = 5; columns = 6
        }
        let collectionViewSize = collectionView.bounds.size
        let itemWidth = ( collectionViewSize.width - columns - 1 ) / columns
        let itemHeight = (collectionViewSize.height - rows - 1) / rows
        let sz = CGSize(width: itemWidth, height: itemHeight)
        return sz
    }
    
    private func readKeypadSpecification() {
        
        guard let specPath = NSBundle.mainBundle().pathForResource(nil, ofType: "KCConfig") else { return }
        guard let specData = NSData(contentsOfFile: specPath) else { return }
        guard let jsonObject = try? NSJSONSerialization.JSONObjectWithData(specData, options: []) else { return }
        guard let jsonDict = jsonObject as? NSDictionary else { return }
        let keyKinds = ConstantString.keyKindNames
        
        for keyKindName in keyKinds {
            if let keySources = jsonDict[keyKindName] as? NSArray {
                var keys = [Key]()
                for element in keySources {
                    guard let keySource = element as? [String : AnyObject] else { break }
                    guard let aKey = Key(keySource: keySource ) else { break }
                    keys.append(aKey)
                    
                }
                if keys.count > 0 {
                    switch keyKindName {
                    case "ScientificKeys":
                        scientificKeys = keys
                    case "CommonKeys":
                        commonKeys = keys
                    case "FeatureKeys":
                        featureKeys = keys
                    case "TrigonometricKeys":
                        trigonometricKeys = keys
                    case "ExponentialKeys":
                        exponentialKeys = keys
                    case "OtherKeys":
                        otherKeys = keys
                    default:
                        break
                    }
                
                }
            }
        }
    }
    
}






























