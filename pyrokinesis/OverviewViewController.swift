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
    var museGraph: CPTXYGraph!
    var fieldValues: [IXNMuseDataPacketType: Double]
    
    

    required init(coder aDecoder: NSCoder) {
        self.fieldValues = [IXNMuseDataPacketType: Double]()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        // Create the muse graph
        self.museGraph = CPTXYGraph(frame: CGRectZero)
        
        super.viewDidLoad()
        
        self.museGraph.title = "Muse Data"
        
        var textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor(componentRed: 0, green: 0, blue: 0, alpha: 1)
        textStyle.fontName = "Helvetica-Bold"
        textStyle.fontSize = 16.0
        self.museGraph.titleTextStyle = textStyle
        
        self.museGraph.paddingLeft = 30
        self.museGraph.paddingTop = 10
        self.museGraph.paddingRight = 30
        self.museGraph.paddingBottom = 30
        
        self.configurePlots()
        self.configureAxes()
        
        self.graphView.hostedGraph = self.museGraph
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func configurePlots() {
        
        let LINE_WIDTH : CGFloat = 1.0
        
        var plotSpace = self.museGraph.defaultPlotSpace as! CPTXYPlotSpace
        
        let trackedTypesAndColours = [
            IXNMuseDataPacketType.AlphaScore : CPTColor(componentRed: 1, green: 0, blue: 0, alpha: 1),
            IXNMuseDataPacketType.BetaScore : CPTColor(componentRed: 0, green: 0, blue: 1, alpha: 0),
            IXNMuseDataPacketType.DeltaScore : CPTColor(componentRed: 0, green: 1, blue: 0, alpha: 1),
            IXNMuseDataPacketType.ThetaScore : CPTColor(componentRed: 1, green: 1, blue: 0, alpha: 1),
            IXNMuseDataPacketType.GammaScore : CPTColor(componentRed: 0, green: 1, blue: 1, alpha: 1),
            IXNMuseDataPacketType.Mellow : CPTColor(componentRed: 1, green: 0, blue: 1, alpha: 1),
            IXNMuseDataPacketType.Concentration : CPTColor(componentRed: 0.5, green: 0.5, blue: 0, alpha: 1)
        ]
        
        // Create a plot for each type of data coming from the muse that we're interested in visualizing
        for (type, colour) in trackedTypesAndColours {
            var scatterPlot = CPTScatterPlot(frame: CGRectZero)
            scatterPlot.dataSource = self
            scatterPlot.identifier = type.rawValue
            
            var lineStyle = scatterPlot.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
            lineStyle.lineWidth = LINE_WIDTH
            lineStyle.lineColor = colour
            scatterPlot.dataLineStyle = lineStyle
            
            self.museGraph.addPlot(scatterPlot, toPlotSpace: plotSpace)
        }
    }
    
    func configureAxes() {
        
    }

    // CPTPlotDataSource Functions
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            
            let plotType = plot.identifier as! IXNMuseDataPacketType
            if let records = museListener.cachedScoreValues[plotType] {
                return UInt(records.count)
            }
        }
        
        return 0
    }
    
    func doubleForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> Double {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let museListener = appDelegate.museListener {
            
            let plotType = plot.identifier as! IXNMuseDataPacketType
            if let records = museListener.cachedScoreValues[plotType] {
                assert(UInt(records.count) < idx, "Invalid record index found.")
                return records[Int(idx)]
            }
        }
        
        assert(false);
        return -1
    }
    
    func dataLabelForPlot(plot: CPTPlot!, recordIndex idx: UInt) -> CPTLayer? {
        return nil
    }
}

