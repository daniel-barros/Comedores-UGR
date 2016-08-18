//
//  Colors.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/27/16.
/*
MIT License

Copyright (c) 2016 Daniel Barros

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//

import UIKit

extension UIColor {
    
    class func customRedColor() -> UIColor {
        return UIColor(red: 0.996, green: 0.230, blue: 0.187, alpha: 1)
    }
    
    class func customAlternateRedColor() -> UIColor {
        return UIColor(red: 0.996, green: 0.330, blue: 0.287, alpha: 1)
    }
    
    class func customDarkRedColor() -> UIColor {
        return UIColor(red: 0.418, green: 0.043, blue: 0.023, alpha: 1)
    }
    
    class func mainTextColor() -> UIColor {
        return .blackColor() //UIColor.darkGrayColor()
    }
}
