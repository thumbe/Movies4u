//
//  MoviesDetailViewController.swift
//  Movies4u
//
//  Created by Tushar Humbe on 10/16/16.
//  Copyright © 2016 Tushar Humbe. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesDetailViewController: UIViewController {

    //@IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    var movieData : NSDictionary = [:]
    
    @IBOutlet weak var descriptionScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionScrollView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        let contentWidth = descriptionScrollView.bounds.width
        let contentHeight = descriptionScrollView.bounds.height * 3
        
        let overviewLabel = UILabel(frame: CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight))
        overviewLabel.numberOfLines = 10
        
        overviewLabel.text = movieData["overview"] as? String
        overviewLabel.sizeToFit()
        descriptionScrollView.addSubview(overviewLabel)
        
        if let posterPath = movieData["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = URL(string: posterBaseUrl + posterPath)
            posterImage.setImageWith(posterUrl!)
        }
        
        //posterImage.setImageWith(<#T##url: URL##URL#>)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
