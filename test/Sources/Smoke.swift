import Testing
import XADI
import Foundation

private let projectDir = URL(filePath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()

private func libDir() throws -> URL {
    #if arch(x86_64)
    let arch = "x86_64"
    #elseif arch(arm64)
    let arch = "arm64-v8a"
    #else
    #error("Unsupported architecture")
    #endif
    let url = projectDir.appending(components: "tmp", "adi-lib", arch)
    try #require(FileManager.default.fileExists(atPath: url.path), "Run `make libs` first")
    return url
}

@Test func smoke() throws {
    let tempDir = projectDir.appending(components: "tmp", "tests")
    try? FileManager.default.removeItem(at: tempDir)
    defer { try? FileManager.default.removeItem(at: tempDir) }
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    let libDir = try libDir()
    xadi_Load(libDir.path)

    let id = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16).lowercased()
    #expect(xadi_SetAndroidID(id, UInt32(id.utf8.count)) == 0)

    #expect(xadi_SetProvisioningPath(tempDir.path) == 0)
    #expect(xadi_GetLoginCode(1) == -45061)
}
