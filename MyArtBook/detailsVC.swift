//
//  detailsVC.swift
//  MyArtBook
//
//  Created by Gökcan Akoya on 10.04.2019.
//  Copyright © 2019 Gökcan Akoya. All rights reserved.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var incomingSelectedPainting = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //select row olduktan sonra viewDidLoad oldugunda gereken bilgileri getirmek icin
        if incomingSelectedPainting != "" {
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest  = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            //filtre ekliyoruz buna predicate deniyor
            //name == %@ esit olduhu yerleri bul *for -> self.incomingSelectedPainting 'e esit oldugu yerleri bul
            fetchRequest.predicate = NSPredicate(format: "name == %@", self.incomingSelectedPainting)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context?.fetch(fetchRequest)
                
                if results!.count > 0 {
                    for result in results as! [NSManagedObject] {
                        nameText.text = self.incomingSelectedPainting
                        
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            self.imageView.image = image
                        }
                    }
                }
            }
            catch{
                
            }
            
        }
        //imageView kullanici ile aksiyona girebilir mi
        imageView.isUserInteractionEnabled = true
        //gesture tanimlama -> @objc metodu olusturuyoruz ve action kismina bunu yaziyoruz
        //
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailsVC.selectImage))
        //imageView a olusturulan gesture ekleme
        imageView.addGestureRecognizer(gestureRecognizer)
        
        //test
        //print(incomingSelectedPainting)

        
    }
    
    @objc func selectImage() {
        //image secmek icin picker classindan faydalanacagiz
        let picker = UIImagePickerController()
        //delegate islemi icin sinifimiza UIImagePickerControllerDelegate, UINavigationControllerDelegate ekliyoruz
        //picker kullanarak kullanicinin galerisine gitmemiz gerekiyor
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        //olusturulan picker present ediliyor
        present(picker, animated: true, completion: nil)
        //kullanici image sectikten sonra didFinishPickingMedia metodunu olusturuyoruz
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //secilen fotografi imageview a atiyoruz fakat dictionary yapisi any dondurmeye kurulu oldugu icin UIImage gibi kabul et diyoruz
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        //appdelegate ulasmak icin
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //bir obje olusturup bunu datamodel e kaydedecegiz
        //once import CoreData yapiyoruz daha sonra;
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //attributes
        newArt.setValue(artistText.text, forKey: "artist")
        newArt.setValue(nameText.text, forKey: "name")
        //year degiskenimiz int oldugu icin kontrollu yapiyoruz
        if let year = Int(yearText.text!) {
            newArt.setValue(year, forKey: "year")
        }
        //image kontrol edecegiz
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newArt.setValue(data, forKey: "image")
        //en sonda context imizi save ediyoruz
        do {
            try
                context.save()
                print("no error")
        }catch{
            print("save process error")
            
        }
        //bildirim gondermek
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Eklendi!"), object: nil)
        //kayit alindiktan sonra ana ekrana donmek icin
        self.navigationController?.popViewController(animated: true)
    }
    
}
