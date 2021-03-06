//
//  MyPageTableViewController.swift
//  FamousSpotTour
//
//  Created by Adriano Gaiotto de Oliveira on 2021-01-25.
//

import UIKit
import RealmSwift

class MyPageTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let stepProfile: [String] = ["Picture","Name","Progress","Segment","SpotList"]
    
    let cellPic = "cellPic"
    let cellNam = "cellNam"
    let cellProg = "cellProg"
    let cellSeg = "cellSeg"
    let cellList = "cellList"
    
    var personalUserDatas: PersonalUserData = PersonalUserData.defaultUserData {
        didSet {
            PersonalUserData.saveToFile(userDatas: personalUserDatas)
        }
    }
    
    let realm = try! Realm()
    
    var locations : [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Page"
        view.backgroundColor = .white
        
        
        tableView.register(PictureTVC.self, forCellReuseIdentifier: cellPic)
        tableView.register(LabelTVC.self, forCellReuseIdentifier: cellNam)
        tableView.register(ProgressTVC.self, forCellReuseIdentifier: cellProg)
        tableView.register(SegmentTVC.self, forCellReuseIdentifier: cellSeg)
        tableView.register(SpotListTVC.self, forCellReuseIdentifier: cellList)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = nil
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: CGFloat.leastNormalMagnitude))
        tableView.separatorColor = .clear;
        
        // load UserData
        if let savedPersonalUserData = PersonalUserData.loadFromFile() {
            personalUserDatas = savedPersonalUserData
        } else {
            PersonalUserData.saveToFile(userDatas: personalUserDatas)
        }
        
        UpdateLocations(option: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // display tab bar
        tabBarController?.tabBar.isHidden = false
        // display nav bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateProgress()
        UpdateLocations(option: 0)
    }
    
    func updateProgress() {
        let locationData: [UserData] = UserData.loadFromFile() ?? []
        let achieves : Int = calcAchieves(locationData: locationData)
        
        let locationCount = self.realm.objects(Location.self).count
        
        let cell = tableView.cellForRow(at: IndexPath.init(item: 2, section: 0)) as! ProgressTVC
        
        cell.did.text = "\(achieves)"
        cell.todo.text = "\(locationCount)"
        
        let perc = CGFloat( achieves * 100 / locationCount)
        
        cell.percent.text = "\(String(format: "%.0f",perc))% achieved"
        
        
        cell.progressLayer.strokeEnd = perc / 100
    }
    
    func calcAchieves(locationData :  [UserData]) -> Int {
        var count = 0
        for data in locationData {
            if data.isVisited {
                count += 1
            }
        }
        return count
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepProfile.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let imageWidth = view.bounds.width * 0.5
        let fontWidth = view.bounds.width * 0.4
        
        switch stepProfile[indexPath.row] {
        case "Picture":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellPic, for: indexPath) as! PictureTVC
            cell.container.backgroundColor = UIColor(hex: "#3EC6FF")
            cell.container.frame = .init(x: 0, y: 0, width: view.bounds.width, height: imageWidth)
            cell.profile.frame = .init(x: view.bounds.width / 2 - (imageWidth / 2), y: imageWidth * 0.3
                                       , width: imageWidth, height: imageWidth)
            cell.profile.layer.cornerRadius = imageWidth / 2
            cell.profile.layer.shadowPath = UIBezierPath(rect: cell.profile.bounds).cgPath
            print(personalUserDatas.userPicture.isEmpty)
            if !personalUserDatas.userPicture.isEmpty {
                cell.profile.image = UIImage(data: personalUserDatas.userPicture)
            }
            cell.changePictureButton.frame = .init(x: view.bounds.width / 2 + (imageWidth / 4), y: imageWidth, width: view.bounds.width * 0.1, height: view.bounds.width * 0.1)
            cell.changePictureButton.addTarget(self,action: #selector(changePicture(_:)),for: .touchUpInside)
            cell.changePictureButton.titleLabel?.font = .boldSystemFont(ofSize: fontWidth / 6)
            return cell
        case "Name":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellNam, for: indexPath) as! LabelTVC
            cell.name.frame = .init(x: 0 , y: 0 , width: view.bounds.width, height: view.bounds.width * 0.2)
            cell.name.textAlignment = .center
            cell.name.font = .boldSystemFont(ofSize: fontWidth / 6)
            cell.name.text = personalUserDatas.username
            cell.editButton.frame = .init(x: view.bounds.width * 0.9, y: view.bounds.width * 0.05, width: view.bounds.width * 0.1, height: view.bounds.width * 0.1)
            cell.editButton.addTarget(self,action: #selector(editMode(_:)),for: .touchUpInside)
            cell.editButton.titleLabel?.font = .boldSystemFont(ofSize: fontWidth / 6)
            cell.nameT.frame = .init(x: view.bounds.width * 0.1 , y: view.bounds.width * 0.05, width: view.bounds.width * 0.8, height: view.bounds.width * 0.1)
            cell.nameT.textAlignment = .center
            cell.nameT.font = .boldSystemFont(ofSize: fontWidth / 6)
            cell.saveButton.frame = .init(x: view.bounds.width * 0.9, y: view.bounds.width * 0.05, width: view.bounds.width * 0.1, height: view.bounds.width * 0.1)
            cell.saveButton.addTarget(self,action: #selector(editMode(_:)),for: .touchUpInside)
            cell.saveButton.titleLabel?.font = .boldSystemFont(ofSize: fontWidth / 6)
            return cell
        case "Progress":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellProg, for: indexPath) as! ProgressTVC
            let path = UIBezierPath(arcCenter: CGPoint(x: view.bounds.width / 2, y: cell.bounds.height / 2), radius: imageWidth / 2, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
            cell.circleLayer.path = path.cgPath
            cell.progressLayer.path = path.cgPath
            
            cell.stackV.centerXYin(cell)
            cell.todo.font = .boldSystemFont(ofSize: fontWidth / 6)
            cell.slash.font = .boldSystemFont(ofSize: fontWidth / 6)
            cell.did.font = .boldSystemFont(ofSize: fontWidth / 6)
            cell.percent.font = .systemFont(ofSize: fontWidth / 12)
            return cell
        case "Segment":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellSeg, for: indexPath) as! SegmentTVC
            cell.optionList.frame = .init(x: 10 , y: view.bounds.width * 0.05, width: view.bounds.width - 20, height: view.bounds.width * 0.1)
            
            cell.optionList.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontWidth / 8),NSAttributedString.Key.foregroundColor: UIColor(hex:"#3EC6FF")], for: .selected)
            cell.optionList.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontWidth / 8),NSAttributedString.Key.foregroundColor: UIColor.lightGray ], for: .normal)
            cell.optionList.addTarget(self, action: #selector(changeOption(sender:)), for: .valueChanged)
            return cell
        case "SpotList":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellList, for: indexPath) as! SpotListTVC
            cell.locList.view.frame = .init(x: 0, y: 0, width: view.bounds.width , height: view.bounds.height + (view.bounds.width * 1.3))
            if locations.count == 0 { cell.isHidden = true } else { cell.isHidden = false }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func editMode(_ sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath.init(item: 1, section: 0)) as! LabelTVC
        if cell.name.isHidden {
            if cell.nameT.text != "" {
                cell.name.text = cell.nameT.text
                personalUserDatas.username = cell.name.text!
            }
            cell.name.isHidden.toggle()
            cell.nameT.isHidden.toggle()
            cell.editButton.isHidden.toggle()
            cell.saveButton.isHidden.toggle()
        } else {
            cell.name.isHidden.toggle()
            cell.nameT.isHidden.toggle()
            cell.editButton.isHidden.toggle()
            cell.saveButton.isHidden.toggle()
            if cell.name.text == "Username" {
                cell.nameT.text = ""
            }
        }
    }
    
    @objc func changePicture(_ sender: UIButton) {
        let cellName = tableView.cellForRow(at: .init(row: 1, section: 0)) as! LabelTVC
        if cellName.name.isHidden {
            cellName.name.isHidden.toggle()
            cellName.nameT.isHidden.toggle()
            cellName.editButton.isHidden.toggle()
            cellName.saveButton.isHidden.toggle()
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photolibAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photolibAction)
        }
        
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = sender
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        let cell = tableView.cellForRow(at: IndexPath.init(item: 0, section: 0)) as! PictureTVC
        cell.profile.image = selectedImage
        
        personalUserDatas.userPicture = selectedImage.pngData()!
        
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat()
        switch stepProfile[indexPath.row] {
        case "Picture":
            height = CGFloat.init(view.bounds.width * 0.5 + (view.bounds.width * 0.5) * 0.3)
        case "Name":
            height = CGFloat.init(view.bounds.width * 0.2)
        case "Progress":
            height = CGFloat.init(view.bounds.width * 0.6)
        case "Segment":
            height = CGFloat.init(view.bounds.width * 0.2)
        default:
            height = CGFloat.init(locations.count * 285)
        }
        
        return height
    }
    
    @objc func changeOption(sender: UISegmentedControl) {
        
        
        let cell = tableView.cellForRow(at: IndexPath.init(item: 4, section: 0)) as! SpotListTVC
        
        UpdateLocations(option: sender.selectedSegmentIndex )
        
        
        
    }
    
    func UpdateLocations(option: Int) {
        let locationData: [UserData] = UserData.loadFromFile() ?? []
        let location = self.realm.objects(Location.self)
        
        switch option {
        
        case 0:
            locations = []
            for spot in locationData {
                if spot.isLike {
                    locations.append(location[spot.locationId-1])
                }
            }
        case 1:
            locations = []
            for spot in locationData {
                if spot.isVisited{
                    locations.append(location[spot.locationId-1])
                }
            }
            
        default:
            
            print("Not")
            
        }
        
        if let cell = tableView.cellForRow(at: IndexPath.init(item: 4, section: 0)) as? SpotListTVC {
            cell.locList.locations = locations
            cell.locList.tableView.reloadData()
            if locations.count == 0 { cell.isHidden = true } else { cell.isHidden = false }
            tableView.reloadData()
        }
        
        
    }
    
    
    
    
}
