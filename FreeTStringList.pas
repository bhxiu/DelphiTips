// I found some codes written in this way

FStrList := TStringList.Create;

for i := 0 to 10 do
begin
        FStrList.AddObject( 'Item ' + intToStr(i) , TObject(i));
end;



// On the event of destroy:

if FStrList <> nil then
begin
        for I := 0 to FStrList.Count - 1 do
        begin
                FStrList.Objects[i].Free;
        end;
        FreeAndNil(FStrList);
end;



// This would cause application hang as we are trying to free an integer object
// in TStringList. We should be aware that what object is added in TStringList, 
// if it is an Integer, use this way to destroy:

if FStrList <> nil then
begin
        for I := 0 to FStrList.Count - 1 do
        begin

                FStrList.Objects[i] := Pointer(0); // It is mandatory for Integer object.
                FStrList.Objects[i].Free;
        end;
        FreeAndNil(FStrList);
end;

// Or a much simpler way:

if Assigned(FStrList) then 
        FStrList.Destroy;
