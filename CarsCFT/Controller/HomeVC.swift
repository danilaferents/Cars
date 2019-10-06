import UIKit
import Firebase
import FirebaseFirestore

class HomeVC: UIViewController, DeleteCollectionViewCellDelegate {
    func deleteCell(id: String) {
//        Cars.removeAll { (car) -> Bool in
//            return car.id == id
//        }
        
        db.collection("Cars").document(id).delete()
    }
    
    //Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Variables
    var Cars = [Car]()
    var selectedCar: Car!
    var db: Firestore!
    var listener: ListenerRegistration!
    
        
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setUpCollectionView()
        let addCarBtn = UIBarButtonItem(image: UIImage(named: Buttnos.newCarBtn), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(addCar))
        addCarBtn.tintColor = .white
    
        
        navigationItem.rightBarButtonItem = addCarBtn
        
        navigationController?.navigationBar.barTintColor = AppColors.Blue
    }
    
    @objc func addCar() {
        performSegue(withIdentifier: Segues.toAddCar, sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setCarsListener()
    }
    func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: Identifiers.CarCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.CarCell)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
        Cars.removeAll()
        collectionView.reloadData()
    }
    
    func setCarsListener() {
        
        listener = db.collection("Cars").addSnapshotListener({ (query, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            query?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let car = Car.init(data: data)
                
                switch(change.type) {
                    
                case .added:
                    self.onDocumentAdded(change: change, car: car)
                case .modified:
                    self.onDocumentModified(change: change, car: car)
                case .removed:
                    self.onDocumentRemoved(change: change)
                @unknown default:
                    print("Unknown case in Snapshot Listener!")
                }
            })
        })
    }

}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func onDocumentAdded(change: DocumentChange, car: Car) {
        //We have only new index
        let newIndex = Int(change.newIndex)
        Cars.insert(car, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }
    
    func onDocumentModified(change : DocumentChange, car: Car)  {
        //       Item changed, but remained in the same position
        if change.oldIndex == change.newIndex {
            let index = Int(change.oldIndex)
            Cars[index] = car
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            //Item changed position
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            Cars.remove(at: oldIndex)
            Cars.insert(car, at: newIndex)
            
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        //We have only old index
        Cars.remove(at: Int(change.oldIndex))
        collectionView.deleteItems(at: [IndexPath(item: Int(change.oldIndex), section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Cars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CarCell, for: indexPath) as? CarCell {
            cell.configureCell(car: Cars[indexPath.row], delegate: self)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCar = Cars[indexPath.row]
        performSegue(withIdentifier: Segues.toEditCar, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toEditCar {
            if let dest = segue.destination as? EditCarVC {
                dest.currCar = selectedCar
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let cellWidth = (width - 30) / 2
        let cellHieght = cellWidth * 1.5
        return CGSize(width: cellWidth, height: cellHieght)
    }
}
