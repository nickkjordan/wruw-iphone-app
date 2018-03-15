extension Sequence {
    func first(
        _ predicate: (Self.Iterator.Element) -> Bool
    ) -> Self.Iterator.Element? {
        for element in self {
            if predicate(element) {
                return element
            }
        }

        return nil
    }
}
