
import Foundation

//禁止使用者輸入特殊字元
extension String {
    var containsValidCharacter: Bool {
        guard self != "" else { return true }
        let noNeedToRestrict = CharacterSet(charactersIn: " ") //可以打空白
        if noNeedToRestrict.containsUnicodeScalars(of: self.last!) {
            return true
        } else {
            return CharacterSet.alphanumerics.containsUnicodeScalars(of: self.last!)
        }
    }
}

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}
