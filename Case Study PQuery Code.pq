(CleanData as table) =>
let
    Source = CleanData,
    DelHeadRows = Table.SelectRows(Source, each not (
        (Text.Contains([Column1], "Pahokee")) or 
        (Text.Contains([Column1], "E main")) or
        (Text.Contains([Column1], "Phone")) or
        (Text.Contains([Column1], "E-mail")) or
        (Text.Contains([Column1], "Fax")) or 
        (Text.Contains([Column1], "E Main")) or
        (Text.Contains([Column1], "Up to date"))
    )),
    PromotedHeaders = Table.PromoteHeaders(DelHeadRows, [PromoteAllScalars=true]),
    RemoveEmptyCol= Table.RemoveColumns(PromotedHeaders,{"Column4"}),
    AddCondiCol = Table.AddColumn(RemoveEmptyCol, "Product Name", each if [Price] = null then [Size] else null),
    FillCol = Table.FillDown(AddCondiCol,{"Product Name"}),
    RemoveEmptyDescCol = Table.SelectRows(FillCol, each [Description] <> null and [Description] <> ""),
    ReorderCol = Table.ReorderColumns(RemoveEmptyDescCol,{"Product Name", "Size", "Description", "Price"}),
    RemoveParamSizeCol = Table.SelectRows(ReorderCol, each not Text.Contains([Size], "Size")),
    SplitDelimiter = Table.SplitColumn(RemoveParamSizeCol, "Description", Splitter.SplitTextByDelimiter(",", QuoteStyle.Csv), {"Description.1", "Description.2", "Description.3"}),
    TransformCol = Table.TransformColumnTypes(SplitDelimiter,{{"Description.1", type text}, {"Description.2", type text}, {"Description.3", type text}}),
    RenameCol = Table.RenameColumns(TransformCol,{{"Description.1", "Detail 1"},{"Description.2", "Detail 2"},{"Description.3", "Detail 3"}}),
    ChangeParamUnit = Table.TransformColumns(RenameCol, {{"Detail 1", each if Text.EndsWith(_,"ft HT") then Text.Combine({Text.Start(_, Text.Length(_)-5), "' Height"},"")
        else if Text.EndsWith(_,"ft GW") then Text.Combine({Text.Start(_, Text.Length(_)-5), "' Width"},"")
        else _
    },
    {"Detail 2", each if Text.EndsWith(_,"ft HT") then Text.Combine({Text.Start(_, Text.Length(_)-5), "' Height"},"")
        else if Text.EndsWith(_,"ft GW") then Text.Combine({Text.Start(_, Text.Length(_)-5), "' Width"},"")
        else _
    },
    {"Detail 3", each if Text.EndsWith(_,"ft HT") then Text.Combine({Text.Start(_, Text.Length(_)-5), "' Height"},"")
        else if Text.EndsWith(_,"ft GW") then Text.Combine({Text.Start(_, Text.Length(_)-5), "' Width"},"")
        else _
    }
    }),
    ReplaceErrValues = Table.ReplaceErrorValues(ChangeParamUnit, {{"Detail 1", null},{"Detail 2", null},{"Detail 3", null}})
in
    ReplaceErrValues