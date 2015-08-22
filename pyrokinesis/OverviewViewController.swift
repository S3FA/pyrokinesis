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
    var updateTimer: NSTimer? = nil
    
    var currPlots = [CPTScatterPlot]()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.overviewViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()

        // Create the muse graph
        self.museGraph = CPTXYGraph(frame: self.graphView.bounds)
        self.graphView.allowPinchScaling = true
        self.museGraph.applyTheme(CPTTheme(named: kCPTPlainBlackTheme))
        self.graphView.hostedGraph = self.museGraph
        
        self.museGraph.borderWidth = 0.0
        self.museGraph.borderLineStyle = nil
        self.museGraph.borderColor = CPTColor.clearColor().cgColor
        
        self.museGraph.plotAreaFrame.borderWidth = 0.0
        self.museGraph.plotAreaFrame.borderLineStyle = nil
        self.museGraph.plotAreaFrame.borderColor = CPTColor.clearColor().cgColor
        self.museGraph.plotAreaFrame.paddingLeft = 25.0
        self.museGraph.plotAreaFrame.paddingRight = 5.0
        self.museGraph.plotAreaFrame.paddingBottom = 15.0
        self.museGraph.plotAreaFrame.paddingTop = 5.0
        
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
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateGraphAndStatus"), userInfo: nil, repeats: true)
        }
        
        self.updateGraphAndStatus()
        self.updateSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    
    private func configurePlots() {
        var plotSpace = self.museGraph.defaultPlotSpace as! CPTXYPlotSpace

        var yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        yRange.setLengthFloat(1.0)
        plotSpace.yRange = yRange
        
        var xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        xRange.setLengthFloat(Float(MuseListener.MAX_CACHED_VALUES/OverviewViewController.MUSE_DATA_DIV))
        plotSpace.xRange = xRange
    }
    
    private func generatePlotTitle(plotType: IXNMuseDataPacketType) -> String {
        switch (plotType) {
            case IXNMuseDataPacketType.AlphaScore:
                return "Alpha"
            case IXNMuseDataPacketType.BetaScore:
                return "Beta"
            case IXNMuseDataPacketType.DeltaScore:
                return "Delta"
            case IXNMuseDataPacketType.ThetaScore:
                return "Theta"
            case IXNMuseDataPacketType.GammaScore:
                return "Gamma"
            case IXNMuseDataPacketType.Mellow:
                return "Mellow"
            case IXNMuseDataPacketType.Concentration:
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
        var x = axisSet.axisForCoordinate(CPTCoordinate.X, atIndex: 0)
        
        x.labelingPolicy = CPTAxisLabelingPolicy.None
        x.axisLineStyle = nil
        
        for label in x.axisLabels {
            if let axisLabel = label as? CPTAxisLabel {
                axisLabel.contentLayer.hidden = true
            }
        }
        
        // Y-Axis
        var y = axisSet.axisForCoordinate(CPTCoordinate.Y, atIndex: 0)
        
        y.axisLineStyle = nil
        y.majorGridLineStyle = majorGridLineStyle
        y.minorGridLineStyle = minorGridLineStyle
        y.majorTickLineStyle = nil
        y.minorTickLineStyle = nil
        
        y.labelingPolicy = CPTAxisLabelingPolicy.None
        y.labelTextStyle = axisTextStyle
        y.labelOffset = 16.0

        y.majorTickLength = 8.0;
        y.minorTickLength = 4.0;
        y.tickDirection = CPTSign.Positive;
        
        var yLabels = Set<NSObject>()
        var minorTickLocations = Set<NSObject>()
        var majorTickLocations = Set<NSObject>()
        
        for (var i = 0; i <= 10; i++) {
            let tickValue = Double(i)*0.1
            
            var tempLabel = CPTAxisLabel(text: "\(tickValue)", textStyle: y.labelTextStyle)
            tempLabel.tickLocation = CPTDecimalFromDouble(tickValue)
            tempLabel.offset = -y.majorTickLength - y.labelOffset
            yLabels.insert(tempLabel)
            
            if (i % 10 == 0) {
                majorTickLocations.insert(NSDecimalNumber(double: tickValue))
            }
            else {
                minorTickLocations.insert(NSDecimalNumber(double: tickValue))
            }
        }
        
        y.axisLabels = yLabels
        y.minorTickLocations = minorTickLocations
        y.majorTickLocations = majorTickLocations

    }
    
    func updateGraphAndStatus() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            if museListener.dataUpdated {
                self.museGraph.reloadData()
                museListener.dataUpdated = false
            }

            self.connStatusDetailLabel.text = MuseListener.getConnectionStatusString(museListener.museConnStatus).uppercaseString
            self.connStatusLabel.text = museListener.isMuseAvailable() ? "FOUND" : "NOT FOUND"
            
            var score = museListener.avgHorseshoeValue()
            self.signalLabel.text = MuseListener.getSignalStrengthString(score).uppercaseString
            self.signalDetailLabel.text = MuseListener.getSignalDetailString(score).uppercaseString
            
            switch (museListener.museConnStatus) {
            case .Connected:
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
            self.gameModeLabel.text = settings.gameMode.uppercaseString + " MODE"
            
            // The data present in the graph will be based off the game mode...
            if let gameMode = PyrokinesisSettings.GameMode(rawValue: settings.gameMode) {
                
                var plotSpace = self.museGraph.defaultPlotSpace as! CPTXYPlotSpace
                var trackedTypesAndColours = [IXNMuseDataPacketType: (CPTColor, CPTColor)]()
                
                switch (gameMode) {
                    case .Calm:
                        trackedTypesAndColours.updateValue((CPTColor(componentRed: 0.0, green: 0.5, blue: 0.5, alpha: 1.0), CPTColor.blueColor()), forKey: .AlphaScore)
                        trackedTypesAndColours.updateValue((CPTColor.cyanColor(), CPTColor(componentRed: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)), forKey: .Mellow)
                        break
                    
                    case .Concentration:
                        trackedTypesAndColours.updateValue((CPTColor.orangeColor(), CPTColor.redColor()), forKey: .BetaScore)
                        trackedTypesAndColours.updateValue((CPTColor.yellowColor(), CPTColor.orangeColor()), forKey: .Concentration)
                        break
                    
                    default:
                        assert(false)
                        return
                }
                
                for plot in self.currPlots {
                    self.museGraph.removePlot(plot)
                }
                self.currPlots.removeAll(keepCapacity: true)
                
                // Create a plot for each type of data coming from the muse that we're interested in visualizing
                let LINE_WIDTH  = CGFloat(2.0)
                let MARKER_SIZE = CGSizeMake(10.0, 10.0)
                
                for (type, (lineColor, markerColor)) in trackedTypesAndColours {
                    
                    var scatterPlot = CPTScatterPlot(frame: CGRectZero)
                    scatterPlot.dataSource = self
                    scatterPlot.identifier = type.rawValue
                    scatterPlot.title = self.generatePlotTitle(type)
                    
                    var lineStyle = scatterPlot.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
                    lineStyle.lineWidth = LINE_WIDTH
                    lineStyle.lineColor = lineColor
                    scatterPlot.dataLineStyle = lineStyle
                    
                    var markerLineStyle = scatterPlot.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
                    markerLineStyle.lineWidth = LINE_WIDTH/2.0
                    
                    var markerSymbol = CPTPlotSymbol.ellipsePlotSymbol()
                    markerSymbol.fill = CPTFill(color: markerColor)
                    markerSymbol.lineStyle = markerLineStyle
                    markerSymbol.size = MARKER_SIZE
                    
                    scatterPlot.plotSymbol = markerSymbol
                    
                    self.currPlots.append(scatterPlot)
                    self.museGraph.addPlot(scatterPlot, toPlotSpace: plotSpace)
                }
            }
        }
    }

    // CPTPlotDataSource Functions
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            
            if let plotType = IXNMuseDataPacketType(rawValue: (plot.identifier as! IXNMuseDataPacketType.RawValue)) {
                if let records = museListener.cachedScoreValues[plotType] {
                    return UInt(records.count/OverviewViewController.MUSE_DATA_DIV)
                }
            }
        }
        
        return 0
    }
    
    func doubleForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> Double {
        
        if (Int(fieldEnum) == CPTScatterPlotField.X.rawValue) {
            return Double(idx);
        }
        else if (Int(fieldEnum) == CPTScatterPlotField.Y.rawValue) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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

