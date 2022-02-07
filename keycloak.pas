unit Medigent.Common.KC;
(* Module Header

  ------------------------------------------------------------------------
        Create a instance of TKCConnection, then assign Username and password.
        Invoke IsUserAuthenticated to talk to Keycloak and get authenticated.
        Token is not null means authenticated successfully.
        GetCustomInfo gets user roles information.
        If we don't keep user information in our database, we would retrieve
        user information from Token.

    Some functions like GetCustomInfo contains business logic that could not
    be shared, face codes are used here.

*)

interface

uses  SysUtils
      ,Classes
      ,REST.Types
      ,REST.Client
      ,System.JSON
      ,IPPeerCommon 
      ,IPPeerClient 
      ,System.NetEncoding
      ;

type

  EKeycloak = class;
  TKCConnection = class;

  TKCConnection = class
    private
      FServer: String;
      FContext: String;
      FRealm: String;
      FClientID: String;
      FClientSecret: String;
      FGrantType: string;

      FPassword: String;
      FUsername: String;
      FToken: String;     // Token got from Keycloak would contain roles information etc.

      FRoles: TStringList;

      FRESTClient: TRESTClient;
      FRESTRequest: TRESTRequest;
      FRESTResponse: TRESTResponse;


      function IsUserAuthenticated: Boolean;
      function GetJsonValue(psValue, psJson: String):String;
      procedure SetUserName(AName: String);
      procedure SetPassword(APassword:String);
      procedure Connect;

    public
      constructor Create( const AServer:        string;
                          const AContext:       String;
                          const ARealm:         String;
                          const AClientID:      String;
                          const AClientSecret:  string;
                          const AGrantType:     string = 'password');
      destructor Destroy; override;

      property UserName: String read FUsername write SetUsername;
      property Password: String read FPassword write SetPassword;
      property Token: String read FToken;
      property UserAuthenticated: Boolean read IsUserAuthenticated;
      property UserRoles: TStringList read FRoles;
      procedure GetCustomInfo;

  end;

  EKeycloak = class(Exception);

procedure KCError(const s: string; errorCode: Integer = 0);

implementation


{ TKCConnection }

procedure KCError(const s: string; errorCode: Integer);
begin
  if errorCode = 0 then
    raise EKeycloak.Create( s )
  else
    raise EKeycloak.CreateFmt( '[%0.8X]: %s', [errorCode, s] );
end;


constructor TKCConnection.Create( const AServer:        string;
                          const AContext:       String;
                          const ARealm:         String;
                          const AClientID:      String;
                          const AClientSecret:  string;
                          const AGrantType:     string = 'password');
begin
   FServer := AServer;
   FClientID := AClientID;
   FClientSecret := AClientSecret;
   FGrantType := AGrantType;
   FRealm := ARealm;
   FContext := AContext;

   FRoles := TStringList.Create;

   Connect;
end;

destructor TKCConnection.Destroy;
begin

  inherited;
  if Assigned(FRESTClient) then FreeAndNil(FRESTClient);
  if Assigned(FRESTRequest) then FreeAndNil(FRESTRequest);
  if Assigned(FRESTResponse) then FreeAndNil(FRESTResponse);
  if Assigned(FRoles) then FreeAndNil(FRoles);

end;

function TKCConnection.GetJsonValue(psValue, psJson: String): String;
var
  json:TJSONObject;
  jsonValue:TJsonValue;
begin
  result := '';
  if (psValue = '') or (psJson = '') then exit;

  json := TJSONObject.Create;
  try
    try
      jsonValue := (json.ParseJSONValue(psJson) as TJSonObject).GetValue(psValue);
      if Assigned(jsonValue) then
        Result := JsonValue.ToString;
    except
      result := '';
    end;
  finally
    FreeAndNil(json);
  end;
end;

function TKCConnection.IsUserAuthenticated: Boolean;
var
    vBaseUrl: String;
begin
  //Set openid params to authenticate
    Connect;
    vBaseUrl :=   FServer
                + '/'
                + FContext
                + '/realms/' + FRealm
                + '/protocol/openid-connect/token'
                ;

  if ( FUsername <> '') and (FPassword <> '') then
  begin
    FRESTClient.ResetToDefaults;
    FRESTClient.BaseURL := vBaseUrl;
    FRESTRequest.Method := TRESTRequestMethod.rmPOST;
    FRESTRequest.AddParameter('client_id',FClientID,TRESTRequestParameterKind.pkGETorPOST);
    FRESTRequest.AddParameter('client_secret',FClientSecret,TRESTRequestParameterKind.pkGETorPOST);
    FRESTRequest.AddParameter('grant_type',FGrantType,TRESTRequestParameterKind.pkGETorPOST);
    FRestrequest.AddParameter('username',FUserName,TRESTRequestParameterKind.pkGETorPOST);
    FRestrequest.AddParameter('password',FPassword,TRESTRequestParameterKind.pkGETorPOST);
    try
      FRESTRequest.Execute;

    except
      on E:Exception do
      begin
        KCError('In IsUserAuthenticated => Exception class name: ' + E.ClassName
                + 'Exception message: ' + E.Message
                );
      end;
    end;

    if not FRESTResponse.Status.Success then
    begin
//      KCError('Unable to get token');
      FToken := '';
    end
    else
    begin
      FToken := GetJsonValue('access_token',FRESTRequest.Response.Content);
    end;
  end;

   GetCustomInfo;
   Result := (FToken <> '');
end;


procedure TKCConnection.Connect;
begin
  if FServer = '' then
  begin
      KCError('Could not set connection to Keycloak. Check config.xml file.');
      exit;
  end;
  if Assigned(FRESTClient) then FreeAndNil(FRESTClient);
  if Assigned(FRESTRequest) then FreeAndNil(FRESTRequest);
  if Assigned(FRESTResponse) then FreeAndNil(FRESTResponse);

   try
      FRestClient := TRESTClient.Create(FServer);
   except
    on E: Exception do
    begin
      KCError(Format('Could not create RESTClient for %s [%s]: %s', [FServer, E.ClassName,E.Message]));
      raise;
    end;
   end;

   try
      FRestRequest := TRESTRequest.Create(nil);
   except
    on E: Exception do
    begin
      KCError(Format('Could not create RestRequest[%s]: %s', [E.ClassName,E.Message]));
      raise;
    end;
   end;

   try
      FRestResponse := TRestResponse.Create(nil);
   except
    on E: Exception do
    begin
      KCError(Format('Could not create RestResponse[%s]: %s', [E.ClassName,E.Message]));
      raise;
    end;
   end;

  FRestRequest.Client := FRestClient;
  FRestRequest.Response := FRestResponse;

  FRESTClient.ResetToDefaults;

end;

procedure TKCConnection.SetPassword(APassword: String);
begin

    //fake codes

  FPassword := trim(APassword);

end;

procedure TKCConnection.SetUserName(AName: String);
begin

    //fake codes

  FUserName := trim(AName);
end;

procedure TKCConnection.GetCustomInfo;
var
  aStr: string;
  oStr: TStringList;
const
  scSSusers = 'default';
  procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
  begin
     ListOfStrings.Clear;
     ListOfStrings.Delimiter       := Delimiter;
     ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
     ListOfStrings.DelimitedText   := Str;
  end;
begin

  // fake codes

  FRoles.Clear;
  if FToken = '' then exit;
  aStr := FToken;
  aStr := aStr.Trim(['"']);
  oStr := TStringList.Create;
  oStr.Sorted := true;
  oStr.Duplicates := TDuplicates.dupIgnore;
  try
    Split('.', aStr, oStr);
    if oStr.Count < 2 then exit;
    aStr := oStr[1];
    try
      aStr := TNetEncoding.Base64.Decode(aStr);
      aStr := GetJsonValue('resource_access',aStr);
      aStr := GetJsonValue(FClientID, aStr);
      aStr := GetJsonValue('roles',aStr);
      aStr := aStr.Trim(['[',']']);
      Split(',',aStr, oStr);
      oStr.Add(scSSusers);
      FRoles.Assign(oStr);
    except
      // Do nothing
      // If no roles set here, GetJsonValue would raise exception
      // We just ignore it.
    end;
  finally
    oStr.Free;
  end;
end;
end.
