//
//  ContactsVC.swift
//  BoostTest
//
//  Created by Sonya Hew on 10/06/2021.
//

import UIKit

class ContactsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var viewModel = ContactsVM(view: self.view, navController: self.navigationController)
    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateData()
    }
    
    func setupView() {
        self.title = "Contacts"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact))
        self.navigationController?.navigationBar.tintColor = .accent
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        refresher.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        tableView.addSubview(refresher)
    }
    
    func updateData() {
        viewModel.resetTextFields()
        viewModel.loadData()
        tableView.reloadData()
        refresher.endRefreshing()
    }
    
    @objc func refreshHandler() {
        updateData()
    }
    
    @objc func addContact() {
        viewModel.resetTextFields()
        let navController = UINavigationController(rootViewController: viewModel.contactDetailsVC)
        viewModel.contactDetailsVC.viewModel = viewModel
        viewModel.contactDetailsVC.isAddContact = true
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true, completion: nil)
    }
}

extension ContactsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.profileModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsTVC", for: indexPath) as! ContactsTVC
        cell.setupCell(profileModel: viewModel.profileModel[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.editContact(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class ContactsTVC: UITableViewCell {
    
    @IBOutlet weak var vwAvatar: UIView!
    @IBOutlet weak var lbName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwAvatar.layer.cornerRadius = 26
    }
    
    func setupCell(profileModel: ProfileModel) {
        lbName.text = "\(profileModel.firstName ?? "") \(profileModel.lastName ?? "")"
    }
}

