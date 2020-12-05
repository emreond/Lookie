//
// StringResources.swift
//
//  Updated by Emre Onder on 05.12.20.
//  Copyright © 2020 Emre Onder. All rights reserved.
//
public class StringResources {

    // tr: hello 
    public static var hello: String { return LanguageManager.sharedInstance.values["hello"] ?? "" }

    // tr: Lookie 
    public static var some_other_key: String { return LanguageManager.sharedInstance.values["some_other_key"] ?? "" }

}

