@main
struct TestRunner {
    static func main() {
        DisplayOptionsPropertyTests.runAll()
        print("")
        DisplayOptionsTests.runAll()
        print("")
        TimeFormatterPropertyTests.runAll()
        print("")
        TimeFormatterTests.runAll()
        print("")
        StyleOptionsPropertyTests.runAll()
        print("")
        StyleOptionsTests.runAll()
        print("")
        StyledTextBuilderPropertyTests.runAll()
        print("")
        StyledTextBuilderTests.runAll()
        print("")
        SettingsViewModelTests.runAll()
        print("")
        MenuPropertyTests.runAll()
        print("")
        MenuTests.runAll()
    }
}
