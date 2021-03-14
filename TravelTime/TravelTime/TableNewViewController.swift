//
//  TableNewViewController.swift
//  TravelTime
//
//  Created by Taha Cakir on 14.03.2021.
//

import UIKit
import CoreData


class TableNewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var chosenTitle = ""
    var chosenTitleId = UUID()
    @IBOutlet weak var tableView1: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView1.delegate = self
        tableView1.dataSource = self
        
        
        
        
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()

        
    }
    override func viewWillAppear(_ animated: Bool) {
//        observer ekleyelim ki görünce calıstırsın newPlace i
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    @objc func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
//                temizleme yap ki for loopundan önce sorun yaşama boş yere
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    tableView1.reloadData()
                
                }
            }
            
        }catch{
            print("Error")
        }
        
        
        
        
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    @objc func addButtonClicked() {
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
//    alttaki ikili add buttondan gidiyosa bu yoldan normal tableView dan giderse yarı yol diye..
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedId = chosenTitleId
            
        }
        
    }
    

    
}
