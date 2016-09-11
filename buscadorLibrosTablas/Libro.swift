//
//  Libro.swift
//  buscadorLibrosTablas
//
//  Created by XrgerX on 10/09/16.
//  Copyright © 2016 XrgerX. All rights reserved.
//


import UIKit
import Foundation

class Libro {
    var titulo :String? = nil
    var autors :String? = nil
    var coverUrl :String? = nil
    var codeISBN :String? = nil
    var coverImage : UIImage? = nil
    
    init(titulo: String, autors :String, isbn: String){
        self.titulo = titulo
        self.autors = autors
        self.codeISBN = isbn
    }
    
    func modificarCoverURL(url: String){
        self.coverUrl = url
    }
    
    func getDataImage(){
        if coverUrl != nil {
            let url = NSURL(string: coverUrl!)
            if let dataImage = NSData(contentsOfURL: url!) {
                coverImage = UIImage(data: dataImage)
            }
        }else{
            getCoverTry()
        }
    }
    
    func getCoverTry(){
        var isbnFormat :String = ""
        for element in self.codeISBN!.characters.split("-").map(String.init){
            isbnFormat = isbnFormat + element
        }
        let coverUrlOption :String = "http://covers.openlibrary.org/b/isbn/" + isbnFormat + "-L.jpg"
        let url = NSURL(string: coverUrlOption)
        if let dataImage = NSData(contentsOfURL: url!) {
            coverImage = UIImage(data: dataImage)
        }
    }
    
}

