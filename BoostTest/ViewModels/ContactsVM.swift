//
//  ContactsVM.swift
//  BoostTest
//
//  Created by Sonya Hew on 11/06/2021.
//

import UIKit

class ViewModelBase {
    weak var targetView: UIView?

    init(view: UIView?) {
        self.targetView = view
    }
}

class ContactsVM: ViewModelBase {
    
    private weak var navController: UINavigationController?
    private weak var view: UIView?
    private var localJsonData = Bundle.main.url(forResource: "data", withExtension: "json")
    
    var profileModel: [ProfileModel] = []
    var profileInfoArray: [[String]] = []
    var newProfileEntry = ProfileModel()
    
    let contactDetailsVC = getVC(sb: "Main", vc: "ContactDetailsVC") as! ContactDetailsVC
    
    let infoHeaderTitles = ["", "Main Information", "Sub Information"]
    let infoTitles = [["First Name", "Last Name"], ["Email", "Phone"]]
    
    var selectedIndex = 0;
    
    init(view: UIView?, navController: UINavigationController?) {
        self.navController = navController
        super.init(view: view)
        resetTextFields()
        loadData()
    }
    
    func editContact(indexPath: IndexPath) {
        selectedIndex = indexPath.row
        getProfileInfoArray()
        contactDetailsVC.viewModel = self
        contactDetailsVC.isAddContact = false
        navController?.pushViewController(contactDetailsVC, animated: true)
    }
    
    func getProfileInfoArray() {
        let profileData = profileModel[selectedIndex]
        profileInfoArray = [
            [profileData.firstName ?? "", profileData.lastName ?? ""],
            [profileData.email ?? "", profileData.phone ?? ""]
        ]
    }
    
    func resetTextFields() {
        profileInfoArray = [["", ""], ["", ""]]
    }
    
    func setInfoValue(title: String, value: String) {
        switch title {
        case "First Name":
            profileModel[selectedIndex].firstName = value
            newProfileEntry.firstName = value
        case "Last Name":
            profileModel[selectedIndex].lastName = value
            newProfileEntry.lastName = value
        case "Email":
            profileModel[selectedIndex].email = value
            newProfileEntry.email = value
        case "Phone":
            profileModel[selectedIndex].phone = value
            newProfileEntry.phone = value
        default:
            print("error")
        }
    }
    
    func getNextIndexPath(indexPath: IndexPath) -> IndexPath {
        if !isLastItem(indexPath: indexPath) {
            if indexPath.row == infoTitles[indexPath.section-1].count-1 {
                return IndexPath(row: 0, section: indexPath.section+1)
            } else {
                return IndexPath(row: indexPath.row+1, section: indexPath.section)
            }
        } else {
            return IndexPath(row: 0, section: 0)
        }
    }

    func isLastItem(indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(row: infoTitles[indexPath.section-1].count-1, section: infoTitles.count) ? true : false
    }
    
    func saveContact(isAddContact: Bool, navController: UINavigationController) {
        var firstName = ""
        var lastName = ""
        
        if isAddContact {
            firstName = newProfileEntry.firstName?.replacingOccurrences(of: " ", with: "") ?? ""
            lastName = newProfileEntry.lastName?.replacingOccurrences(of: " ", with: "") ?? ""
        } else {
            firstName = profileModel[selectedIndex].firstName?.replacingOccurrences(of: " ", with: "") ?? ""
            lastName = profileModel[selectedIndex].lastName?.replacingOccurrences(of: " ", with: "") ?? ""
        }
        
        if firstName == "" || lastName == "" {
            showAlertMsg(title: "Oops!", message: "Please fill in your first name and last name.", navController: navController)
        } else {
            if isAddContact {
                loadData()
                profileModel.insert(newProfileEntry, at: 0)
                writeData()
                showAlertMsg(title: "Success", message: "New Contact Added!", navController: navController)
            } else {
                writeData()
                showAlertMsg(title: "Success", message: "Contact Updated!", navController: navController)
            }
        }
    }
    
    func loadData() {
        if let url = localJsonData {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([ProfileModel].self, from: data)
                profileModel = jsonData
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    func writeData() {
        if let url = localJsonData {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let jsonData = try encoder.encode(profileModel)
                try jsonData.write(to: url)
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    func showAlertMsg(title: String, message: String, navController: UINavigationController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            navController.popViewController(animated: true)
            navController.dismiss(animated: true, completion: nil)
        }))
        navController.present(alertController, animated: true, completion: nil)
    }
}
