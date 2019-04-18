//
//  ViewController.swift
//  MyArtBook
//
//  Created by Gökcan Akoya on 10.04.2019.
//  Copyright © 2019 Gökcan Akoya. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    //verileri cekmek icin dizilerimizi olusturuyoruz
    var nameArray = [String]()
    var artistArray = [String]()
    var yearArray = [Int]()
    var imageArray = [UIImage]()
    //secilen rowun indexini tutmak icin
    var selectedPainting = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableview olusturuyoruz ve UITableViewDelegate, UITableViewDataSource ekliyoruz
        tableView.delegate = self
        tableView.dataSource = self
        getInfo()
    }
    //viewDidLoad dan farki bu her acildiginda cagirilir didload tek bir kere cagirilir
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.getInfo), name: NSNotification.Name("Eklendi!"), object: nil)
    }
    
    @objc func getInfo() {
        //tableview tekrar aktiflestiginde onceki verileri temizlemek icin
        nameArray.removeAll(keepingCapacity: false)
        artistArray.removeAll(keepingCapacity: false)
        yearArray.removeAll(keepingCapacity: false)
        imageArray.removeAll(keepingCapacity: false)
        //appdelegate ulasmak icin CoreData import ediyoruz oncelikle daha sonra context olusturuyoruz
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        //verileri cekmek icin request olusturuyoruz
        let fetchRequest  = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        //verileri cekiyoruz
        do {
            let results = try context?.fetch(fetchRequest)
            
            if results!.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                }
                    if let artist = result.value(forKey: "artist") as? String{
                        self.artistArray.append(artist)
                    }
                    if let year = result.value(forKey: "year") as? Int{
                        self.yearArray.append(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data{
                        let image = UIImage(data: imageData)
                        self.imageArray.append(image!)
                    }
                    self.tableView.reloadData()
                }
            }
            
        }
        catch{
            print("error fetch request!")
        }
        
    }
    //silme islemi icin ve yana kaydirinca delete butonu cikmasi icin
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delegate islemleri
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            let fetchRequest  = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            //fetch yapip siliyoruz
            do{
                let results = try context?.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        if name == nameArray[indexPath.row] {
                            context?.delete(result)
                            nameArray.remove(at: indexPath.row)
                            artistArray.remove(at: indexPath.row)
                            yearArray.remove(at: indexPath.row)
                            imageArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            do{
                            try context?.save()
                            }
                            catch {
                                print("delete process error")
                            }
                            break
                        }
                    }
                }
            }
            catch{
                
            }

        }
    }
    
    //hücre sayisi override edilecek fonksiyon
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //nameArray dizisinin boyutu kadar hucre olusturuyoruz
        return nameArray.count
    }
    //table view icerigi
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //nameArray den aliyoruz hucre teztlerini
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! detailsVC
            destinationVC.incomingSelectedPainting = selectedPainting
        }
        
    }
    
    //tableview tiklandiginda cagirilacak fonksiyon didSelectRow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        //fakat segue olmadan once verileri gondermeliyiz bunun icinde yukaridaki prepareforSegue metodunu yaziyoruz
    }

    @IBAction func addButtonClicked(_ sender: Any) {
        //segue yapmadan once selectedPainting bos kabul ediyoruz ki bir onceki secilen resim bize tekrar gosgerilmesin
        selectedPainting = ""
        //dateilsVC ekranina gidis
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
}

