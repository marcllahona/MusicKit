//  Copyright (c) 2015 Ben Guo. All rights reserved.

import Foundation

// MARK: == PitchSet ==
/// A collection of unique `Pitch` instances ordered by frequency.
public struct PitchSet : Equatable {

    var contents : [Pitch] = []

    /// The number of pitches the `PitchSet` contains.
    public var count: Int {
        return contents.count
    }

    /// Creates an empty `PitchSet`
    public init() { }

    /// Creates a new `PitchSet` with the contents of a given sequence of pitches.
    public init<S : SequenceType where S.Generator.Element == Pitch>(_ sequence: S) {
        contents = sorted(Array(Set(sequence)))
    }

    /// Creates a new `PitchSet` with the given pitches.
    public init(pitches: Pitch...) {
        contents = sorted(Array(Set(pitches)))
    }

    /// Returns the index of the given `pitch`
    ///
    /// :returns: The index of the first instance of `pitch`, or `nil` if `pitch` isn't found.
    public func indexOf(pitch: Pitch) -> Int? {
        let index = MKUtil.insertionIndex(contents, pitch)
        if index == count {
            return nil
        }
        return contents[index] == pitch ? index : nil
    }

    /// Returns true iff `pitch` is found in the collection.
    public func contains(pitch: Pitch) -> Bool {
        return indexOf(pitch) != nil
    }

    /// Returns a new `PitchSet` with the combined contents of `self` and the given pitches.
    public func merge(pitches: Pitch...) -> PitchSet {
        return merge(pitches)
    }

    /// Returns a new `PitchSet` with the combined contents of `self` and the given sequence of pitches.
    public func merge<S: SequenceType where S.Generator.Element == Pitch>(pitches: S) -> PitchSet {
        return PitchSet(contents + pitches)
    }

    /// Inserts one or more new pitches into the `PitchSet` in the correct order.
    public mutating func insert(pitches: Pitch...) {
        for pitch in pitches {
            if !contains(pitch) {
                contents.insert(pitch, atIndex: MKUtil.insertionIndex(contents, pitch))
            }
        }
    }

    /// Inserts the contents of a sequence of pitches into the `PitchSet`.
    public mutating func insert<S: SequenceType where S.Generator.Element == Pitch>(pitches: S) {
        contents = sorted(Array(Set(contents + pitches)))
    }

    /// Removes `pitch` from the `PitchSet` if it exists.
    ///
    /// :returns: The given pitch if found, otherwise `nil`.
    public mutating func remove(pitch: Pitch) -> Pitch? {
        if let index = indexOf(pitch) {
            return contents.removeAtIndex(index)
        }
        return nil
    }

    /// Removes and returns the pitch at `index`. Requires count > 0.
    public mutating func removeAtIndex(index: Int) -> Pitch {
        return contents.removeAtIndex(index)
    }

    /// Removes all pitches from the `PitchSet`.
    public mutating func removeAll(keepCapacity: Bool = true) {
        contents.removeAll(keepCapacity: keepCapacity)
    }
}

// MARK: Printable
extension PitchSet : Printable {
    public var description : String {
        return contents.description
    }
}

// MARK: SequenceType
extension PitchSet : SequenceType {
    /// Returns a generator of the elements of the collection.
    public func generate() -> GeneratorOf<Pitch> {
        return GeneratorOf(contents.generate())
    }
}

// MARK: CollectionType
extension PitchSet : CollectionType {
    /// The position of the first pitch in the set. (Always zero.)
    public var startIndex: Int {
        return 0
    }

    /// One greater than the position of the last pitch in the set.
    /// Zero when the collection is empty.
    public var endIndex: Int {
        return count
    }

    /// Accesses the pitch at index `i`.
    /// Read-only to ensure sorting - use `insert` to add new pitches.
    public subscript(i: Int) -> Pitch {
        return contents[i]
    }
}

// MARK: ArrayLiteralConvertible
extension PitchSet : ArrayLiteralConvertible {
    public init(arrayLiteral elements: Pitch...) {
        self.contents = sorted(Array(Set(elements)))
    }
}

// MARK: Sliceable
extension PitchSet : Sliceable {
    /// Access the elements in the given range.
    public subscript(range: Range<Int>) -> PitchSetSlice {
        return PitchSetSlice(contents[range])
    }
}

// MARK: Equatable
public func ==(lhs: PitchSet, rhs: PitchSet) -> Bool {
    if count(lhs) != count(rhs) {
        return false
    }
    for (lhs, rhs) in zip(lhs, rhs) {
        if lhs != rhs {
            return false
        }
    }
    return true
}

// MARK: Operators
public func +(lhs: PitchSet, rhs: PitchSet) -> PitchSet {
    var lhs = lhs
    lhs.insert(rhs)
    return lhs
}

public func +=(inout lhs: PitchSet, rhs: PitchSet) {
    lhs.insert(rhs)
}

public func -(lhs: PitchSet, rhs: PitchSet) -> PitchSet {
    var lhs = lhs
    for pitch in rhs {
        lhs.remove(pitch)
    }
    return lhs
}

public func -=(inout lhs: PitchSet, rhs: PitchSet) {
    for pitch in rhs {
        lhs.remove(pitch)
    }
}

// MARK: == PitchSetSlice ==
/// A slice of a `PitchSet`.
public struct PitchSetSlice : Printable {
    private var contents: ArraySlice<Pitch> = []

    /// The number of elements the `PitchSetSlice` contains.
    public var count: Int {
        return contents.count
    }

    /// Creates an empty `PitchSetSlice`.
    public init() { }

    /// Creates a new `PitchSetSlice` with the contents of a given sequence.
    public init<S : SequenceType where S.Generator.Element == Pitch>(_ sequence: S) {
        contents = ArraySlice(sorted(Array(Set(sequence))))
    }

    /// Creates a new `PitchSetSlice` with the given values.
    public init(values: Pitch...) {
        contents = ArraySlice(sorted(Array(Set(values))))
    }

    /// Creates a new `PitchSetSlice` from a sorted slice.
    private init(sortedSlice: ArraySlice<Pitch>) {
        contents = sortedSlice
    }

    /// Returns the index of the given `pitch`
    ///
    /// :returns: The index of the first instance of `pitch`, or `nil` if `pitch` isn't found.
    public func indexOf(pitch: Pitch) -> Int? {
        let index = MKUtil.insertionIndex(contents, pitch)
        if index == count {
            return nil
        }
        return contents[index] == pitch ? index : nil
    }

    /// Returns true iff `pitch` is found in the slice.
    public func contains(pitch: Pitch) -> Bool {
        return indexOf(pitch) != nil
    }

    /// Returns a new `PitchSetSlice` with the combined contents of `self` and the given pitches.
    public func merge(pitches: Pitch...) -> PitchSetSlice {
        return merge(pitches)
    }

    /// Returns a new `PitchSetSlice` with the combined contents of `self` and the given pitches.
    public func merge<S: SequenceType where S.Generator.Element == Pitch>(pitches: S) -> PitchSetSlice {
        return PitchSetSlice(contents + pitches)
    }

    /// Inserts one or more new pitches into the slice in the correct order.
    public mutating func insert(pitches: Pitch...) {
        for pitch in pitches {
            if !contains(pitch) {
                contents.insert(pitch, atIndex: MKUtil.insertionIndex(contents, pitch))
            }
        }
    }

    /// Inserts the contents of a sequence into the `PitchSetSlice`.
    public mutating func insert<S: SequenceType where S.Generator.Element == Pitch>(pitches: S) {
        contents = ArraySlice(sorted(Array(Set(contents + pitches))))
    }

    /// Removes `pitch` from the slice if it exists.
    ///
    /// :returns: The given value if found, otherwise `nil`.
    public mutating func remove(pitch: Pitch) -> Pitch? {
        if let index = indexOf(pitch) {
            return contents.removeAtIndex(index)
        }
        return nil
    }

    /// Removes and returns the pitch at `index`. Requires count > 0.
    public mutating func removeAtIndex(index: Int) -> Pitch {
        return contents.removeAtIndex(index)
    }

    /// Removes all pitches from the slice.
    public mutating func removeAll(keepCapacity: Bool = true) {
        contents.removeAll(keepCapacity: keepCapacity)
    }
}

// MARK: Printable
extension PitchSetSlice : Printable {
    public var description: String {
        return contents.description
    }
}

// MARK: SequenceType
extension PitchSetSlice : SequenceType {
    public func generate() -> GeneratorOf<Pitch> {
        return GeneratorOf(contents.generate())
    }
}

// MARK: CollectionType
extension PitchSetSlice : CollectionType {
    typealias Index = Int

    /// The position of the first pitch in the slice. (Always zero.)
    public var startIndex: Int {
        return 0
    }

    /// One greater than the position of the last element in the slice. Zero when the slice is empty.
    public var endIndex: Int {
        return count
    }

    /// Accesses the pitch at index `i`.
    ///
    /// Read-only to ensure sorting - use `insert` to add new pitches.
    public subscript(i: Int) -> Pitch {
        return contents[i]
    }
}

// MARK: ArrayLiteralConvertible
extension PitchSetSlice : ArrayLiteralConvertible {
    public init(arrayLiteral elements: Pitch...) {
        self.contents = ArraySlice(sorted(Array(Set(elements))))
    }
}

// MARK: Sliceable
extension PitchSetSlice : Sliceable {
    /// Access the elements in the given range.
    public subscript(range: Range<Int>) -> PitchSetSlice {
        return PitchSetSlice(contents[range])
    }
}
