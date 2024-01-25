import Foundation

extension Array {
    /// Usage:
    /// let array = [1, 2, 3, 4]
    /// array[safeIndex: 6] => nil
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
