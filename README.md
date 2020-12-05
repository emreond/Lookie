# Bookie
Swift script that scan your localization file and generate domain base localization files

[![Swift Version][swift-image]][swift-url]

# Bookie

**Localization code generator** written for Swift in Swift.

## What It does:

It helps you to use your localization file in a much easier, safer and scalable way. 


## How Does It Work:

It generate off the hook classes/codes from your language file everytime you build the project. It allows you to separate your keys into domains. 

**How To Use It**

**Step 1**

Open Lookie.xcodeproj and add necessary domains to `domainsToFind` array depenging on your localization file.

For example; `dashboard_my_title` generates `DashboardStringResources.swift` file. Every key you add starting with `dashboard` will be written inside `DashboardStringResources.swift` file. If you can't find any related domain it will be written in `StringResources.swift`

**Step 2**

Get product file called Laurine and paste it to your project folder

**Step 3**

Add below build phase above Compile Sources step. 

```
echo "STRING GENERATION BUILD PHASE STARTED"
 BASE_PATH="${PROJECT_DIR}/LookieExample"
 OUTPUT_PATH="$BASE_PATH/Resources/"
 SOURCE_PATH="${BASE_PATH}/lang_en.json"
 PROGRAM_PATH="${BASE_PATH}/Lookie"
 chmod 755 ${PROGRAM_PATH}

# Run string generation program if language file is newer then Resources folder files.
 if [ "$OUTPUT_PATH" -ot "$SOURCE_PATH" ]; then
    $PROGRAM_PATH $SOURCE_PATH $OUTPUT_PATH
 fi
echo "STRING GENERATION BUILD PHASE FINISHED"
```

**Step 4**

Add example `LanguageManager.swift` file to your project.

**Step 5**

Use it like `StringResources.myKey`

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
