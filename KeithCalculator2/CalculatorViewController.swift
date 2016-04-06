//
//  CalculatorProtraitViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - Manage User Interface of Simple and Scientifi calculator

final class CalculatorViewController: UIViewController {
    
    /**
     constants used by this controller
     */
    private struct ConstantString {
        static let collectionViewCellReusableString: String = "reusable string"
        static let HistoryCollectionViewCellReusableString: String = "history reusable string"
        static let graphCollectionViewCellReusableString: String = "Graph reusable String"
        static let collectionViewHeaderString: String = "Header String"
        static let keyKindNameScientific = "ScientificKeys"
        static let keyKindNameCommon = "CommonKeys"
        static let keyKindNameFeature = "FeatureKeys"
        static let keyKindNameTrigonometric = "TrigonometricKeys"
        static let keyKindNameExponential = "ExponentialKeys"
        static let keyKindNameOther = "OtherKeys"
        static let keyKindNames = [keyKindNameCommon, keyKindNameFeature, keyKindNameTrigonometric, keyKindNameOther]
    }
    
    // MARK: rows and columns of keys in Keypad
    private var commonKeypadRows: CGFloat = 5
    private var commonKeypadColumns: CGFloat = 4
    private var featureKeypadRows: CGFloat = 1
    private var featureKeypadColumns: CGFloat = 6
    private var functionKeypadRows: CGFloat = 4
    private var functionKeypadColumns: CGFloat = 6
    
    
    // MARK:
    /**
     a private constance holding a calculating engin for evaluating input expression
     */
    private let brain = CalculatingEngine()
    
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
     an array of key for holding feature keys for scientific calculator keypad
     */
    private var featureKeys: [Key] = [Key]() {
        didSet {
            if historyKeys.isEmpty { historyKeys.append(featureKeys[0]) }
            featureKeys = featureKeys.sort{$0.positionInOrder < $1.positionInOrder}
        }
    }
    
    /**
     an array of key for holding keys for trigonometrical function
     */
    private var trigonometricKeys: [Key] = [Key]() {
        didSet { trigonometricKeys = trigonometricKeys.sort{$0.positionInOrder < $1.positionInOrder} }
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
     an array of key for holding keys for recent used function
     */
    private var historyKeys: [Key] = [Key]()
    
    /**
     to control function area how to display its content
     */
    private var switcher: Int = 0
    
    private var functionKeys:[Key] {
        switch switcher {
        case 0:
            return trigonometricKeys
        case 1:
            return otherKeys
        case 2:
            return customFunctionKeys
        case 3:
            return historyKeys
        case 4:
            return historyKeys
        default:
            return trigonometricKeys
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
            userInputDisplay.font = UIFont(name: "ChalkboardSE-Light", size: userInputDisplay.font!.pointSize + 20)
            userInputDisplay.setContentHuggingPriority(750, forAxis: .Vertical)
            userInputDisplay.numberOfLines = 1
            userInputDisplay.minimumScaleFactor = 0.5
            userInputDisplay.adjustsFontSizeToFitWidth = true
            
        }
    }
    
    private weak var userOutputDispaly: UILabel! {
        didSet{
            userOutputDispaly.translatesAutoresizingMaskIntoConstraints = false
            userOutputDispaly.textAlignment = .Right
            userOutputDispaly.textColor = UIColor.blackColor()
            userOutputDispaly.font = UIFont(name: "Chalkduster", size: userOutputDispaly.font.pointSize + 20)
            userOutputDispaly.numberOfLines = 1
            userOutputDispaly.minimumScaleFactor = 0.5
            userOutputDispaly.adjustsFontSizeToFitWidth = true
            userOutputDispaly.setContentHuggingPriority(700, forAxis: .Vertical)
            
        }
    }
    private weak var commonKeypad: UICollectionView! {
        didSet {
            commonKeypad.translatesAutoresizingMaskIntoConstraints = false
            commonKeypad.dataSource = self
            commonKeypad.delegate = self
            let layout = commonKeypad.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            commonKeypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            commonKeypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            commonKeypad.backgroundColor = UIColor.whiteColor()
            commonKeypad.setContentHuggingPriority(250, forAxis: .Vertical)
            
            portraitConstraints = getPortraitConstraints()
        }
    }
    
    private weak var featureKeypad: UICollectionView! {
        didSet {
            featureKeypad.translatesAutoresizingMaskIntoConstraints = false
            featureKeypad.dataSource = self
            featureKeypad.delegate = self
            let layout = featureKeypad.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            featureKeypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            
            featureKeypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            featureKeypad.setContentHuggingPriority(250, forAxis: .Horizontal)
            featureKeypad.setContentHuggingPriority(255, forAxis: .Vertical)
            featureKeypad.backgroundColor = UIColor.whiteColor()
        }
    }
    
    private weak var functionKeypad: UICollectionView! {
        
        didSet{
            functionKeypad.translatesAutoresizingMaskIntoConstraints = false
            functionKeypad.dataSource = self
            functionKeypad.delegate = self
            let layout = functionKeypad.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            
            functionKeypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            functionKeypad.registerClass(HistoryRecordCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.HistoryCollectionViewCellReusableString)
            functionKeypad.registerClass(GraphicsCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.graphCollectionViewCellReusableString)
            
            functionKeypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            functionKeypad.setContentHuggingPriority(250, forAxis: .Horizontal)
            functionKeypad.backgroundColor = UIColor.whiteColor()
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
        
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Top, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
        
        
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: featureKeypad, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplay, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Left, relatedBy: .Equal, toItem: functionKeypad, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.8, constant: 0))
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.16, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.64, constant: 0))
        
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
        
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.7, constant: 0))
        
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
        commonKeypad = keypad
        
        view.addSubview(inputDisplay)
        view.addSubview(outputDisplay)
        view.addSubview(keypad)
        view.addSubview(menuBtn)
        
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if featureKeypad == nil {
            let keypad = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
            featureKeypad = keypad
            view.addSubview(keypad)
        }
        
        if functionKeypad == nil {
            let keypad = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
            functionKeypad = keypad
            view.addSubview(keypad)
        }
        
        
        if isPortraitMode() {
            // portrait mode
            NSLayoutConstraint.deactivateConstraints(landscapeConstraints)
            NSLayoutConstraint.activateConstraints(portraitConstraints)
            functionKeypad.hidden = true
        } else {
            // landscape mode
            NSLayoutConstraint.deactivateConstraints(portraitConstraints)
            NSLayoutConstraint.activateConstraints(landscapeConstraints)
            functionKeypad.hidden = false
        }
        // update collection view's layout
        functionKeypad.collectionViewLayout.invalidateLayout()
        functionKeypad.collectionViewLayout.invalidateLayout()
        commonKeypad.collectionViewLayout.invalidateLayout()
        
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
                case "CommonKeys":
                    commonKeys = keys
                case "FeatureKeys":
                    featureKeys = keys
                case "TrigonometricKeys":
                    trigonometricKeys = keys
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
                    case "CommonKeys":
                        commonKeys = keys
                    case "FeatureKeys":
                        featureKeys = keys
                    case "TrigonometricKeys":
                        trigonometricKeys = keys
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
extension CalculatorViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {  return 1 }
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case commonKeypad:
            return commonKeys.count
        case featureKeypad:
            return featureKeys.count
        case functionKeypad:
            return functionKeys.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if switcher == 3 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ConstantString.HistoryCollectionViewCellReusableString, forIndexPath: indexPath) as! HistoryRecordCollectionViewCell
            cell.historyRecords = inputExpressionRecords
            return cell
        }
        
        if switcher == 4 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ConstantString.graphCollectionViewCellReusableString, forIndexPath: indexPath) as! GraphicsCollectionViewCell
            cell.inputExpression = lexicalFullString
            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ConstantString.collectionViewCellReusableString, forIndexPath: indexPath) as! KeypadCollectionViewCell
        
        switch collectionView {
        case commonKeypad:
            cell.key = commonKeys[indexPath.item]
        case featureKeypad:
            cell.key = featureKeys[indexPath.item]
        case functionKeypad:
            cell.key = functionKeys[indexPath.item]
        default:
            break
        }
        
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
extension CalculatorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if switcher == 3 || switcher == 4 { return CGSize(width: collectionView.bounds.size.width - 8, height: collectionView.bounds.size.height - 8) }
        
        var rows: CGFloat = 0
        var columns: CGFloat = 0
        
        switch collectionView {
        case commonKeypad:
            rows = commonKeypadRows
            columns = commonKeypadColumns
        case featureKeypad:
            rows = featureKeypadRows
            columns = featureKeypadColumns
        case functionKeypad:
            rows = functionKeypadRows
            columns = functionKeypadColumns
        default:
            break
        }
        
        let collectionViewSize = collectionView.bounds.size
        let itemWidth = ( collectionViewSize.width - columns - 1 ) / columns
        let itemHeight = (collectionViewSize.height - rows - 1) / rows

        let sz = CGSize(width: itemWidth, height: itemHeight)
        return sz
    }
    
}

// MARK: - UICollectionViewDelegate Implementation
extension CalculatorViewController: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var keys = [Key]()
        switch collectionView {
        case commonKeypad:
            keys = commonKeys
        case featureKeypad:
            keys = featureKeys
        case functionKeypad:
            keys = functionKeys
            if switcher == 4 {
                if lexicalFullString.isEmpty || lexicalFullString == "" { break }
                let presentVC = DrawingViewController(WithExpression: lexicalFullString)
                presentViewController(presentVC, animated: true, completion: nil)
                return
            }
        default:
            break
        }
        
        let key = keys[indexPath.item]
        switch key.lexicalString {
        case "=":
            var resultString = brain.getResultStringWithLexicalString(lexicalFullString)
            if let resultFloat = Double(resultString) {
                let resultInt = Int(resultFloat)
                if Double(resultInt) - resultFloat == 0 {
                    resultString = "\(resultInt)"
                }
            }
            inputExpressionRecords.append((displayString: displayFullString, lexicalString: lexicalFullString, result: resultString))
            userOutputDispaly.text = resultString
            functionKeypad.reloadData()
            return
        case "AC":
            displayStrings.removeAll()
            lexicalStrings.removeAll()
            userOutputDispaly.text = ""
        case "<-":
            if !displayStrings.isEmpty { displayStrings.removeLast() }
            if !lexicalStrings.isEmpty { lexicalStrings.removeLast() }
        case "TF":
            switcher = 0
            functionKeypad.reloadData()
        case "Hst":
            print(inputExpressionRecords)
            switcher = 3
            functionKeypad.reloadData()
        case "Ots":
            switcher = 1
            functionKeypad.reloadData()
        case "CF":
            switcher = 2
            functionKeypad.reloadData()
        case "Gph":
            switcher = 4
            functionKeypad.reloadData()
            
        default:
            displayStrings.append(key.displayString)
            lexicalStrings.append(key.lexicalString)
        }
        
        
        userInputDisplay.text = displayFullString
    }
}


















