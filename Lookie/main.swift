//
//  main.swift
//  StringFileGenerator
//
//  Created by Emre Onder on 11.11.2020.
//

import Foundation

var outputDirectory = ""
let domainsToFind = ["domain1", "domain2"]
main()

func main() {
    guard CommandLine.argc >= 3 else { return }
    let langFilePath = CommandLine.arguments[1]
    outputDirectory = CommandLine.arguments[2]
    print("Language File Generation Started")
    print("Lang File Path: \(langFilePath)")
    print("Output Directory: \(outputDirectory)")
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: langFilePath), options: .mappedIfSafe)
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        if let jsonResult = jsonResult as? Dictionary<String, String> {
            writeSwiftFile(keysAndValues: jsonResult)
        } else {
            print("Wrong JSON Format")
        }
    } catch {
        print("Can't find the language file")
    }
}

private func writeSwiftFile(keysAndValues: Dictionary<String, String>) {

    var domainValues = Dictionary<String, Dictionary<String,String>>()

    keysAndValues.forEach { (key, value) in
        let domainCandidate = domainsToFind.first(where: { key.starts(with: $0 )}) ?? ""
        
        var domainValue = domainValues[domainCandidate]
        if domainValue == nil {
            var temp = Dictionary<String,String>()
            temp[key] = value
            domainValue = temp
        } else {
            domainValue![key] = value
        }
        domainValues[domainCandidate] = domainValue
    }
    
    domainValues.forEach { (domain, valuePairs) in
        let processedDomain = domain.capitalized
        writeDomainToSwiftFile(domain: processedDomain, keysAndValues: valuePairs)
    }

}

private func writeDomainToSwiftFile(domain: String, keysAndValues: Dictionary<String, String>) {
    var output: String = ""
    let newLine = "\n"
    let tab = "    "
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "dd.MM.yy"
    let dateString = dateFormatterGet.string(from: Date())
    
    let sortedDatas = keysAndValues.sorted { $0.0 < $1.0 }
    let userName = NSFullUserName()
    
    output.append("//\(newLine)")
    output.append("// \(domain)StringResources.swift\(newLine)")
    output.append("//\(newLine)")
    output.append("//  Updated by \(userName) on \(dateString).\(newLine)")
    output.append("//  Copyright © 2020 \(userName). All rights reserved.\(newLine)")
    output.append("//\(newLine)")
    
    output.append("public class \(domain)StringResources {\(newLine)")
    output.append(newLine)
    
    sortedDatas.forEach { (key, value) in
        let valueHasParameters = value.contains("{0}")
        if (valueHasParameters) {
            var parameterCount = 1
            if (value.contains("{1}")) { parameterCount = 2 }
            if (value.contains("{2}")) { parameterCount = 3 }
            if (value.contains("{3}")) { parameterCount = 4 }
            if (value.contains("{4}")) { parameterCount = 5 }
            if (value.contains("{5}")) { parameterCount = 6 }

            // comment
            output.append("\(tab)//tr: \(value.filter({ !newLine.contains($0) }))\(newLine)")

            // function signature
            output.append("\(tab)public static func \(key)(")
            for i in 1...parameterCount {
                output.append("_ param\(i): String?")
                if (i != parameterCount) {
                    output.append(", ")
                }
            }
            output.append(") -> String {\(newLine)")

            // function body
            output.append("\(tab)\(tab)var valueCandidate = LanguageManager.sharedInstance.values[\"\(key)\"] ?? \"\"\(newLine)")
            for i in 1...parameterCount {
                output.append("\(tab)\(tab)valueCandidate = valueCandidate.replacingOccurrences(of: \"{\(i-1)}\", with: param\(i) ?? \"\")\(newLine)")
            }
            output.append("\(tab)\(tab)return valueCandidate\(newLine)")
            output.append("\(tab)}\(newLine)")
            output.append(newLine)
        } else {
            output.append("    // tr: \(value.filter({ !newLine.contains($0) })) \(newLine)")
            output.append("    public static var \(key): String { return LanguageManager.sharedInstance.values[\"\(key)\"] ?? \"\" }\(newLine)")
            output.append(newLine)
        }
    }
    output.append("}\(newLine)\(newLine)")

    let filename =  outputDirectory + "\(domain)StringResources.swift"
    let url = URL(fileURLWithPath: filename)
    do {
        try output.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        print("Language File Generation Finished Without Any Error")
    } catch {
        print("Writing File Error")
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
    }
}
