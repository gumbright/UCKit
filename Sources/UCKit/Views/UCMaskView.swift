//
//  UCBlockingTaskView.swift
//  UCBlockingTaskView
//
//  Created by Guy Umbright on 2/15/23.
//

import UIKit
import UCUILib
//idea here is to provide view that blocks current interface until something happens
//initial driver is restore purchases with Revenue cat...nothing happens
//the base would just be the a clear (or blurred?) view that covers the screen and other
//stuff gets added on top of it
//want it to be able to handle changing the display (eg "Restoring Purchases" with spinner, to "Success" w/button or "Failed" w/ button

//seems like just the overlay is its own thing and then it could display another controller so should it be a container controller?
//no because that would overlay the VC beneath with is not the desired outcome.

//but could pass it another view.  Allow it to be placed top, middle bottom, and define insets

public class UCMaskView: UIView {
    
    public enum ContentPostion
    {
        case top, center, bottom
    }
        
    public var contentPosition = ContentPostion.center
    {
        didSet {
            if let contentView
            {
                applyContent(contentView: contentView)
            }
        }
    }
    private let overlayView = UIView()
    public var overlayInsets = UIEdgeInsets.zero
    var contentConstraints : [NSLayoutConstraint] = []
    
    public var contentView : UIView?
    {
        didSet {
            if contentView == nil && oldValue != nil
            {
                removeContentView(contentView: oldValue!)
            }
            else
            {
                if oldValue != nil
                {
                    oldValue!.removeFromSuperview()
                }
                contentView?.sizeToFit()
                applyContent(contentView: contentView!)
            }
        }
    }
    public var contentViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    //var tapToDismiss = false

    //config
    public var overlayViewColor = UIColor.clear
    {
        didSet {
            overlayView.backgroundColor = overlayViewColor
        }
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit()
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = overlayViewColor
        
        addSubview(overlayView)
        //add overlay to me
        let constraints : [NSLayoutConstraint] = [
            overlayView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
    
    //present over just a single view
    public func present()
    {
        //applyToParent(UIApplication.shared.keyWindow!)
        applyToParent(UIApplication.shared.currentUIWindow()!)
    }
    
    //present on the VCs entire view
    public func presentOnView(_ view : UIView)
    {
        applyToParent(view)
    }
    
    public func dismiss()
    {
        contentView?.removeFromSuperview()
        //overlayView.removeFromSuperview()
        self.removeFromSuperview()
    }
}

//MARK: Internal
extension UCMaskView
{
    func applyToParent(_ parentView : UIView)
    {
        parentView.addSubview(self)
        
        var constraints : [NSLayoutConstraint] = []
        constraints.append( NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1, constant: overlayInsets.left))
        constraints.append( NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1, constant: overlayInsets.top))
        constraints.append( NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: -overlayInsets.right))
        constraints.append( NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: -overlayInsets.bottom))
        NSLayoutConstraint.activate(constraints)
    }
    
    func applyContent(contentView : UIView)
    {
        contentView.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(contentView)
        
        NSLayoutConstraint.deactivate(contentConstraints)
        contentConstraints.removeAll()
        
        contentConstraints.append(contentView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor))
        contentConstraints.append(contentView.leadingAnchor.constraint(greaterThanOrEqualTo: overlayView.leadingAnchor, constant: contentViewInsets.left))
        contentConstraints.append(contentView.trailingAnchor.constraint(lessThanOrEqualTo: overlayView.trailingAnchor, constant: -contentViewInsets.right))
        switch contentPosition
        {
            case .center:
                contentConstraints.append(contentView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor))
                contentConstraints.append(contentView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor))
            case .top:
                contentConstraints.append(contentView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: contentViewInsets.top))
                break
            case .bottom:
                contentConstraints.append(contentView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -contentViewInsets.bottom))
                break
        }
        NSLayoutConstraint.activate(contentConstraints)
    }
    
    func removeContentView(contentView : UIView)
    {
        contentView.removeFromSuperview()
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
