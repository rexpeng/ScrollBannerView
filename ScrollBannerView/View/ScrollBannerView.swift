//
//  ScrollBannerView.swift
//  ScrollBannerView
//
//  Created by Rex Peng on 2019/10/18.
//  Copyright © 2019 Rex Peng. All rights reserved.
//

import UIKit

enum PageControlAlignment {
    case left, center, right, none
}

class ScrollBannerView: UIView {
    
    private var scrollView: UIScrollView!
    private var pageControl: UIPageControl!
    
    private var itemsCount: Int = 0
    private var fullWidth: CGFloat = 0
    private var timer: Timer?
    private var banners: [UIImage] = []
    private var timerInterval: TimeInterval = 5
    
    var pageControlAlignment: PageControlAlignment = .right {
        didSet {
            setupPageControlPosition()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    deinit {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fullWidth = bounds.width
        scrollView.frame = bounds
        
        setupBanners()
    }
    
    private func setup() {
        scrollView = UIScrollView(frame: .zero)
        addSubview(scrollView)
        scrollView.isPagingEnabled = true
        
        scrollView.delegate = self
        
        pageControl = UIPageControl(frame: .zero)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        //addSubview(pageControl)
        pageControl.backgroundColor = .clear
        pageControl.hidesForSinglePage = true
    }
    
    private func setupPageControlPosition() {
        NSLayoutConstraint.deactivate(pageControl.constraints)
        pageControl.removeFromSuperview()
        switch pageControlAlignment {
        case .left:
            addSubview(pageControl)
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
            pageControl.heightAnchor.constraint(equalToConstant: 14).isActive = true
        case .center:
            addSubview(pageControl)
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
            pageControl.heightAnchor.constraint(equalToConstant: 14).isActive = true
        case .right:
            addSubview(pageControl)
            pageControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
            pageControl.heightAnchor.constraint(equalToConstant: 14).isActive = true
        case .none:
            break
        }
    }
    
    func setupItems(items: [UIImage]) {
        banners = items
        itemsCount = items.count
        pageControl.numberOfPages = itemsCount
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.0/255.0, green: 180.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        pageControl.pageIndicatorTintColor = .white
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        
        setupTimer(interval: timerInterval)
    }
    
    private func setupBanners() {
        guard itemsCount > 0 else { return }
        scrollView.contentSize = CGSize(width: fullWidth * CGFloat(itemsCount + 2), height: scrollView.frame.height)
        scrollViewScrollToRect(scrollView: scrollView, timesOfScrollViewWidth: 1, animated: false)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            if let vc = findViewController() {
                vc.automaticallyAdjustsScrollViewInsets = false
            }
        }
        
        for sub in scrollView.subviews {
            sub.removeFromSuperview()
        }
        
        for i in 0..<itemsCount {
            let imageView = UIImageView(frame: CGRect(x: fullWidth * CGFloat(i), y: 0, width: fullWidth, height: scrollView.frame.height))
            imageView.contentMode = contentMode
            imageView.image = banners[i]
            imageView.center = CGPoint(x: fullWidth * (0.5 + CGFloat(i+1)),y: scrollView.frame.height * 0.5)
            if i == 0 {
                let bufferImageView = UIImageView(frame: CGRect(x: fullWidth * CGFloat(i), y: scrollView.frame.minY, width: fullWidth, height: scrollView.frame.height))
                bufferImageView.contentMode = contentMode
                bufferImageView.image = banners.last
                
                scrollView.addSubview(bufferImageView)
            }
            scrollView.addSubview(imageView)
            if i == itemsCount-1 {
                let bufferImageView = UIImageView(frame: CGRect(x: fullWidth * CGFloat(itemsCount+1), y: scrollView.frame.minY, width: fullWidth, height: scrollView.frame.height))
                bufferImageView.contentMode = contentMode
                bufferImageView.image = banners.first
                
                scrollView.addSubview(bufferImageView)
            }
        }
        
    }
    
    @objc private func pageChanged(_ sender: UIPageControl) {
        scrollViewScrollToRect(scrollView: scrollView, timesOfScrollViewWidth: CGFloat(sender.currentPage + 1), animated: true)
    }
    
    private func scrollViewScrollToRect(scrollView: UIScrollView , timesOfScrollViewWidth times: CGFloat, animated: Bool) {
        var frame = scrollView.frame
        frame.origin.x = frame.width * times
        scrollView.scrollRectToVisible(frame, animated: animated)
    }
    
    func setupTimer(interval: TimeInterval = 5) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timerInterval = interval
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(autoPaged), userInfo: nil, repeats: true)
    }
    
    @objc private func autoPaged(_ sender: Timer) {
        guard itemsCount > 0 else { return }
        if pageControl.currentPage == itemsCount - 1 {
            scrollViewScrollToRect(scrollView: scrollView, timesOfScrollViewWidth: CGFloat(itemsCount + 1), animated: true)
        } else {
            pageControl.currentPage += 1
            scrollViewScrollToRect(scrollView: scrollView, timesOfScrollViewWidth: CGFloat(pageControl.currentPage + 1), animated: true)
        }
    }
    
    
}

extension ScrollBannerView: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currenOffsetX = scrollView.contentOffset.x
        if currenOffsetX == fullWidth * CGFloat(itemsCount + 1) {
            scrollViewScrollToRect(scrollView: scrollView, timesOfScrollViewWidth: 1, animated: false)
            pageControl.currentPage = 0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if page == itemsCount + 1 {
            page = 0
            scrollViewScrollToRect(scrollView: scrollView, timesOfScrollViewWidth: 1, animated: false)
        } else if page == 0 {
            page = itemsCount - 1
            scrollViewScrollToRect(scrollView: scrollView, timesOfScrollViewWidth: CGFloat(itemsCount), animated: false)
        } else {
            page -= 1
        }
        pageControl.currentPage = page
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
