//
//  ElbitHackathonTools.swift
//  SomeApp
//
//  Created by Perry on 17/05/22.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import Contacts
import PhoneNumberKit

class ElbitHackathonTools {
    static func fetchContacts() -> [String: CNContact] {
        let contactStore = CNContactStore()
        var contacts = [String: CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
        ] as [Any]

        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) {
                contact, _ in
                // Array containing all unified contacts from everywhere
//                contacts.append(contact)

//                for phoneNumber in contact.phoneNumbers {
//                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
//                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
//
//                        // Get The Name
//                        let name = contact.givenName + " " + contact.familyName
//                        //                            print(name)
//
//                        // Get The Mobile Number
//                        var mobile = number.stringValue
//                        mobile = mobile.replacingOccurrences(of: " ", with: "")
//
//                        // Parse The Mobile Number
//                        let phoneNumberKit = PhoneNumberKit()
//
//                        do {
//                            let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse(mobile, withRegion: "IN", ignoreType: true)
//                            let countryCode = String(phoneNumberCustomDefaultRegion.countryCode)
//                            let mobile = String(phoneNumberCustomDefaultRegion.nationalNumber)
//                            let finalMobile = "+" + countryCode + mobile
//                            //                                print(finalMobile)
//                        } catch {
//                            //                                print("Generic parser error")
//                        }
//
//                        // Get The Email
//                        var email: String
//                        for mail in contact.emailAddresses {
//                            email = mail.value as String
//                            //                                print(email)
//                        }
//                    }
//                }

                contacts[contact.familyName] = contact
                contacts[contact.givenName] = contact
                contacts[contact.middleName] = contact
            }
            
            print("done iterating \(contacts.count) contacts")
        } catch {
            print("unable to fetch contacts")
        }
        
        return contacts
    }
    
    static func searchContacts(searchPhrase: String) -> [CNContact]? {
        let contactRecords = fetchContacts()
        var foundContacts = [CNContact]()
        searchPhrase.components(separatedBy: " ").forEach { component in
            if let contactRecord = contactRecords[component] {
                foundContacts.append(contactRecord)
            }
        }
        
        📘(foundContacts)
        return foundContacts.isEmpty ? nil : foundContacts
    }

}


public extension CNContact {
    var firstName: String {
        return givenName
    }
}
