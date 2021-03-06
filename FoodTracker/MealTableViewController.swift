//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Sergey on 16.03.2021.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    var meals = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedMeals = loadMeals() {
            meals += savedMeals
        }else{
            loadSampleMeals()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        // получаем значение из массива по индексу строки
        let meal = meals[indexPath.row]
        // заполняем свойства
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        // Configure the cell...

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.",log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                    fatalError("Неопределенное назначение контроллера \(segue.destination)")
                }
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Неопределен отправитель: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("Выбранная ячейка не была отображена в таблице")
            }
             
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Неожиданный идентификатор перехода; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToMeatList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController,
           let meal = sourceViewController.meal{
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveMeals()
        }
    }
    
    //MARK: Private metods
    private func loadSampleMeals(){
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal(name: "Caprese salad", photo: photo1, rating: 4) else {
            fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal3")
        }
        meals+=[meal1, meal2, meal3]
    }
    
    private func saveMeals() {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path) - Не работает. Ниже современная реализация
        do{
        let data = try NSKeyedArchiver.archivedData(withRootObject: meals, requiringSecureCoding: false)
            try data.write(to: Meal.ArchiveURL)
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        }
        catch{
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
            }
    }
    
    private func loadMeals() -> [Meal]?  {
        //return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
        // также не работает, ниже современная реализация
        do{
            guard let codedData = try? Data(contentsOf: Meal.ArchiveURL) else { return nil }
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(codedData) as? [Meal]
        }catch{
            return nil
        }
    }
}
