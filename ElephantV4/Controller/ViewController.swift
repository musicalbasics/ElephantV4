import UIKit

let model = Model()

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var completeRateLabel: UILabel!
    @IBOutlet weak var totalTasksLabel: UILabel!
    @IBOutlet weak var dailyRateLabel: UILabel!
    
    @IBOutlet weak var itemTableView: UITableView!
    
//    var currentSelection: Item = Item(title: "Placeholder", timeDone: Date(), project: "None", uniqueNum: 0, status: "Active")
    var currentSelection: Placeholder = Placeholder(title: "Placeholder", project: "None", indx: 0, status: "Active")
    var currentIndx = 0
    var numItemsShown = 1
    var timer = Timer()
    var (hours, minutes, seconds) = (0, 0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTableView.delegate = self
        itemTableView.dataSource = self
        
        
        currentSelection = model.activeArray[0]
        itemTableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        timeLabel.numberOfLines = 0;
        timeLabel.lineBreakMode = .byWordWrapping;
        itemTableView.reloadData()
    }
    
//MARK: - Navigation Bar
    
    @IBAction func refreshDataPressed(_ sender: UIBarButtonItem) {
        self.itemTableView.reloadData()
    }
    
    
//MARK: - 1st Button Row
    
    
    @IBAction func addItemPressed(_ sender: UIButton) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Item With None Project", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItemName = textField.text!
            
            model.addItemToNoneProject(itemName: newItemName)
            
            model.saveItems()
            self.itemTableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Text for Item"
            textField = alertTextField
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancelled")
        })
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)


    }
    
    @IBAction func editItemPressed(_ sender: UIButton) {
        
        //get current placeholder
        var currentPlaceholder = model.activeArray[safe: currentIndx]
        
        let projLookup = currentPlaceholder!.project
        let numIndex = currentPlaceholder!.indx
        print(numIndex)
        
        var textField = UITextField()
//        if var currentItem = model.projectDictionary[projLookup]?.activeItems[safe: numIndex] {
        if var currentItem = model.projectDictionary[projLookup]?.objectiveList[0].items[safe: numIndex] {
            let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Edit Item", style: .default) { (action) in
                currentItem.title = textField.text!
                
                
//                model.projectDictionary[currentItem.project]?.activeItems[numIndex] = currentItem
                let lookupActiveIndex = model.projectDictionary[currentItem.project]?.activeItems.firstIndex { $0.uniqueNum == currentItem.uniqueNum }
                model.projectDictionary[currentItem.project]?.activeItems[lookupActiveIndex!] = currentItem
                
                model.projectDictionary[currentItem.project]?.objectiveList[0].items[numIndex] = currentItem
                model.saveItems()
                self.itemTableView.reloadData()
            }
            
            alert.addAction(action)
            
            alert.addTextField { (alertTextField) in
                alertTextField.text = currentItem.title
                textField = alertTextField
            }

            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                print("Cancelled")
            })
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)

        }
        
    }
                
        
        
        
        
        
        
    
    
    
    
    @IBAction func completeItemPressed(_ sender: UIButton) {
        model.completeItem(index: currentIndx)
        model.activateNextItem()
        model.saveItems()
        self.itemTableView.reloadData()
        
        if let checkEmpty = model.activeArray[safe: 0] {
            currentSelection = model.activeArray[0]
        } else {
            currentSelection = Placeholder(title: "Placeholder", project: "None", indx: 0, status: "Active")
        }
//        self.currentSelection = model.activeArray[0]
        
        timer.invalidate()
        (hours, minutes, seconds) = (0, 0, 0)
        timeLabel.text = "00:00:00"
        startButtonOutlet.isHidden = false
        startTimer()
        totalTasksLabel.text = "Total Tasks: \(model.activeArray.count)"
        
    }
    
    
    
//MARK: - 2nd Button Row
    
    
    
    @IBAction func showMorePressed(_ sender: UIButton) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Choose Number Of Items Shown", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Choose Number Of Items Shown", style: .default) { (action) in
            let numItemsSelected = textField.text!
            let intNumItemsSelected = Int(numItemsSelected)
            self.numItemsShown = intNumItemsSelected!
            self.itemTableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Integer"
            textField = alertTextField
        }
        alert.addAction(action)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancelled")
        })
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    
    
    
    @IBAction func showItemProjectPressed(_ sender: UIButton) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let projSelected = model.projectDictionary[currentSelection.project]
        
        
        
        if (segue.identifier == "showProjectOfItem") {
            let viewController = segue.destination as? ProjectItemsViewController
            viewController?.selectedProject = projSelected!
        }
    }
    
    
    
    @IBAction func backupPlistPressed(_ sender: UIButton) {
        model.backupPlistFiles()
        let alert = UIAlertController(title: "Files Saved.", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    
    
    
//MARK: - Third Button Row
    
    @IBAction func completeObjectivePressed(_ sender: UIButton) {
        let currentProjectName = currentSelection.project
        let currentProject = model.projectDictionary[currentProjectName]
        let currentObjective = currentProject?.objectiveList[0]
        model.completeObjective(objective: currentObjective!)
        
        
        
        itemTableView.reloadData()
    }
    
    
    @IBAction func completeProjectPressed(_ sender: UIButton) {
        let currentProjectName = currentSelection.project
        let currentProject = model.projectDictionary[currentProjectName]
        model.completeProject(project: currentProject!)
        
        itemTableView.reloadData()
    }
    
    
    
    
    
    
//MARK: - TABLE VIEW METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numItemsShown
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ItemCell
        
        
        if let currentPlaceholder = model.activeArray[safe: indexPath.row] {
            let projLookup = currentPlaceholder.project
//            let numIndex = currentItem.indx
            
            var itemShown = ""
            var objectiveShown = ""
            
            
//            if let currentItem = model.projectDictionary[projLookup]?.activeItems[safe: currentPlaceholder.indx] {
            if let currentItem = model.projectDictionary[projLookup]?.objectiveList[0].items[safe: currentPlaceholder.indx]{
                
                itemShown = currentItem.title
                objectiveShown = currentItem.objective
            } else {
                itemShown = currentPlaceholder.title + String(currentPlaceholder.indx)
                objectiveShown = ""
            }
            
            
//            itemShown = currentPlaceholder.title + String(currentPlaceholder.indx)
            
            cell.titleLabel.text = itemShown
    //        cell.titleLabel.text = model.activeArray[indexPath.row].title
            cell.titleLabel?.numberOfLines = 0;
            cell.titleLabel?.lineBreakMode = .byWordWrapping;
            
            cell.objectiveLabel.text = "Objective: \(objectiveShown)"
            cell.objectiveLabel?.numberOfLines = 0;
            cell.objectiveLabel?.lineBreakMode = .byWordWrapping;

            cell.projLabel.text = "Project: \(currentPlaceholder.project)"
            cell.projLabel?.numberOfLines = 0;
            cell.projLabel?.lineBreakMode = .byWordWrapping;
        } else {
            cell.titleLabel.text = "NO MORE"
            cell.titleLabel?.numberOfLines = 0;
            cell.titleLabel?.lineBreakMode = .byWordWrapping;
            
            cell.objectiveLabel.text = "NO MORE"
            cell.objectiveLabel?.numberOfLines = 0;
            cell.objectiveLabel?.lineBreakMode = .byWordWrapping;

            cell.projLabel.text = "NO MORE"
            cell.projLabel?.numberOfLines = 0;
            cell.projLabel?.lineBreakMode = .byWordWrapping;
        }
        
//        let currentItem = model.activeArray[indexPath.row]
        

        
//        if let currentItem = model.projectDictionary[projLookup]?.activeItems[0] {
//            cell.titleLabel.text = currentItem.title
//        }
        


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let currentSelect = model.activeArray[safe: indexPath.row] {
            currentSelection = currentSelect
            currentIndx = indexPath.row
        }
    }
    
    

    
//MARK: - TIMER STACK
    
    @IBAction func startTimerButton(_ sender: UIButton) {
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.keepTimer), userInfo: nil, repeats: true)
        startButtonOutlet.isHidden = true
    }
    
    @IBAction func pauseTimerButton(_ sender: UIButton) {
        timer.invalidate()
        startButtonOutlet.isHidden = false
    }
    
    @objc func keepTimer() {
        seconds += 1
        
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        
        if minutes == 60 {
            hours += 1
            minutes = 0
        }
        
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        
        timeLabel.text = "Time Spent: \(hoursString):\(minutesString):\(secondsString)"
    }
}









//extension Collection {
//    /// Returns the element at the specified index if it is within bounds, otherwise nil.
//    subscript (safe index: Index) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}
