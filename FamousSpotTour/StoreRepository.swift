//
//  StoreRepository.swift
//  FamousSpotTour
//
//  Created by Takayasu Nasu on 2021/01/28.
//

import Foundation
import RealmSwift
import FirebaseFirestore

enum Store: String, Codable {
    case spots
    case categories
    case tags
    case last_updated
    case sub_images
}

struct StoreRepository {

    var name: String

    init(name: String) {
        self.name = name
    }

    init() {
        self.name = "spots"
    }

    init(store: Store) {
        self.name = store.rawValue
    }

    let stores: [(Store, Object)] = [
        (.spots, Location()),
        (.categories, CategoryObject()),
        (.last_updated, LastUpdated()),
        (.sub_images, SubImage()),
        (.tags, Tag()),
    ]

    let realm = try! Realm()

    private var databaseStore: Firestore = Firestore.firestore()


    /// Get specific data from Firebase by document id.
    /// - Parameters:
    ///   - id: document id.
    ///   - completeion: closure
    func find(by id: String, completeion: @escaping ([String: Any]) -> Void) {
        databaseStore.collection(self.name).document(id).getDocument{ (document, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let data = document?.data() else { return }
            completeion(data)
        }
    }

    func select(from name: Store, where id: String,  completeion: @escaping ([String: Any]) -> Void) {
        databaseStore.collection(name.rawValue).document(id).getDocument{ (document, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let data = document?.data() else { return }
            completeion(data)
        }
    }

    /// Get All data from Firebase
    /// - Parameter completeion: closure.
    func all(completeion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        databaseStore.collection(self.name).getDocuments{ (documents, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let data = documents else { return }
            completeion(data.documents)
        }
    }

    func findAll(_ name: String, completeion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        databaseStore.collection(name).getDocuments{ (documents, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let data = documents else { return }
            completeion(data.documents)
        }
    }

    func fetchAndSave() {
        for (store, object) in self.stores {
            self.findAll(store.rawValue, completeion: { (collection) in
                self.insert(into: object, value: collection)
            })
        }
    }

    func insert(into Entity: Object, value collection: [QueryDocumentSnapshot]) {
        try! self.realm.write() {
            for document in collection {
                let entity: Object = {
                    switch Entity {
                    case is Location:
                        return Location(document.data())
                    case is CategoryObject:
                        return CategoryObject(document.data())
                    case is LastUpdated:
                        return LastUpdated(document.data())
                    case is SubImage:
                        return SubImage(document.data())
                    case is Tag:
                        return Tag(document.data())
                    default:
                        return Tag(document.data())
                    }
                }()
                self.realm.add(entity, update: .modified)
            }
        }
    }

    func updateIfNeed() {
        self.select(from: .last_updated, where: "id_1", completeion: {(document) in
            let serverDate = (document["last_updated_at"] as! Timestamp).dateValue()
            guard let localDate = realm.object(ofType: LastUpdated.self, forPrimaryKey: 1) else { fatalError("Have not saved data yet!") }
            if serverDate > localDate.lastUpdatedAt {
                print("Update local data.")
                self.deleteAll()
                self.fetchAndSave()
            }
        })
    }

    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }

}
