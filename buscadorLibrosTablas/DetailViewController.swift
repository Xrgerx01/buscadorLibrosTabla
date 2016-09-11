//
//  DetailViewController.swift
//  buscadorLibrosTablas
//
//  Created by XrgerX on 10/09/16.
//  Copyright © 2016 XrgerX. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var libro :Libro?
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autors: UITextView!
    @IBOutlet weak var portada: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        titulo.text = libro!.titulo
        autors.text = libro!.autors!
        
        if libro!.coverImage != nil {
            portada.image = libro!.coverImage
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Detalle del Libro"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

