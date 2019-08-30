//
//  WebViewModel.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation
import UIKit

/**
 * This is a ViewModel responsible for the WebViewController logic and search.
 * Is is also responsible for coordinating with the SearchBarViewModel and SearchSuggestionViewModel.
 * It contains a finite state machine.
 */
final class WebViewModel: NSObject {

    // MARK: - UI Bindings (Communications to UI components)
    var showErrorAlert: ((Error) -> Void)?
    var setSearchSuggestionVisibility: ((Bool) -> Void)?
    var setSearchBarToText: ((String) -> Void)?
    var loadURL: ((URL) -> Void)?

    // MARK: - Private Properties
    private let searchAPI: SearchAPI
    private let searchBarViewModel: SearchBarViewModel
    private let searchSuggestionViewModel: SearchSuggestionViewModel
    private var currentViewState: ViewState = .emptyView

    // MARK: - Constructors
    init(searchAPI: SearchAPI, searchBarViewModel: SearchBarViewModel, searchSuggestionViewModel: SearchSuggestionViewModel) {
        self.searchAPI = searchAPI
        self.searchBarViewModel = searchBarViewModel
        self.searchSuggestionViewModel = searchSuggestionViewModel
        super.init()
        searchBarViewModel.delegate = self
    }
}

// MARK: - Finite State Machine
/**
 * I can implement this ViewModel without a state machine.
 * But for the purpose of demonstrating good design pattern and
 * considering future expendibility and flexibity,
 * having a state machine built in now will save the future from refactoring. 
 */
extension WebViewModel {
    private typealias Transition = () throws -> (ViewState)
    
    private enum ViewState: Int {
        case emptyView
        case enteringText
        case searchResultShown
    }
    
    private enum ViewEvent {
        case enteredText(String)
        case showSuggestions([String])
        case searchQuery(String)
    }
    
    private func handle(event: ViewEvent) throws {
        let transition: Transition = try transitionForEvent(event)
        currentViewState = try transition()
    }
    
    private func transitionForEvent(_ event: ViewEvent) throws -> Transition {
        switch (currentViewState, event) {
        case (.emptyView, .enteredText(let text)):
            return fetchSuggestionsForText(text)
        case (.enteringText, .enteredText(let text)):
            return fetchSuggestionsForText(text)
        case (.enteringText, .showSuggestions(let suggestions)):
            return showSuggestions(suggestions)
        case (.enteringText, .searchQuery(let query)):
            return searchQuery(query)
        case (.searchResultShown, .enteredText(let text)):
            return fetchSuggestionsForText(text)
        default:
            return { self.currentViewState }
        }
    }
    
    private func fetchSuggestionsForText(_ text: String) -> Transition {
        return {
            if text.isEmpty {
                self.setSearchSuggestionVisibility?(false)
                self.searchSuggestionViewModel.suggestions = []
                return .enteringText
            }
            
            do {
                try self.searchAPI.suggestionsForText(text) { [weak self] (searchSuggestionResponse, error) in
                    guard let self = self else {
                        return
                    }
                    
                    if let error = error {
                        self.showErrorAlert?(error)
                        return
                    }
                    
                    if let suggestions = searchSuggestionResponse?.suggestions {
                        try? self.handle(event: .showSuggestions(suggestions))
                    }
                }
            } catch {
                self.showErrorAlert?(error)
            }
            
            return .enteringText
        }
    }
    
    private func showSuggestions(_ suggestions: [String]) -> Transition {
        return {
            self.searchSuggestionViewModel.suggestions = suggestions
            self.setSearchSuggestionVisibility?(!suggestions.isEmpty)
            return .enteringText
        }
    }
    
    private func searchQuery(_ query: String) -> Transition {
        return {
            guard !query.isEmpty else {
                return self.currentViewState
            }
            
            do {
                let url = try self.searchAPI.searchURLWithQuery(query)
                self.loadURL?(url)
                self.setSearchBarToText?(query)
                self.setSearchSuggestionVisibility?(false)
                return .searchResultShown
            } catch {
                self.showErrorAlert?(error)
                return self.currentViewState
            }
        }
    }
}

// MARK: - SearchBarViewModelDelegate
extension WebViewModel: SearchBarViewModelDelegate {
    
    func searchBarTextDidChange(_ searchText: String) {
        try? handle(event: .enteredText(searchText))
    }
    
    func didSelectSearchButtonWithText(_ searchText: String) {
        try? handle(event: .searchQuery(searchText))
    }
}

// MARK: - UITableViewDelegate
extension WebViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let searchText = cell?.textLabel?.text {
            try? handle(event: .searchQuery(searchText))
        }
    }
}

