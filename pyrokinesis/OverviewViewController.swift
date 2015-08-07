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
    @IBOutlet var signalLabel: UILabel!
    
    var museGraph: CPTXYGraph!
    var updateTimer: NSTimer? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        // Create the muse graph
        self.museGraph = CPTXYGraph(frame: self.graphView.bounds)
        self.graphView.allowPinchScaling = true
        self.museGraph.applyTheme(CPTTheme(named: kCPTDarkGradientTheme))
        self.graphView.hostedGraph = self.museGraph
        
        super.viewDidLoad()
        
        self.museGraph.title = "Muse Data"
        
        var textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor(componentRed: 1, green: 1, blue: 1, alpha: 1)
        textStyle.fontName = "Helvetica-Bold"
        textStyle.fontSize = 16.0
        self.museGraph.titleTextStyle = textStyle
        self.museGraph.titlePlotAreaFrameAnchor = CPTRectAnchor.Top;
        self.museGraph.titleDisplacement = CGPoint(x: 0, y: 20)
        
        self.museGraph.paddingTop = textStyle.fontSize + 9.0
        self.museGraph.plotAreaFrame.paddingLeft = 30.0
        self.museGraph.plotAreaFrame.paddingRight = 5.0
        self.museGraph.plotAreaFrame.paddingBottom = 15.0
        self.museGraph.plotAreaFrame.paddingTop = 15.0
        
        self.configurePlots()
        self.configureAxes()
        
        if self.updateTimer == nil {
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateGraphAndStatus"), userInfo: nil, repeats: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func configurePlots() {
        
        let LINE_WIDTH : CGFloat = 1.0
        
        var plotSpace = self.museGraph.defaultPlotSpace as! CPTXYPlotSpace
        
        let trackedTypesAndColours = [
            IXNMuseDataPacketType.AlphaScore    : CPTColor.redColor(),
            IXNMuseDataPacketType.BetaScore     : CPTColor.blueColor(),
            IXNMuseDataPacketType.DeltaScore    : CPTColor.greenColor(),
            IXNMuseDataPacketType.ThetaScore    : CPTColor.yellowColor(),
            IXNMuseDataPacketType.GammaScore    : CPTColor.cyanColor(),
            IXNMuseDataPacketType.Mellow        : CPTColor.magentaColor(),
            IXNMuseDataPacketType.Concentration : CPTColor.orangeColor()
        ]
        
        // Create a plot for each type of data coming from the muse that we're interested in visualizing
        for (type, colour) in trackedTypesAndColours {
            var scatterPlot = CPTScatterPlot(frame: CGRectZero)
            scatterPlot.dataSource = self
            scatterPlot.identifier = type.rawValue
            scatterPlot.title = self.generatePlotTitle(type)
            
            var lineStyle = scatterPlot.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
            lineStyle.lineWidth = LINE_WIDTH
            lineStyle.lineColor = colour
            scatterPlot.dataLineStyle = lineStyle
            
            var markerSymbol = CPTPlotSymbol.ellipsePlotSymbol()
            markerSymbol.fill = CPTFill(color: colour)
            markerSymbol.lineStyle = lineStyle;
            markerSymbol.size = CGSizeMake(6.0, 6.0);
            
            scatterPlot.plotSymbol = markerSymbol;
            
            self.museGraph.addPlot(scatterPlot, toPlotSpace: plotSpace)
        }
        
        var yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        yRange.setLengthFloat(1.0)
        plotSpace.yRange = yRange
        
        var xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        xRange.setLengthFloat(Float(MuseListener.MAX_CACHED_VALUES))
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

        
        var axisTitleStyle = CPTMutableTextStyle()
        axisTitleStyle.color = CPTColor.whiteColor()
        axisTitleStyle.fontName = "Helvetica-Bold";
        axisTitleStyle.fontSize = 12.0;
        
        var axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.whiteColor()
        axisTextStyle.fontName = "Helvetica-Bold";
        axisTextStyle.fontSize = 11.0;
        
        //var tickLineStyle = CPTMutableLineStyle()
        //tickLineStyle.lineColor = CPTColor.whiteColor();
        //tickLineStyle.lineWidth = 2.0;
        
        var axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0;
        axisLineStyle.lineColor = CPTColor.whiteColor()
        
        var majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 1.0;
        majorGridLineStyle.lineColor = CPTColor.whiteColor()
        var minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.5;
        minorGridLineStyle.lineColor = CPTColor.darkGrayColor()
        
        
        var axisSet = self.museGraph.axisSet
        
        // X-Axis
        var x = axisSet.axisForCoordinate(CPTCoordinate.X, atIndex: 0)
        x.labelingPolicy = CPTAxisLabelingPolicy.None
        for label in x.axisLabels {
            if let axisLabel = label as? CPTAxisLabel {
                axisLabel.contentLayer.hidden = true
            }
        }
        
        
        // Y-Axis
        var y = axisSet.axisForCoordinate(CPTCoordinate.Y, atIndex: 0)
        y.axisLineStyle = axisLineStyle;
        y.majorGridLineStyle = majorGridLineStyle;
        y.minorGridLineStyle = minorGridLineStyle
        y.labelingPolicy = CPTAxisLabelingPolicy.None
        y.labelTextStyle = axisTextStyle;
        y.labelOffset = 16.0;
        y.majorTickLineStyle = axisLineStyle;
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
        //yAxis.
        
    }
    
    func updateGraphAndStatus() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            if museListener.dataUpdated {
                self.museGraph.reloadData()
                museListener.dataUpdated = false
            }
            self.connStatusLabel.text = MuseListener.getConnectionStatusString(museListener.museConnStatus)
            self.connStatusLabel.textColor = MuseListener.getConnectionStatusColour(museListener.museConnStatus)
            
            self.signalLabel.text = MuseListener.getSignalStrengthString(museListener.horseshoeScore)
            self.signalLabel.textColor = MuseListener.getSignalStrengthColour(museListener.horseshoeScore)
        }
    }

    // CPTPlotDataSource Functions
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            
            if let plotType = IXNMuseDataPacketType(rawValue: (plot.identifier as! IXNMuseDataPacketType.RawValue)) {
                if let records = museListener.cachedScoreValues[plotType] {
                    return UInt(records.count)
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
                        return records[Int(idx)]
                    }
                }
            }
        }
        
        return 0
    }
    
    /*
    func dataLabelForPlot(plot: CPTPlot!, recordIndex idx: UInt) -> CPTLayer? {
        if let plotType = IXNMuseDataPacketType(rawValue: (plot.identifier as! IXNMuseDataPacketType.RawValue)) {
            return CPTLayer(
        }
        
        return nil
    }
*/
}

