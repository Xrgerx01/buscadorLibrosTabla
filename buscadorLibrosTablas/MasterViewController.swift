//
//  MasterViewController.swift
//  buscadorLibrosTablas
//
//  Created by XrgerX on 10/09/16.
//  Copyright © 2016 XrgerX. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    private var libros = [Libro]()
    private var libroISBN : [String] = [String]()
    var contexto : NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Carga Informacion de Libros Grabados
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let seccionEntidad = NSEntityDescription.entityForName("Seccion", inManagedObjectContext: self.contexto!)
        let peticion = seccionEntidad?.managedObjectModel.fetchRequestTemplateForName("petSecciones")
        
        do{
            
            let seccionesEntidad = try self.contexto?.executeFetchRequest(peticion!)
            for seccionEntidad2 in seccionesEntidad! {
                let nombre = seccionEntidad2.valueForKey("nombre") as! String
                let librocarga : Libro? = self.obtieneData(nombre)
                self.libros.insert(librocarga!, atIndex: 0)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        catch{
            
        }

        // Seccion de Button
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func obtieneData(codeISBN: String) ->Libro?{
        var libro :Libro? = nil
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + codeISBN
        let url = NSURL(string: urls)
        let datos = NSData(contentsOfURL: url!)
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dico1 = json as! NSDictionary
            let dico2 = "ISBN:" + codeISBN
            if let valorLibro = dico1[dico2] {
                libro = ejecutaLibro(valorLibro as! NSDictionary, code: codeISBN)
            }
        }catch _ {
            print("Error")
        }
        return libro
    }
    
    func ejecutaLibro(data: NSDictionary, code: String) ->Libro{
        var autorsvalor = "No se encontro datos"
        var titulo :String = "No se encontro datos"
        var cover :String? = nil
        
        if (data.valueForKey("authors") != nil) {
            autorsvalor = ""
            let autorsx = data["authors"] as! NSArray as Array
            for var authory in autorsx{
                authory = authory as! NSDictionary
                let name = authory["name"] as! NSString as String
                autorsvalor = autorsvalor + name + " "
            }
        }
        
        if (data.valueForKey("title") != nil){
            titulo = data["title"] as! NSString as String
        }
        
        if (data.valueForKey("cover") != nil){
            let coverDict = data["cover"] as! NSDictionary
            cover = coverDict["small"] as! NSString as String
        } else {
            cover = ""
        }
        
        let libroObject = Libro(titulo: titulo, autors: autorsvalor, isbn: code)
        if cover != nil{
            libroObject.modificarCoverURL(cover!)
        }
        return libroObject
        
    }
    
    func insertNewObject(sender: AnyObject) {
        let alertaText = UIAlertController(title: "Busqueda ISBN", message: "Ingrese Codigo ISBN", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveAction = UIAlertAction(title: "Buscar", style: UIAlertActionStyle.Default, handler: {
            alert -> Void in
            let firstTextField = alertaText.textFields![0] as UITextField
            
            let code = firstTextField.text!
            
            if code != ""{
                
        
                //Verifica si el Libro ingresado se encuentra en la Base de Datos.
                let seccionEntidad = NSEntityDescription.entityForName("Seccion", inManagedObjectContext: self.contexto!)
                let peticion = seccionEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("petSeccionn", substitutionVariables: ["nombre": code])
                
                do {
                    let seccionEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
                    if (seccionEntidad2?.count > 0){
                        return
                    }
                }
                catch{
                    
                }
   
                
                if Reachability.isConnectedToNetwork(){
                    let bookObtained :Libro? = self.obtieneData(code)
                    if bookObtained != nil {
                     
                        bookObtained!.getDataImage()
                        self.libros.insert(bookObtained!, atIndex: 0)
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        //Guarda Nombre de isbn y titulo de Libro en Base de Datos
                        let nuevaSeccionEntidad = NSEntityDescription.insertNewObjectForEntityForName("Seccion", inManagedObjectContext: self.contexto!)
                        nuevaSeccionEntidad.setValue(code, forKey: "nombre")
                        nuevaSeccionEntidad.setValue(bookObtained!.titulo, forKey: "titulo")
                        
                        do {
                            
                            try self.contexto?.save()
                        }
                        catch{
                            
                        }
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("DetailBookController") as! DetailViewController
                        
                        controller.libro = self.libros[0]
                        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                        controller.navigationItem.leftItemsSupplementBackButton = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    else{
                        let alertaText = UIAlertController(title: "Sin Datos", message: "No se obtuvo Resultados", preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in //
                        })
                        alertaText.view.setNeedsLayout()
                        alertaText.addAction(okAction)
                        self.presentViewController(alertaText, animated: true, completion: nil)
                        
                    }
                }else{
                    let alertController = UIAlertController(title: "Sin Conexion a Internet", message: "No se obtuvo respuesta del servidor.", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in //
                    })
                    alertController.view.setNeedsLayout()
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }else{
                let alertController = UIAlertController(title: "Error", message: "Debes de ingresar un codigo ISBN.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                    print("OK button")
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertaText.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
             textField.placeholder = "Code ISBN"
        }
        
        alertaText.addAction(saveAction)
        alertaText.addAction(cancelAction)
        alertaText.view.setNeedsLayout()
        self.presentViewController(alertaText, animated: true, completion: nil)
        
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.libros[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.libro = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libros.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.libros[indexPath.row]
        // TODO render Title of Book
        cell.textLabel!.text = object.titulo
    }


    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}

