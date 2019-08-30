//
//  WebViewController.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation
import UIKit
import WebKit

/**
 * The main ViewController for the WebView.
 */
final class WebViewController: UIViewController {
    // MARK: - Constants
    static private let errorTitle: String = "Error"
    
    // MARK: - IBOutlets
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var searchSuggestionTableView: UITableView!
    
    // MARK: - Private Properties
    private var webViewModel: WebViewModel
    private var searchBarViewModel: SearchBarViewModel
    private var searchSuggestionViewModel: SearchSuggestionViewModel
    
    // MARK: - Constructors
    required init?(coder aDecoder: NSCoder) {
        searchBarViewModel = SearchBarViewModel()
        searchSuggestionViewModel = SearchSuggestionViewModel()
        webViewModel = WebViewModel(searchAPI: AppFactory.makeSearchAPI(), searchBarViewModel:searchBarViewModel, searchSuggestionViewModel:searchSuggestionViewModel)
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchSuggestionTableView.isHidden = true
        
        searchBar.delegate = searchBarViewModel
        searchSuggestionTableView.dataSource = searchSuggestionViewModel
        searchSuggestionTableView.delegate = webViewModel
        
        bindWithViewModels()
    }
    
    // MARK: - ViewModel Binding Closures
    private func bindWithViewModels() {
        webViewModel.showErrorAlert = { [weak self] error in
            self?.showAlert(title: WebViewController.errorTitle, message: error.localizedDescription)
        }
        
        webViewModel.setSearchSuggestionVisibility = { [weak self] visible in
            self?.searchSuggestionTableView.isHidden = !visible
        }
        
        webViewModel.setSearchBarToText = { [weak self] text in
            self?.searchBar.text = text
        }
        
        webViewModel.loadURL = { [weak self] url in
            self?.webView.load(URLRequest(url: url))
            self?.view.endEditing(true)
        }
        
        searchSuggestionViewModel.updateSearchSuggestions = { [weak self] suggestions in
            self?.searchSuggestionTableView.reloadData()
        }
    }
}
