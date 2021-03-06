//
//  GenresVC.swift
//  TMDb.iOS
//
//  Created by Rauan on 11/8/18.
//  Copyright © 2018 Rauan. All rights reserved.
//

import UIKit
import Moya

class GenresVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //Constants and variables
    fileprivate var genres = [Genre]()
    fileprivate var selectedGenre : Genre?
    fileprivate let provider = MoyaProvider<MovieListService>()
    let nib = UINib(nibName: "GenreCell", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadGenres()
        self.tableView.register(nib, forCellReuseIdentifier: "genreCell")
        navigationItem.rightBarButtonItem = nil
        LoadingIndicator().showActivityIndicator(uiView: self.view)
    }
    
    

    //Load data
    private func loadGenres() {
        provider.request(.genreList) { [weak self](result) in
            guard let strongSelf = self else {return}
            switch result{
            case .success(let response):
                do{
                    let jsonData = try response.mapJSON() as! [String : Any]
                    let array = jsonData["genres"] as! [[String: Any]]
                    strongSelf.genres = array.map({Genre(JSON: $0)!})
                    strongSelf.tableView.reloadData()
                    
                }catch{
                    print("MAPPING ERROR")
                    
                }
                
            case .failure(let error):
                print("SERVER ERROR = \(error)")
            }
        }
    }

}

extension GenresVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if  let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell") as? GenreCell {
            let genre = self.genres[indexPath.row]
            cell.configureCell(genre: genre)
        LoadingIndicator().hideActivityIndicator(uiView: self.view)
        return cell
      } else {
        return UITableViewCell()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genre = self.genres[indexPath.row]
        selectedGenre = genre
        let index = IndexPath(row: indexPath.row, section: 0)
        tableView.reloadRows(at: [index], with: .none)
        tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        genreId = selectedGenre?.id
        genreName = selectedGenre?.name
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MoviesByGenresVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
