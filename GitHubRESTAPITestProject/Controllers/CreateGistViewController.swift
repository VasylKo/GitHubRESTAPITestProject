//
//  CreateGistViewController.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasyl Kotsiuba on 09.06.16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import Eureka


class CreateGistViewController: FormViewController {
    //MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Gist"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel,
                                                           target: self, action: #selector(self.cancelPressed(_:)))
    }
    
    //MARK: - Form tags
    //Raw value will be tag and title for the row
    private enum Tags: String {
        case descroptionRow         = "Description"
        case isPublicRow            = "isPublic"
        case filenameRow            = "Filename"
        case fileContentRow         = "File Content"
        case createGistButtonRow    = "Create Gist"
    }
    
    //MARK: - Form setup
    private func initializeForm() {
        form +++ Section("Gist info")
        
            <<< TextRow(Tags.descroptionRow.rawValue) {
                $0.title = $0.tag
                $0.placeholder = $0.tag?.lowercaseString
        }
        
            <<< SwitchRow(Tags.isPublicRow.rawValue){
                $0.title = $0.tag
        }
        
        form +++ Section("File info")
        
            <<< TextRow(Tags.filenameRow.rawValue) {
                $0.title = $0.tag
                $0.placeholder = $0.tag?.lowercaseString
        }
        
            <<< TextAreaRow(Tags.fileContentRow.rawValue) {
                $0.placeholder = $0.tag
        }
        
        form +++ Section()
            <<< ButtonRow(Tags.createGistButtonRow.rawValue) {
                $0.title = $0.tag
        }.onCellSelection{ [weak self] (cell, row) in
            self?.createNewGist()
        }
    }
    
    //MARK: - Create gist
    private func createNewGist() {
        guard let formValues = readFormValuesIfValid() else { return }
        
        let files:[File] = [File(name: formValues.fileName, content: formValues.fileContent)]
        
        GitHubAPIManager.sharedInstance.createNewGist(formValues.gistDescription, isPublic: formValues.isBublicGist, files: files) { [weak self] (result) in
            guard let strongSelf = self else { return }
            guard result.error == nil else {
                print("ERROR: \(result.error!.localizedDescription)")
                showMessage(type: .warning, title: "Could not create gist.", subtitle: result.error!.localizedDescription)
                return
            }
            
            if result.value! {
                strongSelf.dismissViewControllerAnimated(true, completion: nil)
                showMessage(type: .success, title: "New gist added!", duration: 1)
            } else {
                showMessage(type: .warning, title: "Could not create gist.", subtitle: "Something went wrong. Please try again.")
            }
        }
    }
    
    func cancelPressed(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helper methods
    private func validate(value: String?, forTag tag: String?) -> Bool {
        guard !(value?.isEmpty ?? true) else {
            showAlert(title: "Incomplete info", message: "Please fill \(tag ?? "all fields")")
            return false
        }
        
        return true
    }
    
    private func showAlert(title title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        // add ok button
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated:true, completion: nil)
    }
    
    private func readFormValuesIfValid() -> (gistDescription: String, isBublicGist: Bool, fileName: String, fileContent: String)? {
        guard let descriptionRow = form.rowByTag(Tags.descroptionRow.rawValue) as? TextRow,
            isPublicRow = form.rowByTag(Tags.isPublicRow.rawValue) as? SwitchRow,
            filenameRow = form.rowByTag(Tags.filenameRow.rawValue) as? TextRow,
            fileContentRow = form.rowByTag(Tags.fileContentRow.rawValue) as? TextAreaRow
            else { fatalError("From error! Can't get rows!") }
        
       guard    validate(descriptionRow.value, forTag: descriptionRow.tag) &&
                validate(filenameRow.value, forTag: filenameRow.tag) &&
                validate(fileContentRow.value, forTag: fileContentRow.tag) else { return nil }
        
        let gistDescription = descriptionRow.value ?? ""
        let isBublicGist = isPublicRow.value ?? false
        let fileName = filenameRow.value ?? ""
        let fileContetnt = fileContentRow.value ?? ""
        
        return (gistDescription, isBublicGist, fileName, fileContetnt)
    }
}
