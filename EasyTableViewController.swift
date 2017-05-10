//
//  EasyTableViewController.swift
//  app
//
//  Created by Adrien on 5/5/17.
//  Copyright © 2017 ZiggTime. All rights reserved.
//

import UIKit
import PromiseKit
import PullToRefreshSwift

class EasyTableViewController<T>: UITableViewController {
    
    class BackgroundDescription {
        let title = "Il n'y a rien ici"
        var subtitle: String?
        var image: UIImage?
    }
    
    var theData: [T]!
    var bottomWasReached = false
    lazy var indicator = UIActivityIndicatorView()
    
    var downloadMethod: Useful.ApiGetter!
    var backgroundViewWhenDataIsEmpty: UIView?

    var pullToRefreshEnabled = false {
        didSet {
            self.tableView.addPullRefresh {
                self.shouldRefresh()
                    .always {
                        self.tableView.stopPullRefreshEver()
                }
            }
        }
    }
    var loadingEnabled = false {
        didSet {
            tableView.addSubview(indicator)
            indicator.isHidden = false
            indicator.startAnimating()
            indicator.color = .gray
            _ = shouldLoadMore() // TODO error image
        }
    }
    var loading = false
    var pageSize = 6
    
    public func fetchMethod(_ getter: Useful.ApiGetter) {
        downloadMethod = getter
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if loadingEnabled {
            indicator.frame = tableView.frame
        }
    }
    
    func shouldRefresh() -> Promise<Void> {
        if theData != nil {
            theData = nil
        }
        return shouldLoadMore()
    }
    
    func shouldLoadMore() -> Promise<Void> {
        
        loading = true
        let dataCount = theData == nil ? 0 : theData.count
        return fetchItems(from: dataCount, count: pageSize).then { items -> () in
            if self.theData == nil {
                self.theData = []
            }
            
            self.bottomWasReached = items.count == 0
            self.theData.append(contentsOf: items)
            self.loading = false
            self.tableView.reloadData()
            }.always {
                self.loading = false
                self.indicator.isHidden = true
                self.indicator.removeFromSuperview()
        }
    }
    
    // TODO: move elsewhere
    enum EasyError: Error {
        case NotImplemented
    }
    
    func fetchItems(from: Int, count: Int) -> Promise<[T]> {
        return Promise(error: EasyError.NotImplemented)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (theData == nil || theData.count == 0) && !loading {
            showBackgroundIfEmpty()
        } else {
            backgroundViewWhenDataIsEmpty?.removeFromSuperview()
            return theData == nil ? 0 : theData.count
        }
 
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == theData.count - 1 && !loading && !bottomWasReached {
             _ = shouldLoadMore()
        }
    }
 
    func showBackgroundIfEmpty() {
        if let backgroundViewWhenDataIsEmpty = backgroundViewWhenDataIsEmpty {
            view.addSubview(backgroundViewWhenDataIsEmpty)
            backgroundViewWhenDataIsEmpty.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        }
    }
    
}
