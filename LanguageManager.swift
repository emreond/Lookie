//
//  LanguageManager.swift
//
//  Created by Emre Önder on 05.12.2020.
//  Copyright © 2020 Emre Önder. All rights reserved.
//

import Foundation

public class LanguageManager {
    
    public static let sharedInstance = LanguageManager()
    private static let LanguageCodeUserDefaultsKey = "LanguageManager_selectedLanguage"
    
    public class Language {
        
        public var code: String?
        public var name: String?
        
        public static var english: Language {
            let language = Language()
            language.code = "eng"
            language.name = "English"
            return language
        }
    }
    
    private init() {
        if let selectedLanguageFromUserDefaults = readSelectedLanguageFromUserDefaults() {
            selectedLanguage = selectedLanguageFromUserDefaults
            return
        }
        
        // find language from prefferred languages
        let prefferedLanguageCodes = findPrefferedLanguageCodes()
        outerLoop : for supportedLanguage in supportedLanguages {
            for prefferedLanguageCode in prefferedLanguageCodes {
                if supportedLanguage.code == prefferedLanguageCode {
                    selectedLanguage = supportedLanguage
                    break outerLoop
                }
            }
        }
        
        // if none of the above works. selected language will stay tr.
        
        populateLangFromCache(for: selectedLanguage)
    }
    
    public var supportedLanguages: [Language] = [Language.english]
    
    public var selectedLanguage: Language = Language.english {
        didSet {
            writeSelectedLanguageToUserDefaults(selectedLanguage)
        }
    }
    
    var values: [String: String] = [:]
    
    private func writeSelectedLanguageToUserDefaults(_ language: Language) {
        UserDefaults.standard.set(language.code, forKey: LanguageManager.LanguageCodeUserDefaultsKey)
    }
    
    private func readSelectedLanguageFromUserDefaults() -> Language? {
        if let langCode = UserDefaults.standard.string(forKey: LanguageManager.LanguageCodeUserDefaultsKey),
            let language = supportedLanguages.first(where: { $0.code == langCode }) {
            return language
        }
        return nil
    }
    
    private func findPrefferedLanguageCodes() -> [String] {
        return Locale.preferredLanguages
            .compactMap({ $0.split(separator: "-").first })
            .map({ String($0) })
    }
    
    private func populateLangFromCache(for lang: Language) {
        let selectedLangPrefix = lang.code ?? ""
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: "lang_\(selectedLangPrefix.lowercased())", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: String] {
                    values = jsonResult
                }
            } catch {
                debugPrint("Can't read language file from cache")
            }
        }
    }
    
}
