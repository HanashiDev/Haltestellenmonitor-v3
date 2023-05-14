//
//  ContactPicker.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 14.05.23.
//

import SwiftUI
import ContactsUI

enum ContactPickerResult {
    case selectedContact(CNContact)
    case cancelled
}

struct ContactPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = CNContactPickerViewController
    let resultHandler: (ContactPickerResult) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPicker>) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: UIViewControllerRepresentableContext<ContactPicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(resultHandler: resultHandler)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let resultHandler: (ContactPickerResult) -> Void
        
        init(resultHandler: @escaping (ContactPickerResult) -> Void) {
            self.resultHandler = resultHandler
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            resultHandler(.selectedContact(contact))
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            resultHandler(.cancelled)
        }
    }
}
