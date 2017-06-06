//
//  OverviewViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-14.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController, CPTPlotDataSource {

    @IBOutlet var graphView: CPTGraphHostingView!

    @IBOutlet var connStatusLabel: UILabel!
    @IBOutlet var connStatusDetailLabel: UILabel!
    
    @IBOutlet var signalLabel: UILabel!
    @IBOutlet var signalDetailLabel: UILabel!
    
    @IBOutlet var gameModeLabel: UILabel!
    
    static let MUSE_DATA_DIV: Int = 5
    
    var museGraph: CPTXYGraph!
    var updateTimer: Timer? = nil
    
    var currPlots = [CPTScatterPlot]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.overviewViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()

        // Create the muse graph
        self.museGraph = CPTXYGraph(frame: self.graphView.bounds)
        self.graphView.allowPinchScaling = true
        self.museGraph.apply(CPTTheme(named: CPTThemeName.plainBlackTheme))
        self.graphView.hostedGraph = self.museGraph
        
        self.museGraph.borderWidth = 0.0
        self.museGraph.borderLineStyle = nil
        self.museGraph.borderColor = CPTColor.clear().cgColor
        
        self.museGraph.plotAreaFrame?.borderWidth = 0.0
        self.museGraph.plotAreaFrame?.borderLineStyle = nil
        self.museGraph.plotAreaFrame?.borderColor = CPTColor.clear().cgColor
        self.museGraph.plotAreaFrame?.paddingLeft = 25.0
        self.museGraph.plotAreaFrame?.paddingRight = 5.0
        self.museGraph.plotAreaFrame?.paddingBottom = 15.0
        self.museGraph.plotAreaFrame?.paddingTop = 5.0
        
        self.configurePlots()
        self.configureAxes()
        
        /*
        let plotArea = self.museGraph.plotAreaFrame.plotArea
        var textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor(componentRed: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 1)
        textStyle.fontName = "Gotham-Bold"
        textStyle.
        textStyle.textAlignment = CPTTextAlignment.Center
        
        var textLayer = CPTTextLayer(text: "THIS IS A TEST!!!", style: textStyle)
        var textLayerSize = textLayer.sizeThatFits()
        textLayer.bounds = CGRectMake(0, 0, textLayerSize.width, textLayerSize.height)
        
        
        var paBounds = self.museGraph.bounds
        
        var halfWidth = paBounds.size.width/2
        var halfHeight = paBounds.size.height/2
        
        textLayer.position = CGPointMake(halfWidth, 150)

        var annotation = CPTAnnotation()
        annotation.contentLayer = textLayer
        
        plotArea.addAnnotation(annotation)
        */
        
        if self.updateTimer == nil {
            self.updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(OverviewViewController.updateGraphAndStatus), userInfo: nil, repeats: true)
        }
        
        self.updateGraphAndStatus()
        self.updateSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    
    fileprivate func configurePlots() {
        let plotSpace = self.museGraph.defaultPlotSpace as! CPTXYPlotSpace

        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        yRange.setLengthFloat(1.0)
        plotSpace.yRange = yRange
        
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        xRange.setLengthFloat(Float(MuseListener.MAX_CACHED_VALUES/OverviewViewController.MUSE_DATA_DIV))
        plotSpace.xRange = xRange
    }
    
    fileprivate func generatePlotTitle(_ plotType: IXNMuseDataPacketType) -> String {
        switch (plotType) {
            case IXNMuseDataPacketType.alphaScore:
                return "Alpha"
            case IXNMuseDataPacketType.betaScore:
                return "Beta"
            case IXNMuseDataPacketType.deltaScore:
                return "Delta"
            case IXNMuseDataPacketType.thetaScore:
                return "Theta"
            case IXNMuseDataPacketType.gammaScore:
                return "Gamma"
            case IXNMuseDataPacketType.mellow:
                return "Mellow"
            case IXNMuseDataPacketType.concentration:
                return "Concentration"
            default:
                assert(false)
                return ""
        }
    }
    
    func configureAxes() {
        let FONT_GRAY = CPTColor(componentRed: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1)
        
        var axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = FONT_GRAY
        axisTextStyle.fontName = "Gotham-Book";
        axisTextStyle.fontSize = 11.0;
        
        var majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 1.0;
        majorGridLineStyle.lineColor = CPTColor(componentRed: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
        
        var minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.75;
        minorGridLineStyle.lineColor = CPTColor(componentRed: 35/255.0, green: 35/255.0, blue: 35/255.0, alpha: 1)
        
        var axisSet = self.museGraph.axisSet
        
        // X-Axis
        var x = axisSet?.axis(for: CPTCoordinate.X, at: 0)
        
        x?.labelingPolicy = CPTAxisLabelingPolicy.none
        x?.axisLineStyle = nil
        
        for label in (x?.axisLabels)! {
            if let axisLabel = label as? CPTAxisLabel {
                axisLabel.contentLayer?.isHidden = true
            }
        }
        
        // Y-Axis
        var y = axisSet?.axis(for: CPTCoordinate.Y, at: 0)
        
        y?.axisLineStyle = nil
        y?.majorGridLineStyle = majorGridLineStyle
        y?.minorGridLineStyle = minorGridLineStyle
        y?.majorTickLineStyle = nil
        y?.minorTickLineStyle = nil
        
        y?.labelingPolicy = CPTAxisLabelingPolicy.none
        y?.labelTextStyle = axisTextStyle
        y?.labelOffset = 16.0

        y?.majorTickLength = 8.0;
        y?.minorTickLength = 4.0;
        y?.tickDirection = CPTSign.positive;
        
        var yLabels = Set<NSObject>()
        var minorTickLocations = Set<NSObject>()
        var majorTickLocations = Set<NSObject>()
        
        for i in 0...10 {
            let tickValue = Double(i)*0.1
            
            let tempLabel = CPTAxisLabel(text: "\(tickValue)", textStyle: y?.labelTextStyle)
            tempLabel.tickLocation = NSNumber(value:tickValue)
            tempLabel.offset = -y!.majorTickLength - y!.labelOffset
            yLabels.insert(tempLabel)
            
            if (i % 10 == 0) {
                majorTickLocations.insert(NSDecimalNumber(value: tickValue as Double))
            }
            else {
                minorTickLocations.insert(NSDecimalNumber(value: tickValue as Double))
            }
        }
        
        y?.axisLabels = yLabels as! Set<CPTAxisLabel>
        y?.minorTickLocations = minorTickLocations as! Set<NSNumber>
        y?.majorTickLocations = majorTickLocations as! Set<NSNumber>

    }
    
    func updateGraphAndStatus() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            if museListener.dataUpdated {
                self.museGraph.reloadData()
                museListener.dataUpdated = false
            }

            self.connStatusDetailLabel.text = MuseListener.getConnectionStatusString(museListener.museConnStatus).uppercased()
            self.connStatusLabel.text = museListener.isMuseAvailable() ? "FOUND" : "NOT FOUND"
            
            var score = museListener.avgHorseshoeValue()
            self.signalLabel.text = MuseListener.getSignalStrengthString(score).uppercased()
            self.signalDetailLabel.text = MuseListener.getSignalDetailString(score).uppercased()
            
            switch (museListener.museConnStatus) {
            case .connected:
                if score >= MuseListener.WORST_HORSESHOE_SCORE {
                    // Overlay on graph that the connection with the muse is too horrible to stream data
                    
                }
                break
                
            default:
                // No data!
                break
            }
        }
    }
    
    func updateSettings() {
        if let settings = PyrokinesisSettings.getSettings() {
            self.gameModeLabel.text = settings.gameMode.uppercased() + " MODE"
            
            // The data present in the graph will be based off the game mode...
            if let gameMode = PyrokinesisSettings.GameMode(rawValue: settings.gameMode) {
                
                let plotSpace = self.museGraph.defaultPlotSpace as! CPTXYPlotSpace
                var trackedTypesAndColours = [IXNMuseDataPacketType: (CPTColor, CPTColor)]()
                
                switch (gameMode) {
                    case .Calm:
                        trackedTypesAndColours.updateValue((CPTColor(componentRed: 0.0, green: 0.5, blue: 0.5, alpha: 1.0), CPTColor.blue()), forKey: .alphaScore)
                        trackedTypesAndColours.updateValue((CPTColor.cyan(), CPTColor(componentRed: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)), forKey: .mellow)
                        break
                    
                    case .Concentration:
                        trackedTypesAndColours.updateValue((CPTColor.orange(), CPTColor.red()), forKey: .betaScore)
                        trackedTypesAndColours.updateValue((CPTColor.yellow(), CPTColor.orange()), forKey: .concentration)
                        break
                    
                    default:
                        assert(false)
                        return
                }
                
                for plot in self.currPlots {
                    self.museGraph.remove(plot)
                }
                self.currPlots.removeAll(keepingCapacity: true)
                
                // Create a plot for each type of data coming from the muse that we're interested in visualizing
                let LINE_WIDTH  = CGFloat(2.0)
                let MARKER_SIZE = CGSize(width: 10.0, height: 10.0)
                
                for (type, (lineColor, markerColor)) in trackedTypesAndColours {
                    
                    let scatterPlot = CPTScatterPlot(frame: CGRect.zero)
                    scatterPlot.dataSource = self
                    scatterPlot.identifier = type.rawValue as NSCoding & NSCopying & NSObjectProtocol
                    scatterPlot.title = self.generatePlotTitle(type)
                    
                    let lineStyle = scatterPlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
                    lineStyle.lineWidth = LINE_WIDTH
                    lineStyle.lineColor = lineColor
                    scatterPlot.dataLineStyle = lineStyle
                    
                    let markerLineStyle = scatterPlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
                    markerLineStyle.lineWidth = LINE_WIDTH/2.0
                    
                    let markerSymbol = CPTPlotSymbol.ellipse()
                    markerSymbol.fill = CPTFill(color: markerColor)
                    markerSymbol.lineStyle = markerLineStyle
                    markerSymbol.size = MARKER_SIZE
                    
                    scatterPlot.plotSymbol = markerSymbol
                    
                    self.currPlots.append(scatterPlot)
                    self.museGraph.add(scatterPlot, to: plotSpace)
                }
            }
        }
    }

    // CPTPlotDataSource Functions
    func numberOfRecords(for plot: CPTPlot!) -> UInt {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            
            if let plotType = IXNMuseDataPacketType(rawValue: (plot.identifier as! IXNMuseDataPacketType.RawValue)) {
                if let records = museListener.cachedScoreValues[plotType] {
                    return UInt(records.count/OverviewViewController.MUSE_DATA_DIV)
                }
            }
        }
        
        return 0
    }
    
    func double(for plot: CPTPlot!, field fieldEnum: UInt, record idx: UInt) -> Double {
        
        if (Int(fieldEnum) == CPTScatterPlotField.X.rawValue) {
            return Double(idx);
        }
        else if (Int(fieldEnum) == CPTScatterPlotField.Y.rawValue) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let museListener = appDelegate.museListener {
                
                if let plotType = IXNMuseDataPacketType(rawValue: (plot.identifier as! IXNMuseDataPacketType.RawValue)) {
                    if let records = museListener.cachedScoreValues[plotType] {
                        assert(idx < UInt(records.count), "Invalid record index found.")
                        return records[Int(idx * UInt(OverviewViewController.MUSE_DATA_DIV))]
                    }
                }
            }
        }
        
        return 0
    }
    
}

