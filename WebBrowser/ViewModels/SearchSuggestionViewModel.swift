//
//  SearchSuggestionViewModel.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation
import UIKit

/**
 * A ViewModel responsible for the SearchSuggestionView
 */
final class SearchSuggestionViewModel: NSObject {
    
    // MARK: - UI Bindings (Communications to UI components)
    var updateSearchSuggestions: (([String]) -> Void)?
    
    var suggestions: [String] = [] {
        didSet {
            updateSearchSuggestions?(suggestions)
        }
    }
    
    // MARK: - Constants
    static private let searchSuggestionTableViewCellID: String = "SearchSuggestionTableViewCell"
}

// MARK: - UITableViewDataSource
extension SearchSuggestionViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchSuggestionViewModel.searchSuggestionTableViewCellID, for: indexPath)
        cell.textLabel!.text = suggestions[indexPath.row]
        return cell
    }
}
