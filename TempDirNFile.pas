procedure TForm1.Button1Click(Sender: TObject);
var
  TempFile: array[0..MAX_PATH - 1] of Char;
  TempPath: array[0..MAX_PATH - 1] of Char;
begin
  GetTempPath(MAX_PATH, TempPath);
  if GetTempFileName(TempPath, PChar('abc'), 0, TempFile) = 0 then
    raise Exception.Create(
      'GetTempFileName API failed. ' + SysErrorMessage(GetLastError)
    );
  ShowMessage(TempFile);
  memo1.Lines.SaveToFile(tempfile);
end;

