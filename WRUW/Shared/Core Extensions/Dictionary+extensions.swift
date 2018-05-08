func +<Key, Value>(lhs: Dictionary<Key, Value>, rhs: Dictionary<Key, Value>)
    -> Dictionary<Key, Value> {
    var base = lhs
    rhs.forEach { base.updateValue($1, forKey: $0) }
    return base
}
