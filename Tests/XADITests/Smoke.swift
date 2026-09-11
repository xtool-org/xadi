import Testing
import XADI
import Foundation

@Test func smoke() {
    // we just want to make sure that it compiles
    if Date().timeIntervalSince1970 == 1 {
        xadi_Load(nil)
    }
}
