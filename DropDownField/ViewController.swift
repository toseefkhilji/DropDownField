//
//  ViewController.swift
//  DropDownField
//
//  Created by Toseef on 18/09/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dropDown: DropDownField!
    override func viewDidLoad() {
        super.viewDidLoad()

let gen1 = DropDownItem(title: "Male")
        let gen2 = DropDownItem(title: "Female")
        let gen3 = DropDownItem(title: "Other")

        dropDown.dataSource = [gen1, gen2, gen3]
    }


}

