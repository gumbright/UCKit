//
//  UCShapeView.swift
//  UCBlockingTaskView
//
//  Created by Guy Umbright on 2/17/23.
//

import UIKit

//should maybe add a create with path init? size dictated by path size?
public class UCShapeView: UIView
{

    public enum Shape
    {
        case roundedRect(CGFloat) //radius
        case shield(CGFloat) //point height
        case triangle
        
    }

    var shapeLayer = CAShapeLayer()

    public var borderColor : UIColor?
    {
        didSet {
            updatePath(shape: shape)
        }
    }

    public var fillColor : UIColor?
    {
        didSet {
            updatePath(shape: shape)
        }
    }

    public var borderWidth : CGFloat?
    {
        didSet {
            updatePath(shape: shape)
        }
    }


    public var shape = Shape.roundedRect(5.0)
    {
        didSet {
            updatePath(shape: shape)
        }
    }
    
    var shapeSize : CGSize = .zero
    
    public override var intrinsicContentSize: CGSize
    {
        get {
            return shapeSize
        }
    }

//    public init()
//    {
//        super.init(frame:.zero)
//        self.shape = .roundedRect(5)
//        updatePath(shape: shape)
//    }
 
    //size is used for intrinsic size so if use is solely constraint based, can be zero
    public convenience init(size : CGSize, shape : Shape)
    {
        var rect = CGRect.zero
        rect.size = size
        self.init(frame:rect)
        shapeSize = size
        self.shape = shape
    }
    
    public override func draw(_ rect: CGRect)
    {
        updatePath(shape: shape)
    }

    func updatePath(shape : Shape)
    {
        let rect = self.bounds
        var path  = CGMutablePath(rect: rect, transform: nil)
        switch shape
        {
            case .roundedRect(let radius):
                path = CGMutablePath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
            case .shield(let pointHeight):
                path = CGMutablePath()
                path.move(to: CGPoint.zero)
                path.addLine(to: CGPoint(x: self.bounds.size.width,y: 0))
                path.addLine(to: CGPoint(x: self.bounds.size.width,y: self.bounds.size.height-pointHeight))
                path.addLine(to: CGPoint(x: self.bounds.size.width/2.0,y: self.bounds.size.height))
                path.addLine(to: CGPoint(x: 0,y: self.bounds.size.height-pointHeight))
                path.closeSubpath()

            case .triangle:
                path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height/2))
                path.addLine(to: CGPoint(x: 0.0, y: rect.size.height))
                path.closeSubpath()
        }
        
        shapeLayer.path = path
        shapeLayer.bounds = path.boundingBox
        self.layer.insertSublayer(shapeLayer, at: 0)
        shapeLayer.position = CGPoint(x:bounds.midX, y:bounds.midY)
        
        if let fillColor
        {
            shapeLayer.fillColor = fillColor.cgColor
        }
        
        if let borderColor
        {
            shapeLayer.strokeColor = borderColor.cgColor
        }
        
        if let borderWidth
        {
            shapeLayer.lineWidth = borderWidth
        }
    }
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        shapeLayer.frame = self.bounds
    }
}
