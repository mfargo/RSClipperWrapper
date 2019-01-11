//
//  Scene.swift
//  Example
//
//  Created by Matthias Fey on 10.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSClipperWrapper

class Scene : SKScene {
    
    let polygon1 = [CGPoint(x: -50, y: -50), CGPoint(x: -50, y: 25), CGPoint(x: 25, y: 25), CGPoint(x: 25, y: -50)]
    let polygon2 = [CGPoint(x: -25, y: -25), CGPoint(x: -25, y: 50), CGPoint(x: 50, y: 50), CGPoint(x: 50, y: -25)]

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        var star = [CGPoint]()
        let increment:CGFloat = (2 * .pi) / 5
        let radius:CGFloat = 50
        for i in [0, 2, 4, 1, 3] {
            let angle = increment * CGFloat(i)
            star.append(CGPoint(x: sin(angle) * radius, y: -100 + cos(angle) * radius))
        }
        
        let starNode = SKShapeNode()
        starNode.strokeColor = SKColor.black
        starNode.lineWidth = 1
        starNode.path = CGPath.pathOfPolygons(polygons: [star])
        addChild(starNode)

        let starPolygon = Clipper.simplifyPolygon(star, fillType: .nonZero)

        let starClipperNode = SKShapeNode()
        starClipperNode.lineWidth = 0
        starClipperNode.fillColor = SKColor.red
        starClipperNode.zPosition = -1
        starClipperNode.path = CGPath.pathOfPolygons(polygons: starPolygon)
        addChild(starClipperNode)

        
        let polygonNode1 = SKShapeNode()
        polygonNode1.strokeColor = SKColor.black
        polygonNode1.lineWidth = 1
        polygonNode1.path = CGPath.pathOfPolygons(polygons: [polygon1])
        addChild(polygonNode1)
        
        let polygonNode2 = SKShapeNode()
        polygonNode2.strokeColor = SKColor.black
        polygonNode2.lineWidth = 1
        polygonNode2.path = CGPath.pathOfPolygons(polygons: [polygon2])
        addChild(polygonNode2)
        
        let clipperPolygon = Clipper.intersectPolygons([polygon1], withPolygons: [polygon2])
        
        let clipperNode = SKShapeNode()
        clipperNode.lineWidth = 0
        clipperNode.fillColor = SKColor.red
        clipperNode.zPosition = -1
        clipperNode.path = CGPath.pathOfPolygons(polygons: clipperPolygon)
        addChild(clipperNode)
        
        
        let pt = CGPoint.zero
        let inPoly = Clipper.polygonContainsPoint(clipperPolygon[0], point: pt)
        NSLog(inPoly ? "point is in poly" : "point is not in poly")
    }
}

extension CGPath {
    
    class func pathOfPolygons(polygons: [[CGPoint]]) -> CGPath {
        let path = CGMutablePath()
        for polygon in polygons {
            for (index, point) in polygon.enumerated() {
                if index == 0 { path.move(to: point) }
                else { path.addLine(to: point) }
            }
            if polygon.count > 2 { path.closeSubpath() }
        }
        
        return path
    }
}
