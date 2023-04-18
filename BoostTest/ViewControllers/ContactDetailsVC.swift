//
//  ContactDetailsVC.swift
//  BoostTest
//
//  Created by Sonya Hew on 10/06/2021.
//

import UIKit

class ContactDetailsVC: UIViewController {
    
    var viewModel: ContactsVM?
    var isAddContact = false

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
        tableView.reloadData()
    }
    
    func setupView() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveContact))
        self.navigationController?.navigationBar.tintColor = .accent
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
    }
    
    @objc func dismissController() {
        navigationController?.popViewController(animated: true)
        navigationController?.dismiss(animated: true, completion: nil)
        _ = viewModel?.loadData()
    }
    
    @objc func saveContact() {
        if let navController = self.navigationController {
            viewModel?.saveContact(isAddContact: isAddContact, navController: navController)
        }
    }
}

extension ContactDetailsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.infoHeaderTitles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return viewModel?.infoTitles[section-1].count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != 0 {
            return viewModel?.infoHeaderTitles[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(hex: 0xF7F7F7)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactDetailsTVC", for: indexPath) as! ContactDetailsTVC

        switch indexPath.section {
        case 0:
            let contactAvatarTVC = tableView.dequeueReusableCell(withIdentifier: "contactAvatarTVC", for: indexPath) as! ContactAvatarTVC
            return contactAvatarTVC
        default:
            cell.setupCell(indexPath: indexPath, viewModel: viewModel)
            cell.tableView = tableView
            cell.isAddContact = isAddContact
            return cell
        }
    }
}

class ContactAvatarTVC: UITableViewCell {
    
    @IBOutlet weak var vwAvatar: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        vwAvatar.layer.cornerRadius = 54
    }
}

class ContactDetailsTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfValue: UITextField!
    
    var viewModel: ContactsVM?
    var indexPath: IndexPath?
    var tableView: UITableView?
    var isAddContact = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        tfValue.delegate = self
        tfValue.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupCell(indexPath: IndexPath, viewModel: ContactsVM?) {
        self.viewModel = viewModel
        self.indexPath = indexPath
        lbTitle.text = viewModel?.infoTitles[indexPath.section-1][indexPath.row]
        tfValue.text = viewModel?.profileInfoArray[indexPath.section-1][indexPath.row]
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel?.setInfoValue(title: lbTitle.text ?? "", value: textField.text ?? "")
    }
}

extension ContactDetailsTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .next:
            let nextCell = tableView?.cellForRow(at: viewModel?.getNextIndexPath(indexPath: indexPath ?? IndexPath()) ?? IndexPath()) as? ContactDetailsTVC
            nextCell?.tfValue.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let indexPath = indexPath {
            if viewModel?.isLastItem(indexPath: indexPath) ?? false {
               textField.returnKeyType = .done
            } else {
               textField.returnKeyType = .next
            }
        }
    }
}
