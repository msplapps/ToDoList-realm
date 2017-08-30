//
//  ViewController.swift
//  ToDoList
//
//  Created by Harshvardhan Agarwal on 28/08/17.
//  Copyright © 2017 Purushotham. All rights reserved.
//

import UIKit
import RealmSwift


// MARK: Model

final class TaskList: Object {
    dynamic var text = ""
    dynamic var id = ""
    let items = List<Task>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Task: Object {
    dynamic var text = ""
    dynamic var completed = false
 
}

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
        var items = List<Task>()
        var realm: Realm!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Tasks"
        navigationItem.leftBarButtonItem = editButtonItem
        self.tableView.dataSource = self
        self.tableView.delegate = self
           items.append(Task(value: ["text": "My First Task"]))
          updateList()
        //print database path in console
 print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // Show initial tasks
    func updateList()  {
        let tasks: Results<Task>
         do{
        realm = try Realm()
           tasks =  realm.objects(Task.self)
            
        }catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        
//        if self.items.realm == nil, let list = self.realm.objects(TaskList.self).first {
//            self.items = list.items
//        }
        
   //     let tasks = updateList()
        
        items.removeAll(keepingCapacity: false)
        for i in 0..<tasks.count {
            items.append(tasks[i])
        }

        self.tableView.reloadData()
    }
    
    // MARK: Functions
    
  
    @IBAction func btnEditTapped(_ sender: Any) {
        
        self.tableView.isEditing = !self.tableView.isEditing
    }
    
    @IBAction func btnAddTapped(_ sender: Any) {
        
        add()
    }
    
    func add() {
        let alertController = UIAlertController(title: "New Task", message: "Enter Task Name", preferredStyle: .alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Task Name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
//            let items = self.items
//            try! items.realm?.write {
//                items.insert(Task(value: ["text": text]), at: items.filter("completed = false").count)
//            }
            
            do{
                let realm = try Realm()
                try realm.write {
                    realm.add(Task(value: ["text": text]))
                }
            }catch let error as NSError{
                fatalError(error.localizedDescription)
            }
             self.updateList()
            
        })
        present(alertController, animated: true, completion: nil)
       
       }

    
    // MARK: UITableView
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.alpha = item.completed ? 0.5 : 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! items.realm?.write {
            items.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
      
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let item = items[indexPath.row]
                realm.delete(item)
            }
        }
        items.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    
}

