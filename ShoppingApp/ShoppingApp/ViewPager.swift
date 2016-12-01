//
//  ViewPager.swift
//  ViewPager
//
//  Created by Septiyan Andika on 6/26/16.
//  Copyright © 2016 sailabs. All rights reserved.
//

import UIKit

@objc public protocol  ViewPagerDataSource {
    func numberOfItems(_ viewPager:ViewPager) -> Int
    func viewAtIndex(_ viewPager:ViewPager, index:Int, view:UIView?) -> UIView
    @objc optional func didSelectedItem(_ index:Int)
    
}

open class ViewPager: UIView {
    
    var pageControl:UIPageControl = UIPageControl()
    var scrollView:UIScrollView = UIScrollView()
    var currentPosition:Int = 0
    
    var dataSource:ViewPagerDataSource? = nil {
        didSet {
            reloadData()
        }
    }
    
    var numberOfItems:Int = 0
    var itemViews:Dictionary<Int, UIView> = [:]
    
    required  public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        setupScroolView();
        setupPageControl();
        reloadData()
    }
    
    func setupScroolView() {
        scrollView.isPagingEnabled = true;
        scrollView.alwaysBounceHorizontal = false
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self;
        let topContraints = NSLayoutConstraint(item: scrollView, attribute:
            .top, relatedBy: .equal, toItem: self,
                  attribute: NSLayoutAttribute.top, multiplier: 1.0,
                  constant: 0)
        
        let bottomContraints = NSLayoutConstraint(item: scrollView, attribute:
            .bottom, relatedBy: .equal, toItem: self,
                     attribute: NSLayoutAttribute.bottom, multiplier: 1.0,
                     constant: 0)
        
        let leftContraints = NSLayoutConstraint(item: scrollView, attribute:
            .leadingMargin, relatedBy: .equal, toItem: self,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 0)
        
        let rightContraints = NSLayoutConstraint(item: scrollView, attribute:
            .trailingMargin, relatedBy: .equal, toItem: self,
                             attribute: .trailingMargin, multiplier: 1.0,
                             constant: 0)
        
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([topContraints,rightContraints,leftContraints,bottomContraints])
    }
    
    func setupPageControl() {
        
        self.pageControl.numberOfPages = numberOfItems
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.gray
        
        
        let heightContraints = NSLayoutConstraint(item: pageControl, attribute:
            .height, relatedBy: .equal, toItem: nil,
                     attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0,
                     constant: -20)
        
        let bottomContraints = NSLayoutConstraint(item: pageControl, attribute:
            .bottom, relatedBy: .equal, toItem: self,
                     attribute: NSLayoutAttribute.bottom, multiplier: 1.0,
                     constant: 0)
        
        let leftContraints = NSLayoutConstraint(item: pageControl, attribute:
            .leadingMargin, relatedBy: .equal, toItem: self,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 0)
        
        let rightContraints = NSLayoutConstraint(item: pageControl, attribute:
            .trailingMargin, relatedBy: .equal, toItem: self,
                             attribute: .trailingMargin, multiplier: 1.0,
                             constant: 0)
        
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([heightContraints,rightContraints,leftContraints,bottomContraints])
    }
    
    
    func reloadData() {
        if(dataSource != nil){
            numberOfItems = (dataSource?.numberOfItems(self))!
        }
        self.pageControl.numberOfPages = numberOfItems
        
        itemViews.removeAll()
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        
        DispatchQueue.main.async {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width *  CGFloat(self.numberOfItems) , height: self.scrollView.frame.height)
            self.reloadViews(0)
        }
        
    }
    
    func loadViewAtIndex(_ index:Int){
        let view:UIView?
        if(dataSource != nil){
            view =  (dataSource?.viewAtIndex(self, index: index, view: itemViews[index]))!
        }else{
            view = UIView()
        }
        
        setFrameForView(view!, index: index);
        
        
        if(itemViews[index] == nil){
            itemViews[index] = view
            let tap = UITapGestureRecognizer(target: self, action:  #selector(self.handleTapSubView))
            tap.numberOfTapsRequired = 1
            itemViews[index]!.addGestureRecognizer(tap)
            
            scrollView.addSubview(itemViews[index]!)
        }else{
            itemViews[index] = view
        }
        
    }
    
    func handleTapSubView() {
        if(dataSource?.didSelectedItem != nil){
            dataSource?.didSelectedItem!(currentPosition)
        }
    }
    
    
    func reloadViews(_ index:Int){
        
        for i in (index-1)...(index+1) {
            if(i>=0 && i<numberOfItems){
                loadViewAtIndex(i);
            }
        }
        
        // print(scrollView.subviews.count)
    }
    
    func setFrameForView(_ view:UIView,index:Int){
        view.frame = CGRect(x: self.scrollView.frame.width*CGFloat(index), y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height);
    }
    
    
}

extension ViewPager:UIScrollViewDelegate{
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        currentPosition = pageControl.currentPage
        reloadViews(Int(pageNumber));
    }
    
    
}

extension ViewPager{
    
    
    func animationNext(){
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ViewPager.moveToNextPage), userInfo: nil, repeats: true)
    }
    func moveToNextPage (){
        if(currentPosition <= numberOfItems && currentPosition > 0) {
            scrollToPage(currentPosition)
            currentPosition = currentPosition + 1
            if currentPosition > numberOfItems {
                currentPosition = 1
            }
        }
    }
    
    func scrollToPage(_ index:Int) {
        if(index <= numberOfItems && index > 0) {
            let zIndex = index - 1
            let iframe = CGRect(x: self.scrollView.frame.width*CGFloat(zIndex), y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height);
            scrollView.setContentOffset(iframe.origin, animated: true)
            pageControl.currentPage = zIndex
            reloadViews(zIndex)
            currentPosition = index
        }
    }
    
}
