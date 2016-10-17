//
//  ViewController.swift
//  Movies4u
//
//  Created by Tushar Humbe on 10/15/16.
//  Copyright © 2016 Tushar Humbe. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var postResponse: Array? = [];
    var filtered: Array? = [];
    let imageBaseUrl = "https://image.tmdb.org/t/p/w342"
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tableView == nil {
            return;
        }
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 160;
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)

        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        let searchBar  = UISearchBar()
        
        searchBar.backgroundColor = UIColor.lightGray
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        searchBar.delegate = self
        //let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.titleView = searchBar
        
        loadData();
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //postResponse?.filter(<#T##isIncluded: (Self.Iterator.Element) throws -> Bool##(Self.Iterator.Element) throws -> Bool#>)
        filtered?.removeAll()
        
        for response in postResponse! {
            let dictionary = response as! NSDictionary
            let title = dictionary["original_title"] as? String;
            let range = title?.lowercased().range(of: searchText.lowercased());
            if range != nil {
                    filtered?.append(response)
            }
            
            
        }
//        filtered = postResponse?.filter({_ in
//            if let $0 as? NSDictionary {
//                var tmp = $0["original_title"] as? String
//                return tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive) != NSNotFound
//            }
//            
//            
//        })
        if(filtered?.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadData();
        refreshControl.endRefreshing()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableView.identifier", for: indexPath) as! MovieTableViewCell;
        var dataArray: Array? = []
        if (searchActive) {
            dataArray = filtered
        } else {
            dataArray = postResponse
        }
        
        if ((dataArray?.count)! > 0) {
            let currentPost = dataArray?[indexPath.row] as! NSDictionary;
            
            cell.titleLabel.text = currentPost["original_title"] as? String;
            cell.summaryLabel.text = currentPost["overview"] as? String;
            cell.summaryLabel.sizeToFit()
            
            if let posterPath = currentPost["poster_path"] as? String {
                let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
                //let posterUrl = URL(string: posterBaseUrl + posterPath)
                let imageRequest = NSURLRequest(url: NSURL(string: posterBaseUrl + posterPath)! as URL)
                //cell.movieImage.setImageWith(posterUrl!)
                cell.movieImage.setImageWith(
                    imageRequest as URLRequest,
                    placeholderImage: nil,
                    success: { (imageRequest, imageResponse, image) -> Void in
                        if imageResponse != nil {
                            
                            cell.movieImage.alpha = 0.0
                            cell.movieImage.image = image
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                cell.movieImage.alpha = 1.0
                            })
                        } else {
                            
                            cell.movieImage.image = image
                        }
                    },
                    failure: { (imageRequest, imageResponse, error) -> Void in
                        
                })
            }
            else {
                cell.movieImage.image = nil
            }
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive) {
            return (filtered?.count)!;
        } else {
            return (postResponse?.count)!;
        }
    }
    
    
    func loadData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    
                    self.postResponse = responseDictionary.value(forKeyPath: "results") as? Array;
                    self.tableView.reloadData();
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
            if error != nil {
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertController = UIAlertController(title: "Network Error", message: "Error fetching data", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
            }
        });
        
        task.resume();
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!)
        
        let destinationViewController = segue.destination as! MoviesDetailViewController;
        
        let currentPost = postResponse?[(indexPath?.row)!] as! NSDictionary;
        
        destinationViewController.movieData = currentPost;
    }

}

