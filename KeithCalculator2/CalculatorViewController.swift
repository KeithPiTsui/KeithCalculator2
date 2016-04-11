//
//  CalculatorProtraitViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - Manage User Interface of Simple and Scientifi calculator

struct InputExpression {
    var displayString: String
    var lexicalString: String
    var resultString: String
    var timestamp: NSDate
    var radianStr: String
}

final class CalculatorViewController: UIViewController {
    
    /**
     constants used by this controller
     */
    private struct ConstantString {
        static let collectionViewCellReusableString: String = "reusable string"
        static let HistoryCollectionViewCellReusableString: String = "history collection view reusable string"
        static let graphCollectionViewCellReusableString: String = "Graph reusable String"
        static let historyTableViewCellReusableString: String = "history table view reusable String"
        static let collectionViewHeaderString: String = "Header String"
        static let keyKindNameScientific = "ScientificKeys"
        static let keyKindNameCommon = "CommonKeys"
        static let keyKindNameFeature = "FeatureKeys"
        static let keyKindNameTrigonometric = "TrigonometricKeys"
        static let keyKindNameExponential = "ExponentialKeys"
        static let keyKindNameOther = "OtherKeys"
        static let keyKindNames = [keyKindNameCommon, keyKindNameFeature, keyKindNameTrigonometric, keyKindNameOther]
        static let userInputDisplayFontName = "ChalkboardSE-Light"
        static let userOutputDisplayFontName = "Chalkduster"
        static let keyConfigureFileName = "Keypad.KCConfig"
        static let sqliteDatabaseName = "KCDB.sqlite"
    }
    
    private let database: FMDatabase = {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent(ConstantString.sqliteDatabaseName)
        let database = FMDatabase(path: fileURL.path)
        return database
    }()
    
    // MARK: rows and columns of keys in Keypad
    private var commonKeypadRows: CGFloat = 5
    private var commonKeypadColumns: CGFloat = 4
    private var featureKeypadRows: CGFloat = 1
    private var featureKeypadColumns: CGFloat = 6
    private var functionKeypadRows: CGFloat = 4
    private var functionKeypadColumns: CGFloat = 6
    
    // MARK: - Demo Pic Names
    private let picNames = ["SCTA.png","SCOTS.png","SCCF.png","SCGraphing.png","SCLog.png"]
    
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
     an array of key for holding feature keys for scientific calculator keypad
     */
    private var featureKeys: [Key] = [Key]() {
        didSet {
            if historyKeys.isEmpty {
                var key = featureKeys[0]
                key.displayString = ""
                key.keypadString = ""
                key.lexicalString = ""
                historyKeys.append(key)
            }
            
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
    enum KeypadFunctionTab: Int {
        case TrigonometricAndArithmeticFunctions
        case OtherFunctions
        case CustomisedFunctions
        case HistoryInputExpression
        case FormulaGraphicPreview
    }
    
    private var switcher: KeypadFunctionTab = .TrigonometricAndArithmeticFunctions
    private var functionKeys:[Key] {
        switch switcher {
        case .TrigonometricAndArithmeticFunctions:
            return trigonometricKeys
        case .OtherFunctions:
            return otherKeys
        case .CustomisedFunctions:
            return customFunctionKeys
        case .HistoryInputExpression:
            return historyKeys
        case .FormulaGraphicPreview:
            return historyKeys
        }
    }
    
    // MARK: - Expression display string and lexical string
    private var displayStrings = [String]()
    private var lexicalStrings = [String]()
    private var displayFullString: String { return displayStrings.reduce(""){$0 + $1} }
    private var lexicalFullString: String { return lexicalStrings.reduce(""){$0 + $1} }
    
    private var lastLexicalFullString: String = "No Lexical String"
    
    private var inputExpressionRecords: [InputExpression] = [InputExpression]()
    
    // MARK: - UI elements and customizing in didSet observor
    
    private weak var userInputDisplayContainer: UIScrollView! {
        didSet{
            userInputDisplayContainer.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private weak var userInputDisplay: UILabel! {
        didSet {
            userInputDisplay.translatesAutoresizingMaskIntoConstraints = false
            userInputDisplay.textAlignment = .Right
            userInputDisplay.textColor = UIColor.lightGrayColor()
            userInputDisplay.setContentHuggingPriority(750, forAxis: .Vertical)
            userInputDisplay.numberOfLines = 1
            userInputDisplay.text = "Hello"
            //userInputDisplay.backgroundColor = UIColor.greenColor()
            userInputDisplay.font = UIFont(name: ConstantString.userInputDisplayFontName, size: userInputDisplay.font.pointSize + 20)
        }
    }
    
    private weak var userOutputDispaly: UILabel! {
        didSet{
            userOutputDispaly.translatesAutoresizingMaskIntoConstraints = false
            userOutputDispaly.textAlignment = .Left
            userOutputDispaly.textColor = UIColor.blackColor()
            userOutputDispaly.font = UIFont(name: ConstantString.userOutputDisplayFontName, size: userOutputDispaly.font.pointSize + 20)
            userOutputDispaly.numberOfLines = 1
            userOutputDispaly.minimumScaleFactor = 0.3
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
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
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
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            featureKeypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            
            featureKeypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            featureKeypad.setContentHuggingPriority(250, forAxis: .Horizontal)
            featureKeypad.setContentHuggingPriority(255, forAxis: .Vertical)
            featureKeypad.backgroundColor = UIColor.whiteColor()
            
            let lp = UILongPressGestureRecognizer(target: self, action: #selector(CalculatorViewController.demo(_:)))
            featureKeypad.addGestureRecognizer(lp)
        }
    }
    
    private weak var functionKeypad: UICollectionView! {
        
        didSet{
            functionKeypad.translatesAutoresizingMaskIntoConstraints = false
            functionKeypad.dataSource = self
            functionKeypad.delegate = self

            let layout = functionKeypad.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            
            functionKeypad.registerClass(KeypadCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.collectionViewCellReusableString)
            functionKeypad.registerClass(HistoryRecordCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.HistoryCollectionViewCellReusableString)
            functionKeypad.registerClass(GraphicsCollectionViewCell.self, forCellWithReuseIdentifier: ConstantString.graphCollectionViewCellReusableString)
            
            functionKeypad.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ConstantString.collectionViewHeaderString)
            functionKeypad.setContentHuggingPriority(250, forAxis: .Horizontal)
            functionKeypad.backgroundColor = UIColor.whiteColor()
            landscapeConstraints = getLandscapeContraints()
            let lp = UILongPressGestureRecognizer(target: self, action: #selector(CalculatorViewController.enterDeleteMode(_:)))
            functionKeypad.addGestureRecognizer(lp)
        }
    }
    

    // MARK: - History Expression Table view
    
    private lazy var historyTableView: UITableView = {
        let tb = UITableView()
        tb.registerClass(UITableViewCell.self, forCellReuseIdentifier: ConstantString.historyTableViewCellReusableString)
        tb.dataSource = self
        tb.delegate =  self
        return tb
    }()
    
    // MARK: - Auto layout constraints construction
    /**
     construct a set of auto layout constraints for landscape UI
     */
    private func getLandscapeContraints() -> [NSLayoutConstraint]{
        // configure lanscapeKeypad's layout constraints
        var constraints = [NSLayoutConstraint]()
        

        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .CenterY, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Right, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Right, multiplier: 1, constant: 0))

        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Right, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Top, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
        
        
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: featureKeypad, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Left, relatedBy: .Equal, toItem: functionKeypad, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.8, constant: 0))
        constraints.append(NSLayoutConstraint(item: featureKeypad, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.16, constant: 0))
        constraints.append(NSLayoutConstraint(item: functionKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.64, constant: 0))
        
        return constraints
    }
    
    /**
     construct a set of auto layout constraints for portrait UI
     */
    private func getPortraitConstraints() -> [NSLayoutConstraint] {
        var constraints = Array<NSLayoutConstraint>()
        
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .CenterY, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Left, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplay, attribute: .Right, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Right, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Top, relatedBy: .Equal, toItem: userInputDisplayContainer, attribute: .Bottom, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Top, relatedBy: .Equal, toItem: userOutputDispaly, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: userInputDisplayContainer, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.2, constant: 0))
        constraints.append(NSLayoutConstraint(item: userOutputDispaly, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0))
        constraints.append(NSLayoutConstraint(item: commonKeypad, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.7, constant: 0))
        
        return constraints
    }

    
    // MARK: - View controller life cycle function
    override func prefersStatusBarHidden() -> Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readKeypadSpecificationBySwiftyJSON()
        loadCustomisedFunctionKeys()
        loadInputExpressionRecords()
        view.backgroundColor = UIColor.whiteColor()
        
        let sv = UIScrollView()
        userInputDisplayContainer = sv
        //sv.backgroundColor = UIColor.blueColor()
        
        let inputDisplay = UILabel()
        userInputDisplay = inputDisplay
        let outputDisplay = UILabel()
        userOutputDispaly = outputDisplay
        let keypad = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        commonKeypad = keypad
        
        
        
        sv.addSubview(inputDisplay)
        
        view.addSubview(sv)
        view.addSubview(outputDisplay)
        view.addSubview(keypad)
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
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
            featureKeypad.hidden = true
            
            
            
        } else {
            // landscape mode
            NSLayoutConstraint.deactivateConstraints(portraitConstraints)
            NSLayoutConstraint.activateConstraints(landscapeConstraints)
            functionKeypad.hidden = false
            featureKeypad.hidden = false
        }
        // update collection view's layout
        functionKeypad.collectionViewLayout.invalidateLayout()
        featureKeypad.collectionViewLayout.invalidateLayout()
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
    
    // MARK: - Helper function for read key specification
    
    /**
     read key specification of JSON via Swifty json framework
     */
    private func readKeypadSpecificationBySwiftyJSON() {
        
        guard let specPath = NSBundle.mainBundle().pathForResource(ConstantString.keyConfigureFileName, ofType: nil) else { return }
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
                case ConstantString.keyKindNameCommon:
                    commonKeys = keys
                case ConstantString.keyKindNameFeature:
                    featureKeys = keys
                case ConstantString.keyKindNameTrigonometric:
                    trigonometricKeys = keys
                case ConstantString.keyKindNameOther:
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
    
    /**
     load custom function keys
     */
    
    private func loadCustomisedFunctionKeys() {
        customFunctionKeys.removeAll()
        loadCustomFunctions()
        var i = 0
        for keyName in FunctionUtilities.customizedFunction.keys {
            let initialIndex = keyName.startIndex.advancedBy(2)
            let shortName = keyName.substringWithRange(initialIndex ..< keyName.endIndex)
            let key = Key(displayStr: shortName+"(", lexicalStr: keyName+"#LEFTPARENTHESIS#", keypadStr: shortName, positionIndex: i, preferColor: UIColor(red: 165/255, green: 49/255, blue: 166/255, alpha: 1), preferFont: nil)
            customFunctionKeys.append(key)
            i += 1
        }
        // a key for adding new custom function
        customFunctionKeys.append(Key(displayStr: "ACF", lexicalStr: "ACF", keypadStr: "CF+", positionIndex: 100, preferColor: UIColor(red: 165/255, green: 49/255, blue: 166/255, alpha: 1), preferFont: nil))

    }
    
    // MARK: - Helper function for recording customize function
    private func setCustomFunction(name: String, withDefinitionTokens definitionTokens: [Token], andLexicalString lexicalStr: String) {
        if name.isEmpty || name == "" || definitionTokens.isEmpty { return }
        let cfName = "CF" + name
        FunctionUtilities.customizedFunction[cfName] = definitionTokens
        storeCustomFunctionWithName(cfName, andLexicalString: lexicalStr)
    }
    
    private func loadCustomFunctions(){
        if !database.open() {
            return
        }
        do {
            let rs = try database.executeQuery("select name, lexicalString from CustomizedFunctions", values: nil)
            while rs.next() {
                let name = rs.stringForColumn("name")
                let lexical = rs.stringForColumn("lexicalString")
                FunctionUtilities.customizedFunction[name] = Scanner().getTokensWithLexicalString(lexical)
            }
        } catch _ as NSError {
        }
        
        database.close()
    }
    
    private func storeCustomFunctionWithName(name: String, andLexicalString lexical: String){
        if !database.open() {
            return
        }
        do {
            try database.executeUpdate("create table if not exists CustomizedFunctions(name text, lexicalString text)", values: nil)
            try database.executeUpdate("insert into CustomizedFunctions (name, lexicalString) values (?, ?)", values: [name, lexical])

        } catch _ as NSError {
        }
        
        database.close()
    }
    
    private func deleteCustomFunctionWithName(name: String){
        if !database.open() {
            return
        }
        do {
            try database.executeUpdate("delete from CustomizedFunctions where name = ?", values: [name])
            
        } catch _ as NSError {
        }
        database.close()
    }
    
    // MARK: - Helper function for recording input expressions
    private func recordInputExpressionWithResultString(resultStr: String){
        let record = InputExpression(displayString: displayFullString, lexicalString: lexicalFullString, resultString: resultStr, timestamp: NSDate(), radianStr: FunctionUtilities.isRadians ? "Rad":"Agl")
        inputExpressionRecords.insert(record, atIndex: 0)
        let indexpath = NSIndexPath(forRow: 0, inSection: 0)
        historyTableView.insertRowsAtIndexPaths([indexpath], withRowAnimation: .Automatic)
        
        storeLastInputExpressionRecords()
    }
    
    private func loadInputExpressionRecords(){
        inputExpressionRecords.removeAll()
        if !database.open() {
            return
        }
        do {
            let rs = try database.executeQuery("select DisplayString, LexicalString, ResultString, seconds, radianString from InputExpression order by seconds desc", values: nil)
            while rs.next() {
                let display = rs.stringForColumn("DisplayString")
                let lexical = rs.stringForColumn("LexicalString")
                let result = rs.stringForColumn("ResultString")
                let seconds = rs.doubleForColumn("seconds")
                let radianString = rs.stringForColumn("radianString")
                
                let record = InputExpression(displayString: display, lexicalString: lexical, resultString: result, timestamp: NSDate(timeIntervalSinceReferenceDate: seconds), radianStr: radianString)
                inputExpressionRecords.append(record)
                
            }
        } catch _ as NSError {
        }
        
        database.close()
    }
    
    private func storeLastInputExpressionRecords(){
        if !database.open() {
            return
        }
        do {
            try database.executeUpdate("create table if not exists InputExpression(DisplayString text, LexicalString text, ResultString text, seconds float, radianString text)", values: nil)
            if let record = inputExpressionRecords.first {
                try database.executeUpdate("insert into InputExpression (DisplayString, LexicalString, ResultString, seconds, radianString) values (?, ?, ?, ?, ?)", values: [record.displayString, record.lexicalString, record.resultString, Double(record.timestamp.timeIntervalSinceReferenceDate), record.radianStr])
            }
        } catch _ as NSError {
        }
        
        database.close()
    }
    
    private func deleteInputExpressionRecordOfCreatedTime(time: NSDate) {
        if !database.open() {
            return
        }
        do {
            try database.executeUpdate("delete from InputExpression where seconds = ?", values: [Double(time.timeIntervalSinceReferenceDate)])
        } catch _ as NSError {
        }
        
        database.close()
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
        
        if switcher == .HistoryInputExpression && collectionView == functionKeypad {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ConstantString.HistoryCollectionViewCellReusableString, forIndexPath: indexPath) as! HistoryRecordCollectionViewCell
            cell.historyViewer = historyTableView
            return cell
        }
        
        if switcher == .FormulaGraphicPreview && collectionView == functionKeypad {
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
        
        if (switcher == .HistoryInputExpression && collectionView == functionKeypad)
            || (switcher == .FormulaGraphicPreview && collectionView == functionKeypad) {
            return CGSize(width: collectionView.bounds.size.width - 8, height: collectionView.bounds.size.height - 8) }
        
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
//        let itemWidth = ( collectionViewSize.width - columns - 1 ) / columns
//        let itemHeight = (collectionViewSize.height - rows - 1) / rows
        let itemWidth = collectionViewSize.width / columns
        let itemHeight = collectionViewSize.height / rows
        
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
            if switcher == .FormulaGraphicPreview {
                if lexicalFullString.isEmpty || lexicalFullString == "" { return }
                let presentVC = DrawingViewController(WithExpression: lexicalFullString)
                presentViewController(presentVC, animated: true, completion: nil)
                return
            }
            keys = functionKeys
        default:
            break
        }
        
        let key = keys[indexPath.item]
        switch key.lexicalString {
        case "=":
            var resultString = brain.getResultStringWithLexicalString(lexicalFullString)
            if let resultFloat = Double(resultString) where resultFloat.isNormal || resultFloat.isZero {
                let resultInt = Int(resultFloat)
                if Double(resultInt) - resultFloat == 0 {
                    resultString = "\(resultInt)"
                }
            }
            recordInputExpressionWithResultString(resultString)
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
            switcher = .TrigonometricAndArithmeticFunctions
            functionKeypad.reloadData()
        case "Hst":
            switcher = .HistoryInputExpression
            functionKeypad.reloadData()
        case "Ots":
            switcher = .OtherFunctions
            functionKeypad.reloadData()
        case "CF":
            switcher = .CustomisedFunctions
            functionKeypad.reloadData()
        case "Gph":
            switcher = .FormulaGraphicPreview
            functionKeypad.reloadData()
        case "ACF":
            let alert = UIAlertController(title: "Enter a name", message: nil, preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler {
                $0.keyboardType = .Default
                $0.placeholder = "function name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            func handler(act: UIAlertAction) {
                let tf = alert.textFields![0]
                if let cfName = tf.text {
                    if let symbol = Token.regconizedSymbol(cfName) where symbol == Token.IDENTIFIER("") {
                        let scanner = Scanner()
                        setCustomFunction(cfName, withDefinitionTokens:scanner.getTokensWithLexicalString(lexicalFullString), andLexicalString: lexicalFullString)
                        loadCustomisedFunctionKeys()
                        functionKeypad.reloadData()
                    } else {
                        userOutputDispaly.text = "All alphabet Please"
                    }
                }
            }
            
            alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: handler))
            //alert.view.setNeedsLayout()
            self.presentViewController(alert, animated: true, completion: nil)
        case "Rad":
            FunctionUtilities.isRadians = !FunctionUtilities.isRadians
            lastLexicalFullString = ""
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! KeypadCollectionViewCell
            var key =  cell.key
            key?.keypadString = FunctionUtilities.isRadians ? "Rad":"Agl"
            cell.key = key
            cell.contentView.setNeedsDisplay()
            
        default:
            displayStrings.append(key.displayString)
            lexicalStrings.append(key.lexicalString)
        }
        
        
        userInputDisplay.text = displayFullString
        userInputDisplay.sizeToFit()
        
        let offset = userInputDisplay.frame.size.width - userInputDisplayContainer.frame.size.width
        if offset > 0 {
            userInputDisplayContainer.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        } else {
            userInputDisplayContainer.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
    }
    
}


// MARK: - historical list data source protocol
extension CalculatorViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputExpressionRecords.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ConstantString.historyTableViewCellReusableString, forIndexPath: indexPath)
        let record = inputExpressionRecords[indexPath.row]
        cell.textLabel?.text = "[\(record.radianStr)]:\(record.displayString) = \(record.resultString)"
        cell.textLabel?.textColor = UIColor.brownColor()
        return cell
    }
}
// MARK: - historical list delegate protocol
extension CalculatorViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let record = inputExpressionRecords[indexPath.row]
        displayStrings = [record.displayString]
        lexicalStrings = [record.lexicalString]
        userOutputDispaly.text = record.resultString
        userInputDisplay.text = record.displayString
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            deleteInputExpressionRecordOfCreatedTime(inputExpressionRecords[indexPath.row].timestamp)
            inputExpressionRecords.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        default:
            break
        }
    }

}

// MARK: - implement a long press gesture to delete a custom function in function keypad
extension CalculatorViewController {
    
    func enterDeleteMode(lpg: UILongPressGestureRecognizer) {
        if lpg.state == UIGestureRecognizerState.Began {
            if switcher == .CustomisedFunctions {
                if let indexPath = functionKeypad.indexPathForItemAtPoint(lpg.locationInView(functionKeypad)) {
                    let key = customFunctionKeys[indexPath.item]
                    if key.lexicalString != "ACF" {
                        let alert = UIAlertController(title: "Delete Custom Funciton \(key.keypadString)", message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        func handler(act: UIAlertAction) {
                            customFunctionKeys.removeAtIndex(indexPath.item)
                            deleteCustomFunctionWithName("CF"+key.keypadString)
                            functionKeypad.reloadData()
                            displayStrings.removeAll()
                            lexicalStrings.removeAll()
                            userInputDisplay.text = ""
                            userOutputDispaly.text = ""
                        }
                        alert.addAction(
                            UIAlertAction(title: "Done", style: .Default, handler: handler)
                        )
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                
            }
        }
    }
}

// MARK: - implement a long press gesture to demostrate how to use specific function
extension CalculatorViewController {
    func demo(lpg: UILongPressGestureRecognizer) {
        if lpg.state == UIGestureRecognizerState.Began {
            let lc = lpg.locationInView(featureKeypad)
            if let indexPath = featureKeypad.indexPathForItemAtPoint(lc) {
                if indexPath.item < 0 || indexPath.item >= picNames.count { return }
                
                let pvc = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
                let page = DemoViewController(Demo: picNames[indexPath.item])
                pvc.setViewControllers([page], direction: .Forward, animated: false, completion: nil)
                pvc.dataSource = self
                let proxy = UIPageControl.appearance()
                proxy.pageIndicatorTintColor = UIColor.lightGrayColor()
                proxy.currentPageIndicatorTintColor = UIColor.darkGrayColor()
                
                presentViewController(pvc, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Implementation of UIPageViewControllerDataSource
extension CalculatorViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pic = (viewController as! DemoViewController).picName
        let ix = picNames.indexOf(pic)! - 1
        if ix < 0 {
            return nil
        }
        
        return DemoViewController(Demo: picNames[ix])
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let pic = (viewController as! DemoViewController).picName
        let ix = picNames.indexOf(pic)! + 1
        if ix >= picNames.count {
            return nil
        }
        
        return DemoViewController(Demo: picNames[ix])
    }
}











