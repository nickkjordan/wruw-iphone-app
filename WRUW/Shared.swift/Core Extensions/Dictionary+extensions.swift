func +<Key, Value>(lhs: [Key: Value], rhs: [Key: Value])
    -> [Key: Value] {
    var base = lhs
    rhs.forEach { base.updateValue($1, forKey: $0) }
    return base
}
