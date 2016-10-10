//
//  OptionsTableViewController.swift
//  WikiGame
//
//  Created by Harish Gonnabhaktula on 08/10/16.
//  Copyright © 2016 Harish Gonnabattula. All rights reserved.
//

import UIKit


protocol answerSelected:class {
    func passAnswerValue(answer:String)
}

class OptionsTableViewController: UITableViewController {

    var dataSource = [""]
    
    weak var delegate:answerSelected?
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("option", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = dataSource[indexPath.row]

        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
       delegate?.passAnswerValue(dataSource[indexPath.row] )
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
}