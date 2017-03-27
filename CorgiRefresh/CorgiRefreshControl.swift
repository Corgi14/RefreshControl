//
//  CorgiRefreshControl.swift
//  weibo
//
//  Created by Corgi on 17/3/27.
//  Copyright © 2017年 cocoaHangTou. All rights reserved.
//

import UIKit

///定义全局常量
let CONTROLHEIGHT: CGFloat = 50
///定义状态枚举
enum controlType: String {
    case normal = "正常状态"
    case pullingDown = "下拉刷新"
    case refreshing = "正在刷新"
}

class CorgiRefreshControl: UIControl {

    //属性
    var scrollView: UIScrollView?
    
    var controlType: controlType = .normal {
    
        didSet {
        
            //根据枚举获得对应的值
            messageLabel.text = controlType.rawValue
            
            switch controlType {
            case .normal:
                
                if oldValue == .refreshing {
                 
                    UIView.animate(withDuration: 0.25, animations: {
                        
                        self.scrollView?.contentInset.top -= CONTROLHEIGHT
                        
                        self.indicatorView.stopAnimating()
                        
                    }, completion: { (_) in
                        
                        self.arrowImageView.isHidden = false
                    })
                }
                
                UIView.animate(withDuration: 0.25, animations: { 
                    
                    self.arrowImageView.transform = CGAffineTransform.identity
                })
            
            case .pullingDown:
                
                UIView.animate(withDuration: 0.25, animations: { 
                    
                    self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-3 * M_PI))
                })
                
            case .refreshing:
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.scrollView?.contentInset.top += CONTROLHEIGHT
                    
                    self.indicatorView.startAnimating()
                    
                    self.arrowImageView.isHidden = true
                    
                }, completion: { (_) in
                    
                    self.sendActions(for: .valueChanged)
                })
            }
        }
    }
    
    //停止动画方法
    func endRefreshing() {
        
        controlType = .normal
    }
    
    //构造方法
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: -CONTROLHEIGHT, width: screenWidth, height: CONTROLHEIGHT))
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = UIColor.darkGray
        
        //添加控件
        addSubview(messageLabel)
        addSubview(arrowImageView)
        addSubview(indicatorView)
        
        //约束控件
        /*
         When you elect to position the view using auto layout by adding your own constraints,
         you must set this property to NO
         */
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        addConstraint(NSLayoutConstraint(item: arrowImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -45))
        
        addConstraint(NSLayoutConstraint(item: arrowImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -45))
        
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    //懒加载控件
    fileprivate lazy var messageLabel:UILabel = {
    
        let lab = UILabel()
    
        lab.textColor = UIColor.white
        
        lab.textAlignment = .center
        
        lab.font = UIFont.systemFont(ofSize: 15)
        
        lab.text = "正常状态"
    
        return lab
    }()
    
    fileprivate lazy var arrowImageView: UIImageView = UIImageView(imageName: "tableview_pull_refresh")
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    
    deinit {
        
        removeObserver(self, forKeyPath: "contentOffset")
    }
}

///extension扩展方法
extension CorgiRefreshControl {

    //获得superView
    override func willMove(toSuperview newSuperview: UIView?) {
        
        //筛选superView,需要添加到scrollView上面
        guard let view = newSuperview as? UIScrollView else {
            
            return
        }
        
        scrollView = view
        
        //KVO监听父view的contentOffset的属性的变化
        /*
         NSKeyValueObservingOptionNew：提供更改前的值
         
         NSKeyValueObservingOptionOld：提供更改后的值
         
         NSKeyValueObservingOptionInitial：观察最初的值（在注册观察服务时会调用一次触发方法）
         
         NSKeyValueObservingOptionPrior：分别在值修改前后触发方法（即一次修改有两次触发）
        */
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        
    }
    
    //KVO监听方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
     
        //正常/下拉临界值
        let contentOffsetMaxY = -(scrollView!.contentInset.top + CONTROLHEIGHT)
        
        let contenOffsetY = scrollView!.contentOffset.y
        
        //用户拖拽界面,有两种状态:1.正常 2.下拉
        if scrollView!.isDragging {
        
            if contenOffsetY >= contentOffsetMaxY && controlType == .pullingDown {
                
                controlType = .normal
                
            } else if contenOffsetY < contentOffsetMaxY && controlType == .normal {
            
                controlType = .pullingDown
            }
        //用户停止拖拽,刷新
        } else {
        
            if controlType == .pullingDown {
            
                controlType = .refreshing
            }
        }
    }
}


































/*
 扩展 就是为一个已有的类、结构体、枚举类型或者协议类型添加新功能。这包括在没有权限获取原始源代码的情况下扩展类型的能力（即 逆向建模 ）。扩展和 Objective-C 中的分类类似。（与 Objective-C 不同的是，Swift 的扩展没有名字。）
 
 使用得当能显著提高代码的可读性，平常我们自己写的大多数辅助类其实都可以转化为extension
 
 extension SomeType {
 // 为 SomeType 添加的新功能写到这里
 }
可以通过扩展来扩展一个已有类型，使其采纳一个或多个协议。在这种情况下，无论是类还是结构体，协议名字的书写方式完全一样：
 extension SomeType: SomeProtocol, AnotherProctocol {
 // 协议实现写到这里
 }
 
 注意
 如果你通过扩展为一个已有类型添加新功能，那么新功能对该类型的所有已有实例都是可用的，即使它们是在这个扩展定义之前创建的。
 
 -添加计算型属性和计算型类型属性
 
 extension Double {
 var km: Double { return self * 1_000.0 }
 var m : Double { return self }
 var cm: Double { return self / 100.0 }
 var mm: Double { return self / 1_000.0 }
 var ft: Double { return self / 3.28084 }
 }
 
 注意
 扩展可以添加新的计算型属性，但是不可以添加存储型属性，也不可以为已有属性添加属性观察器。
 
 -定义实例方法和类型方法
 扩展可以为已有类型添加新的构造器。这可以让你扩展其它类型，将你自己的定制类型作为其构造器参数，或者提供该类型的原始实现中未提供的额外初始化选项。
 
 扩展能为类添加新的便利构造器，但是它们不能为类添加新的指定构造器或析构器。指定构造器和析构器必须总是由原始的类实现来提供。
 

 
 提供新的构造器
 定义下标
 定义和使用新的嵌套类型
 使一个已有类型符合某个协议
 
 
 注：扩展可以增加新的功能，但是不能覆盖已有的功能
 */



























