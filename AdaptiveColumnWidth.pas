procedure GetColMaxDataLength(ASGrid: TStringGrid);
var
  MaxColLength, 
  CellLength: Integer;
  ACol,ARow: Integer;
begin
  with ASGrid do
  begin
    for ACol := 0 to ColumnCount - 1 do
    begin
      MaxColLength:=Canvas.TextWidth(Columns[ACol].Header);
      for ARow := 0 to RowCount - 1 do
      begin
        CellLength := Canvas.TextWidth(Cells[ACol,ARow]);
        if CellLength > MaxColLength then
          MaxColLength := CellLength;
      end;
      Columns[ACol].Width := MaxColLength + CFixPadding;  // const CFixPadding = 20 or whatever
    end;
  end;
end;


