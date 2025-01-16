/// A custom parameter attribute that constructs parsers from closures. The constructed parser
/// runs a number of parsers, one after the other, and accumulates their outputs.
///
/// The ``Parse`` parser acts as an entry point into `@ParserBuilder` syntax, where you can list
/// all of the parsers you want to run. For example, to parse two comma-separated integers:
///
/// ```swift
/// try Parse {
///   Int.parser()
///   ","
///   Int.parser()
/// }
/// .parse("123,456") // (123, 456)
/// ```
@resultBuilder
public enum ParserBuilder<Input> {
  @inlinable
  public static func buildBlock() -> Always<Input, Void> {
    Always(())
  }
  
  @inlinable
  public static func buildBlock<P: Parser>(_ parser: P) -> P where P.Input == Input {
    parser
  }
  
  /// Provides support for `if`-`else` statements in ``ParserBuilder`` blocks, producing a
  /// conditional parser for the `if` branch.
  ///
  /// ```swift
  /// Parse {
  ///   "Hello"
  ///   if shouldParseComma {
  ///     ", "
  ///   } else {
  ///     " "
  ///   }
  ///   Rest()
  /// }
  /// ```
  @inlinable
  public static func buildEither<TrueParser, FalseParser>(
    first parser: TrueParser
  ) -> Parsers.Conditional<TrueParser, FalseParser>
  where TrueParser.Input == Input, FalseParser.Input == Input {
    .first(parser)
  }
  
  /// Provides support for `if`-`else` statements in ``ParserBuilder`` blocks, producing a
  /// conditional parser for the `else` branch.
  ///
  /// ```swift
  /// Parse {
  ///   "Hello"
  ///   if shouldParseComma {
  ///     ", "
  ///   } else {
  ///     " "
  ///   }
  ///   Rest()
  /// }
  /// ```
  @inlinable
  public static func buildEither<TrueParser, FalseParser>(
    second parser: FalseParser
  ) -> Parsers.Conditional<TrueParser, FalseParser>
  where TrueParser.Input == Input, FalseParser.Input == Input {
    .second(parser)
  }
  
  @inlinable
  public static func buildExpression<P: Parser>(_ parser: P) -> P where P.Input == Input {
    parser
  }
  
  /// Provides support for `if` statements in ``ParserBuilder`` blocks, producing an optional
  /// parser.
  @inlinable
  public static func buildIf<P: Parser>(_ parser: P?) -> P? where P.Input == Input {
    parser
  }
  
  /// Provides support for `if` statements in ``ParserBuilder`` blocks, producing a void parser for
  /// a given void parser.
  ///
  /// ```swift
  /// Parse {
  ///   "Hello"
  ///   if shouldParseComma {
  ///     ","
  ///   }
  ///   " "
  ///   Rest()
  /// }
  /// ```
  @inlinable
  public static func buildIf<P>(_ parser: P?) -> Parsers.OptionalVoid<P>
  where P.Input == Input {
    .init(wrapped: parser)
  }
  
  /// Provides support for `if #available` statements in ``ParserBuilder`` blocks, producing an
  /// optional parser.
  @inlinable
  public static func buildLimitedAvailability<P: Parser>(_ parser: P?) -> P?
  where P.Input == Input {
    parser
  }
  
  /// Provides support for `if #available` statements in ``ParserBuilder`` blocks, producing a void
  /// parser for a given void parser.
  @inlinable
  public static func buildLimitedAvailability<P>(_ parser: P?) -> Parsers.OptionalVoid<P>
  where P.Input == Input {
    .init(wrapped: parser)
  }
  
  @inlinable
  public static func buildPartialBlock<P: Parser>(first: P) -> P
  where P.Input == Input {
    first
  }
  
  @_disfavoredOverload
  @inlinable
  public static func buildPartialBlock<P0, P1>(accumulated: P0, next: P1) -> SkipFirst<P0, P1>
  where P0.Input == Input, P1.Input == Input {
    .init(accumulated, next)
  }
  
  @inlinable
  public static func buildPartialBlock<P0, P1>(accumulated: P0, next: P1) -> SkipSecond<P0, P1>
  where P0.Input == Input, P1.Input == Input {
    .init(accumulated, next)
  }
  
  public struct SkipFirst<P0: Parser, P1: Parser>: Parser
  where P0.Input == P1.Input, P0.Output == Void {
    @usableFromInline let p0: P0, p1: P1
    
    @usableFromInline init(_ p0: P0, _ p1: P1) {
      self.p0 = p0
      self.p1 = p1
    }
    
    @inlinable public func parse(_ input: inout P0.Input) rethrows -> P1.Output {
      do {
        try self.p0.parse(&input)
        return try self.p1.parse(&input)
      } catch { throw ParsingError.wrap(error, at: input) }
    }
  }
  
  public struct SkipSecond<P0: Parser, P1: Parser>: Parser
  where P0.Input == P1.Input, P1.Output == Void {
    @usableFromInline let p0: P0, p1: P1
    
    @usableFromInline init(_ p0: P0, _ p1: P1) {
      self.p0 = p0
      self.p1 = p1
    }
    
    @inlinable public func parse(_ input: inout P0.Input) rethrows -> P0.Output {
      do {
        let o0 = try self.p0.parse(&input)
        try self.p1.parse(&input)
        return o0
      } catch { throw ParsingError.wrap(error, at: input) }
    }
  }
  
  public struct Take2<P0: Parser, P1: Parser>: Parser
  where
  P0.Input == P1.Input
  {
    @usableFromInline let p0: P0, p1: P1
    
    @usableFromInline init(_ p0: P0, _ p1: P1) {
      self.p0 = p0
      self.p1 = p1
    }
    
    @inlinable public func parse(_ input: inout P0.Input) rethrows -> (P0.Output, P1.Output) {
      do {
        return try (
          self.p0.parse(&input),
          self.p1.parse(&input)
        )
      } catch { throw ParsingError.wrap(error, at: input) }
    }
  }
}

extension ParserBuilder.SkipFirst: ParserPrinter where P0: ParserPrinter, P1: ParserPrinter {
  @inlinable
  public func print(_ output: P1.Output, into input: inout P0.Input) rethrows {
    try self.p1.print(output, into: &input)
    try self.p0.print(into: &input)
  }
}

extension ParserBuilder.SkipSecond: ParserPrinter where P0: ParserPrinter, P1: ParserPrinter {
  @inlinable
  public func print(_ output: P0.Output, into input: inout P0.Input) rethrows {
    try self.p1.print(into: &input)
    try self.p0.print(output, into: &input)
  }
}

extension ParserBuilder.Take2: ParserPrinter where P0: ParserPrinter, P1: ParserPrinter {
  @inlinable
  public func print(_ output: (P0.Output, P1.Output), into input: inout P0.Input) rethrows {
    try self.p1.print(output.1, into: &input)
    try self.p0.print(output.0, into: &input)
  }
}

extension ParserBuilder where Input == Substring {
  @_disfavoredOverload
  public static func buildExpression<P: Parser>(_ expression: P)
  -> From<Conversions.SubstringToUTF8View, Substring.UTF8View, P>
  where P.Input == Substring.UTF8View {
    From(.utf8) {
      expression
    }
  }
}

extension ParserBuilder where Input == Substring.UTF8View {
  @_disfavoredOverload
  public static func buildExpression<P: Parser>(_ expression: P) -> P
  where P.Input == Substring.UTF8View {
    expression
  }
}

extension ParserBuilder {
  public struct TupleParser<P0: Parser, P1: Parser, each Elements>: Parser
  where P0.Input == P1.Input, P0.Output == (repeat each Elements) {
    @usableFromInline let p0: P0
    @usableFromInline let p1: P1
    
    @usableFromInline init(_ p0: P0, _ p1: P1) {
      self.p0 = p0
      self.p1 = p1
    }
    
    @inlinable public func parse(_ input: inout P0.Input) rethrows -> (repeat each Elements, P1.Output) {
      do {
        let first = try self.p0.parse(&input)
        let second = try self.p1.parse(&input)
        return (repeat each first, second)
      } catch {
        throw ParsingError.wrap(error, at: input)
      }
    }
  }
  
  @_disfavoredOverload
  public static func buildPartialBlock<P0: Parser, P1: Parser, each Elements>(
    accumulated: P0,
    next: P1
  ) -> TupleParser<P0, P1, repeat each Elements>
  where P0.Input == P1.Input, P0.Output == (repeat each Elements) {
    TupleParser(accumulated, next)
  }
}

extension ParserBuilder.TupleParser: ParserPrinter
where P0: ParserPrinter, P1: ParserPrinter {
  @inlinable public func print(_ output: (repeat each Elements, P1.Output), into input: inout P0.Input) throws {
    //    The following doesn't compile with error: 'Value pack expansion can only appear inside a function argument list, tuple element, or as the expression of a for-in loop'
    //    try p1.print(output.1, into: &input)
    //    try p0.print((repeat each output.0), into: &input)
  }
}
