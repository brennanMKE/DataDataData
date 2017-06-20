//
//  ViewController.swift
//  DataDataData
//
//  Created by Stehling, Brennan on 6/20/17.
//  Copyright © 2017 Acme. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    let metaStore = MetaStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let metas = metaStore.populateMeta()
        
        statusLabel.text = "There are \(metas.count) stored objects."
    }

}
