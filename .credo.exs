%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: [~r"/node_modules/", ~r"/_build/", ~r"/deps/"]
      },
      strict: true,
      color: true,
      checks: [
        # Consistency

        {Credo.Check.Consistency.MultiAliasImportRequireUse, false},

        # Design

        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Design.DuplicatedCode, exit_status: 0},
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Design.TagFIXME, exit_status: 2},

        # Readability

        {Credo.Check.Readability.FunctionNames},
        {Credo.Check.Readability.LargeNumbers},
        # MaxLineLength is already enforced by formatter
        # credo throws warnings for commented lines, which is just annoying
        {Credo.Check.Readability.MaxLineLength, false},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.ModuleNames},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs},
        {Credo.Check.Readability.ParenthesesInCondition},
        {Credo.Check.Readability.PredicateFunctionNames},
        {Credo.Check.Readability.PreferImplicitTry},
        {Credo.Check.Readability.RedundantBlankLines},
        {Credo.Check.Readability.StringSigils},
        {Credo.Check.Readability.TrailingBlankLine},
        {Credo.Check.Readability.TrailingWhiteSpace},
        {Credo.Check.Readability.VariableNames},
        {Credo.Check.Readability.Semicolons},
        {Credo.Check.Readability.SpaceAfterCommas},

        # Refactor

        {Credo.Check.Refactor.ABCSize, exit_status: 0},
        {Credo.Check.Refactor.AppendSingleItem},
        {Credo.Check.Refactor.DoubleBooleanNegation},
        {Credo.Check.Refactor.CondStatements, false},
        {Credo.Check.Refactor.CyclomaticComplexity},
        # This should be a product of our common sense and detailed in reviews
        {Credo.Check.Refactor.FunctionArity, false},
        {Credo.Check.Refactor.LongQuoteBlocks},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting},
        {Credo.Check.Refactor.PipeChainStart, false},
        {Credo.Check.Refactor.UnlessWithElse},
        {Credo.Check.Refactor.VariableRebinding},

        # Warning

        {Credo.Check.Warning.BoolOperationOnSameValues},
        {Credo.Check.Warning.ExpensiveEmptyEnumCheck},
        {Credo.Check.Warning.IExPry},
        {Credo.Check.Warning.IoInspect},
        {Credo.Check.Warning.LazyLogging, false},
        {Credo.Check.Warning.OperationOnSameValues},
        {Credo.Check.Warning.OperationWithConstantResult},
        {Credo.Check.Warning.UnusedEnumOperation},
        {Credo.Check.Warning.UnusedFileOperation},
        {Credo.Check.Warning.UnusedKeywordOperation},
        {Credo.Check.Warning.UnusedListOperation},
        {Credo.Check.Warning.UnusedPathOperation},
        {Credo.Check.Warning.UnusedRegexOperation},
        {Credo.Check.Warning.UnusedStringOperation},
        {Credo.Check.Warning.UnusedTupleOperation},
        {Credo.Check.Warning.RaiseInsideRescue},
        {Credo.Check.Warning.MapGetUnsafePass}
      ]
    }
  ]
}
