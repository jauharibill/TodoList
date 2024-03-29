//
//  ViewTableViewController.swift
//  TodoList
//
//  Created by Idris on 23/06/19.
//  Copyright © 2019 IdrisLabs. All rights reserved.
//

import UIKit
import CoreData

class ViewTableViewController: UITableViewController {
    var selectedCategory:Category?{
        didSet{
            let request:NSFetchRequest<Item> = Item.fetchRequest()
            loadItems(with: request)
        }
    }
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        loadItems(with: request,nPredicate: predicate)
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return itemArray.count
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
//        itemArray[indexPath.row]
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFieldItem = UITextField()
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            textFieldItem = textField
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let itemName = textFieldItem.text{
                let newItem = Item(context: self.context)
                    newItem.title = itemName
                    newItem.done  = false
                    newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                self.saveItems()
                
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        do{
            try context.save()
        }
        catch{
            print("error")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request:NSFetchRequest<Item>,nPredicate:NSPredicate? = nil){
        let itemPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = nPredicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [itemPredicate,additionalPredicate])
        }
        else{
            request.predicate = itemPredicate
        }
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [itemPredicate,nPredicate!])
//
//        request.predicate = compoundPredicate
        do{
            itemArray = try context.fetch(request)
        }
        catch{
            print("error")
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ViewTableViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title contains[cd] %@", searchBar.text!)
        request.predicate = predicate
        let sortDescript = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescript]
        
        loadItems(with: request,nPredicate: predicate)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            let request:NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title contains[cd] %@", searchBar.text!)
            request.predicate = predicate
            loadItems(with: request,nPredicate: predicate)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}
