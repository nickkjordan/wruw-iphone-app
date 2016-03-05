extension SequenceType {
    func first(
        predicate: (Self.Generator.Element) -> Bool
    ) -> Self.Generator.Element? {
        for element in self {
            if predicate(element) {
                return element
            }
        }

        return nil
    }
}
