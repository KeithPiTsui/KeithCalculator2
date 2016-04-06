//
//  CalculatorProtraitViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - Manage User Interface of Simple and Scientifi calculator

final class CalculatorProtraitViewController: UIViewController {

    /**
     constants used by this controller
     */
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
    
    // MARK: rows and columns of keys in Keypad
    private var portraitKeypadRows: CGFloat = 5
    private var portraitKeypadColumns: CGFloat = 4
    private var landscapeKeypadRows: CGFloat = 5
    private var landscapeKeypadColumns: CGFloat = 6
    
    
    // MARK:
    /**
     a private constance holding a calculating engin for evaluating input expression
     */
    private let brain = CalculatingEngine.universalCalculatingEngine
    
    /**
     auto layout constraints for portrait interface of simple calculator
     */
    private var portraitConstraints = [NSLayoutConstraint]()
    
    /**
     auto layout constraints for landscape interface of simple calculator
     */
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    /**
     an array of key for holding keys for simple calculator keypad
     */
    private var commonKeys: [Key] = [Key]() {
        didSet { commonKeys = commonKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }

    /**
     an array of key for holding keys for scientific calculator keypad
     */
    private var scientificKeys: [Key] = [Key]() {
        didSet { scientificKeys = scientificKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    /**
     an array of key for holding feature keys for scientific calculator keypad
     */
    private var featureKeys: [Key] = [Key]() {
        didSet { featureKeys = featureKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    /**
     an array of key for holding keys for trigonometrical function
     */
    private var trigonometricKeys: [Key] = [Key]() {
        didSet { trigonometricKeys = trigonometricKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    /**
     an array of key for holding keys for exponential function
     */
    private var exponentialKeys: [Key] = [Key]() {
        didSet { exponentialKeys = exponentialKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    /**
     an array of key for holding keys for other function
     */
    private var otherKeys: [Key] = [Key]() {
        didSet { otherKeys = otherKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }
    
    /**
     an array of key for holding keys for customized function
     */
    private var customFunctionKeys: [Key] = [Key]() {
        didSet { customFunctionKeys = customFunctionKeys.sort{$0.positionInOrder < $1.positionInOrder} }
    }

    /**
     an array of key for holding keys for recent used function
     */
    private var recentUsedKeys: [Key] = [Key]()
    
    /**
     to control keys display
     */
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
    
    // MARK: - Expression display string and lexical string
    private var displayStrings = [String]()
    private var lexicalStrings = [String]()
    private var displayFullString: String { return displayStrings.reduce(""){$0 + $1} }
    private var lexicalFullString: String { return lexicalStrings.reduce(""){$0+$1} }
    
    private var inputExpressionRecords: [(displayString: String, lexicalString: String, result: String)]
        = [(displayString: String, lexicalString: String, result: String)]()
    
    // MARK: - UI elements
    private weak var userInputDisplay: UILabel! {
        didSet {
            userInputDisplay.translatesAutoresizingMaskIntoConstraints = false
            userInputDisplay.textAlignment = .Right
            userInputDisplay.textColor = UIColor.lightGrayColor()
            userInputDisplay.font = UIFont(name: userInputDisplay.font.fontName, size: userInputDisplay.font.pointSize + 20)
            userInputDisplay.numberOfLines = 0
            userInputDisplay.minimumScaleFactor = 0.5
            userInputDisplay.adjustsFontSizeToFitWidth = true
            userInputDisplay.setContentHuggingPriority(750, forAxis: .Vertical)
        }
    }
    
    private weak var userOutputDispaly: UILabel! {
        didSet{
            userOutputDispaly.translatesAutoresizingMaskIntoConstraints = false
            userOutputDispaly.textAlignment = .Right
            userOutputDispaly.textColor = UIColor.blackColor()
            userOutputDispaly.font = UIFont(name: userOutputDispaly.font.fontName, size: userOutputDispaly.font.pointSize + 20)
            userOutputDispaly.numberOfLines = 0
            userOutputDispaly.minimumScaleFactor = 0.5
            userOutputDispaly.adjustsFontSizeToFitWidth = true
            userOutputDispaly.setContentHuggingPriority(700, forAxis: .Vertical)
        }
    }
    private weak var portraitKeypad: UICollectionView! {
        didSet {
            portraitKeypad.translatesAutoresizingMaskIntoConstraints = false
            portraitKeypad.dataSource = self
            portraitKeypad.delegate = self
            let layout = portraitKeypad.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            portraitKeypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            portraitKeypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            portraitKeypad.backgroundColor = UIColor.whiteColor()
            portraitKeypad.setContentHuggingPriority(250, forAxis: .Vertical)
            
            portraitConstraints = getPortraitConstraints()
        }
    }
    private weak var landscapeKeypad: UICollectionView! {
        
        didSet{
            landscapeKeypad.dataSource = self
            landscapeKeypad.delegate = self
            let layout = landscapeKeypad.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            landscapeKeypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            landscapeKeypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            landscapeKeypad.translatesAutoresizingMaskIntoConstraints = false
            landscapeKeypad.setContentHuggingPriority(250, forAxis: .Horizontal)
            landscapeKeypad.backgroundColor = UIColor.whiteColor()
            landscapeConstraints = getLandscapeContraints()
        }
    }
    private weak var menuButton: UIButton! {
        didSet{
            menuButton.translatesAutoresizingMaskIntoConstraints = false
            menuButton.setTitle("M", forState: .Normal)
            menuButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            menuButton.sizeToFit()
        }
    }
    
    
    // MARK: - Auto layout constraints construction
    /**
     construct a set of auto layout constraints for landscape UI
     */
    private func getLandscapeContraints() -> [NSLayoutConstraint]{
        // configure lanscapeKeypad's layout constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 8))
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Right, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Top, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
        constraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Left, relatedBy: .Equal, toItem: landscapeKeypad, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.8, constant: 0))
        constraints.append(NSLayoutConstraint(item: landscapeKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.8, constant: 0))
        
        return constraints
    }
    
    /**
     construct a set of auto layout constraints for portrait UI
     */
    private func getPortraitConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 8))
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Top, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Bottom, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0))
        constraints.append(NSLayoutConstraint(item: portraitKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.7, constant: 0))
        return constraints
    }
    
    // MARK: - View controller life cycle function
    override func prefersStatusBarHidden() -> Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readKeypadSpecificationBySwiftyJSON()
        view.backgroundColor = UIColor.whiteColor()
        
        let menuBtn = UIButton()
        menuButton = menuBtn
        let inputDisplay = UILabel()
        userInputDisplay = inputDisplay
        let outputDisplay = UILabel()
        userOutputDispaly = outputDisplay
        let keypad = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        portraitKeypad = keypad

        view.addSubview(inputDisplay)
        view.addSubview(outputDisplay)
        view.addSubview(keypad)
        view.addSubview(menuBtn)
        
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if landscapeKeypad == nil {
            let keypad = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
            landscapeKeypad = keypad
            view.addSubview(keypad)
        }
        
        if isPortraitMode() {
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
        // update collection view's layout
        landscapeKeypad.collectionViewLayout.invalidateLayout()
        portraitKeypad.collectionViewLayout.invalidateLayout()
        
    }
    
    /**
     To know if it is portrait mode or landscape mode
     */
    private func isPortraitMode() -> Bool {
        let dynamicWidth = UIScreen.mainScreen().coordinateSpace.bounds.width
        let fixWidth = UIScreen.mainScreen().fixedCoordinateSpace.bounds.width
        return dynamicWidth == fixWidth
    }
   
    // MARK: - Helper function for read key specification of JSON
    
    /**
     read key specification of JSON via Swifty json framework
     */
    private func readKeypadSpecificationBySwiftyJSON() {
        
        guard let specPath = NSBundle.mainBundle().pathForResource(nil, ofType: "KCConfig") else { return }
        guard let specData = NSData(contentsOfFile: specPath) else { return }
        let json = JSON(data: specData)
        let keyKinds = ConstantString.keyKindNames
        for keyKindName in keyKinds {
            var keys = [Key]()
            for (_, subJson):(String, JSON) in json[keyKindName] {
                guard let keySource = subJson.rawValue as? [String : AnyObject] else { break }
                guard let aKey = Key(keySource: keySource) else { break }
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
    
    /**
     /**
     read key specification of JSON via cocoa native json parser
     */
     */
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


// MARK: - UICollectionViewDataSource Implementation
extension CalculatorProtraitViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {  return 1 }
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return collectionView == portraitKeypad ? commonKeys.count : landscapeKeys.count
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ConstantString.collectionViewCellReusableString, forIndexPath: indexPath) as! KeypadCollectionViewCell
        cell.key = collectionView == portraitKeypad ? commonKeys[indexPath.item] : landscapeKeys[indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                            withReuseIdentifier: ConstantString.collectionViewHeaderString,
                            forIndexPath: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Implementation
extension CalculatorProtraitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let rows = collectionView == portraitKeypad ? portraitKeypadRows : landscapeKeypadRows
        let columns = collectionView == portraitKeypad ? portraitKeypadColumns : landscapeKeypadColumns
        let collectionViewSize = collectionView.bounds.size
        let itemWidth = ( collectionViewSize.width - columns - 1 ) / columns
        let itemHeight = (collectionViewSize.height - rows - 1) / rows
        let sz = CGSize(width: itemWidth, height: itemHeight)
        return sz
    }

}

// MARK: - UICollectionViewDelegate Implementation
extension CalculatorProtraitViewController: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        let keys = collectionView == portraitKeypad ? commonKeys : landscapeKeys
        let key = keys[indexPath.item]
        switch key.lexicalString {
        case "=":
            
            let resultString = brain.getResultStringWithLexicalString(lexicalFullString)
            inputExpressionRecords.append((displayString: displayFullString, lexicalString: lexicalFullString, result: resultString))
            userOutputDispaly.text = resultString
            
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
        case "Hst":
            print(inputExpressionRecords)
        case "Ots":
            switcher = 3
            collectionView.reloadData()
        case "CF":
            switcher = 4
            collectionView.reloadData()
        case "Gph":
            let presentVC = DrawingViewController(WithExpression: lexicalFullString)
            presentViewController(presentVC, animated: true, completion: nil)
            
        default:
            displayStrings.append(key.displayString)
            lexicalStrings.append(key.lexicalString)
        }
        
        userInputDisplay.text = displayFullString
        
        
        
    }
}


















