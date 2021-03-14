//
//  ViewController.swift
//  TravelTime
//
//  Created by Taha Cakir on 13.03.2021.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    //    locationda audio da hep manager olarak atarsın bunları,dünya dili öyle yani aslında..
    var locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    var chosenLatitude = Double()
    var chosenLongtitude = Double()
//    seçilen yer eklicez yer boşsa eklemek doluysa göster için başlıyoruz
    var selectedTitle = ""
    var selectedId : UUID?
    var annotationTitle = ""
    var annotationSubTitle = ""
//    var annotationLatitude : Double?
//    var annotationLongtitude : Double? ünlem kullanmamak için
    var annotationLatitude = Double()
    var annotationLongtitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        kendisine döndürüyoruz map i selfe
        mapView.delegate = self
        locationManager.delegate = self
//        accuracy soruyoruz aslında,bestini ver noktası noktasına diye bu,km de var 100 m sapma da var
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        alttaki de loc isteme durumu ne zaman isteyelim sorusu..kullanımda izin iste genelde
        locationManager.requestWhenInUseAuthorization()
//        baslıyor takip.. info plistten privacy ekle loc ile ilgili
        locationManager.startUpdatingLocation()
//        **pinleme**
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLoc(gestureRecognizer:)))
//        state durumu görmek için kullan
        gestureRecognizer.minimumPressDuration = 2
//        kaç saniye basarsa pinliyor onu anlamak içindir.
        mapView.addGestureRecognizer(gestureRecognizer)
//        gesture ekledik burda da.
        if selectedTitle != "" {
//            core data,öbür sayfada table da en altta segue ve didselect yaptık,bunlardan sonra geldik buraya kodlar anlaşılır bence
//            let StringUUID = selectedId!.uuidString
//            print(StringUUID)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let idString = selectedId!.uuidString
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
//            sadece bu id dekileri çağır diyoruz..
            
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            if let subTitle = result.value(forKey: "subtitle") as? String {
                                annotationSubTitle = subTitle
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    if let longtitude = result.value(forKey: "longtitude") as? Double {
            //                            bunları yazdıktan sonra annotation zamanıı
                                        annotationLongtitude = longtitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubTitle
                                        
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongtitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubTitle
                                        
//                                        benimle birlikte hareket etmesin gösterdiğim pinlediğim yerde kalsın diye
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                
                                }
                            }
                            
                        }
                        
                        
                        
//                        bunları iç içe kontrol edebilrisn aslında.. yani şu şekilde yapalım alt alta aynı sırada değil.
                        
                    }
                    
                }
            }catch{
                print("Error")
            }
            
        }else {
//            add new data
        }

        
    }
//    içine değişken koymamızın nedeni aslında birazdan .began .failed ile ilgili gestureları kontrol edicez state ile,bundan dolayı içine bu şekilde yazmamız gerekti.
    @objc func chooseLoc(gestureRecognizer: UILongPressGestureRecognizer) {
//        dediğimiz noktaya geldik aslında neden üstteki fonkta parantez içine yazdık diye,diyoruz ki gesture durumu kontrol ettik basladıgında dedik dokunulan pointleri mapView da göster.
//        eğer başladıysa dedik işlemler başlasın diyoruz..
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongtitude = touchedCoordinates.longitude
//            bunlar değiştirince ben aşağıda save edebilicem chosen diye..
//            üstteki dokunulan koordinatları veriyor.
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
//            annotation pinlemedir. üstü anlarsın zaten..pinleme bunlardır..
        }
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if selectedTitle == "" {
//            boş işe beni al değiştir dedik. ama kullanmıyorum if i gereksiz oluyor.
            //        CLlocation objesi verir 0. enlem ve boylam barındıır CL.
    //        locations[0]
    //        kendi yerimizi almak için kullanıcı yeri
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
    //        zoomlanacak oran aslında bu
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            
//        }else {
//            if else e alma durumu hata yaşamasından dolayı oluyor ben yaşamadım ama yaşanabilir update kısmında lokasyonun.
//        }
        

    }
//    annotation özelleştirme yapıyoruz burdan navigasyon baglayacagız yani seçilen pinlenen yerleri bizim oldugumuz yere uzaklıgını alıcaz.viewFor Annotation demen hatırlatıcı senin için.Formülde farkettiysen diyor ki MKANnnView olarak döndür diyor. as olarak cast etmelisin hata verir öbür türlü..MKPinAnnView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        altta denilen şudur,kullanıcının yerini pin ile göstermek istemiyorum bu fon ondandır.
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "my annotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
//        yaptığımzı şey aşağıda tıklayınca annotationa  bil butoncuk cıkarması ordan da cıkıp navigasyona yönlendiricez aslında..
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            özelleşme başlıyor,canShow baloncuk ile ekstra bilgi verir.
            pinView?.canShowCallout = true
//            annotation rengi için oluşturduk .
            pinView?.tintColor = UIColor.black
//            alttaki ikili de button oluşturduk ve işlevini söyledik type olarak açıp,detay gösteren butondur bu..
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
//            sagda gösterilecke oldugunu belirttik right callout dedik.
            pinView?.rightCalloutAccessoryView = button
            
        }else {
            pinView?.annotation = annotation
        }
        return pinView
    }
//    altta yaptıgıız fonk callout a tıklanma kontrolu yapıyor.
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
//            CLloc a ihtiyacımız var bir iileriki fonk için göreceksin zaten..CLGeo
            let requestLoc = CLLocation(latitude: annotationLatitude, longitude: annotationLongtitude)
            CLGeocoder().reverseGeocodeLocation(requestLoc) { (placemarks, error) in
//                bu işleme closure deniyor. callback func deniyor,placemark bulunan bir şey diyor onu vermelisin ya da error verecek işte..
//                böylelikle if let ile hatalardan kurtulduk yani varsa bu işlemleri yap diyoruz.
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
//                        navigasyon için bir mapItem oluşturdum,mapItem için de placemark objesi gerekli onu da reversegeocode ile alabilirsin..
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
//                        launch opt neyle gideceksin modu söylee diyosun sonrasında driving diyip arabayla oldugunu belirtiyosun.
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    
                    }
                
                }
                
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Place", into: (context)!)
//        if let ile burda kendini garantiye alabilriisn aslında..
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
//        latitude longtitude bulmak için touch.lat veya to.long yapabilirsin enlem boylam için ama class ın başına git bunun için.
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongtitude, forKey: "longtitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            try context?.save()
        }catch{
            print("Error")
        }
        
//        notificationcenter ile mesaj yolla ve direk kaydet yeni eklem yap demek için
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
//        alttaki de bir önceki view controller a götürsün diye..
        navigationController?.popViewController(animated: true)
    }
    


}

