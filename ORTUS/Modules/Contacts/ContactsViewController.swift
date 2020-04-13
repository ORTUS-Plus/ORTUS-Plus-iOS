//
//  ContactsViewController.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 4/9/20.
//  Copyright (c) 2020 Firdavs. All rights reserved.
//

import UIKit
import Carbon
import Models

class ContactsViewController: TranslatableModule, ModuleViewModel {
    var viewModel: ContactsViewModel
    
    weak var contactsView: ContactsView! { return view as? ContactsView }
    weak var tableView: UITableView! { return contactsView.tableView }
    
    let toolbarSegmentedControl = UISegmentedControl()
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.delegate = self

        let barItem = UIBarButtonItem(customView: self.toolbarSegmentedControl)

        toolbar.setItems([barItem], animated: false)

        return toolbar
    }()
    
    var selectedContactsFilter: Int = 0
    
    var refreshControl: UIRefreshControl!
    
    lazy var adapter = ContactsTableViewAdapter(delegate: self)
    
    lazy var renderer = Renderer(
        adapter: self.adapter,
        updater: UITableViewUpdater()
    )
    
    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = ContactsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventLogger.log(.openedContacts)
        
        prepareNavigationItem()
        prepareToolbar()
        prepareRefreshControl()
        prepareData()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func prepareLocales() {
        navigationItem.title = "contacts.title".localized()
        
        toolbarSegmentedControl.removeAllSegments()
        for (index, filter) in ContactsFilter.allCases.enumerated() {
            toolbarSegmentedControl.insertSegment(
                withTitle: filter.rawValue.localized(),
                at: index,
                animated: false)
        }
        toolbarSegmentedControl.selectedSegmentIndex = selectedContactsFilter
    }
    
    func render() {
        renderer.render {
            Group(
                of: selectedContactsFilter ==  0 ? viewModel.prioritizedSortedKeys : viewModel.sortedKeys
            ) { key in
                Section(id: key, header: StickyHeader(title: key)) {
                    Group(
                        of: (selectedContactsFilter ==  0 ? viewModel.prioritizedContacts[key] : viewModel.contacts[key]) ?? []
                    ) { contact in
                        ContactComponent(id: contact.id, contact: contact)
                    }
                }
            }
        }
    }
    
    func loadData() {
        viewModel.loadContacts().always {
            self.refreshControl.endRefreshing()
            self.render()
        }
    }
    
    @objc func filterContacts() {
        selectedContactsFilter = toolbarSegmentedControl.selectedSegmentIndex
        
        render()
    }
    
    @objc func refresh() {
        loadData()
    }
    
    func openContact(_ contact: Contact) {
        viewModel.router.openContact(contact)
    }
}

extension ContactsViewController {
    func prepareNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func prepareToolbar() {
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
        
        toolbarSegmentedControl.addTarget(self, action: #selector(filterContacts), for: .valueChanged)
    }
    
    func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func prepareData() {
        renderer.target = tableView
        
        adapter.didSelect = { [unowned self] context in
            guard let contact = context.node.component(as: ContactComponent.self)?.contact else {
                return
            }
            
            self.openContact(contact)
        }
    }
}

extension ContactsViewController: UIToolbarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }
}

extension ContactsViewController: ContactsTableViewAdapterDelegate {
    func indexTitles() -> [String] {
        return selectedContactsFilter == 0 ? viewModel.prioritizedSortedKeys : viewModel.sortedKeys
    }
}
