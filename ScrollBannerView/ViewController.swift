//
//  ViewController.swift
//  ScrollBannerView
//
//  Created by Rex Peng on 2019/10/18.
//  Copyright © 2019 Rex Peng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupBannerView()
        
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    func setupBannerView() {
        let bannerView = ScrollBannerView(frame: .zero)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        bannerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let banners = [UIImage(named: "dims")!, UIImage(named: "dims1")!, UIImage(named: "dims2")!]
        bannerView.setupItems(items: banners)
    }
}

