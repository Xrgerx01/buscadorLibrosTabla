//
//  VistaISBN.swift
//  buscadorLibrosTablas
//
//  Created by XrgerX on 10/09/16.
//  Copyright © 2016 XrgerX. All rights reserved.
//

import UIKit

class VistaISBN: UIViewController {

    @IBOutlet weak var isbn: UITextField!
    private var libros = [Libro]()
    
    @IBAction func buscarLibro(sender: UITextField) {
        procesoJson(sender.text!)
        sender.text = nil
        sender.resignFirstResponder()
    }
    
    func procesoJson(termino: String) {
        if Reachability.isConnectedToNetwork(){
            let bookObtained :Libro? = self.obtieneData(termino)
            if bookObtained != nil {
                
                bookObtained!.getDataImage()
                self.libros.insert(bookObtained!, atIndex: 0)
                //let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                //self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("DetailBookController") as! DetailViewController
                
                controller.libro = self.libros[0]
                self.navigationController?.pushViewController(controller, animated: true)
                //controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                //controller.navigationItem.leftItemsSupplementBackButton = true
            }
            else{
                let alertController = UIAlertController(title: "Sin Datos", message: "Sin Datos resultados", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }else{
            let alertController = UIAlertController(title: "Sin conexion a Internet", message: "No se pudo realizar la conexion a Internet", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                print("OK button")
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
    
    func buucarfd() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isbn.enabled = true
        isbn.selected.boolValue
        // Do any additional setup after loading the view.
    }

}
