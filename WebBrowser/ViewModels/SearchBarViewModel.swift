//
//  SearchBarViewModel.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation
import UIKit

/**
 * A delegate design pattern to communicate to other ViewModel without coupling.
 */
protocol SearchBarViewModelDelegate: class {
    func searchBarTextDidChange(_ searchText: String)
    func didSelectSearchButtonWithText(_ searchText: String)
}

/**
 * It may seem that we don't need this ViewModel right now.
 * But when we start adding more feature to the searc bar in the futrue,
 * the search bar logic codebase will grow. And it will be good to handle
 * the logic in a dedicated class.
 * Future expension can be: delay timer for typing, inline suggestion, URL detection, etc.
 */
final class SearchBarViewModel: NSObject {
    weak var delegate: SearchBarViewModelDelegate?
}

// MARK: - UISearchBarDelegate
extension SearchBarViewModel: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBarTextDidChange(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.didSelectSearchButtonWithText(searchBar.text ?? "")
    }
}
