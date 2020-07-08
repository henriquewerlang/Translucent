unit Delphi.Mock.Method;

interface

uses System.SysUtils, System.Rtti;

type
  EDidNotCallTheStartRegister = class(Exception)
  public
    constructor Create;
  end;

  EMethodNotRegistered = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
  end;

  EParamsRegisteredMismatch = class(Exception)
  public
    constructor Create;
  end;

  IIt = interface
    ['{5B034A6E-3953-4A0A-9A3A-6805210E082E}']
    function Compare(const Value: TValue): Boolean;
  end;

  IMethod = interface
    ['{047238B7-4FEB-4D99-A7B9-108F1627F298}']
    function GetItParams: TArray<IIt>;
    function GetMethod: TRttiMethod;

    procedure Execute(out Result: TValue);
    procedure SetItParams(const Value: TArray<IIt>);
    procedure SetMethod(const Value: TRttiMethod);

    property ItParams: TArray<IIt> read GetItParams write SetItParams;
    property Method: TRttiMethod read GetMethod write SetMethod;
  end;

  IMethodExpect = interface
    ['{01FB3CF2-C990-4078-AF97-C9E3F4CD9B44}']
    function CheckExpectation: String;
  end;

  IMethodRegister = interface
    ['{A3AD240A-0365-40D2-801E-E094BFB1BA9C}']
    procedure ExecuteMethod(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure RegisterMethod(Method: TRttiMethod);
    procedure StartRegister(Method: IMethod);
  end;

  TMethodRegister = class(TInterfacedObject, IMethodRegister)
  private
    FMethodRegistering: IMethod;
    FMethods: TArray<IMethod>;
  public
    procedure ExecuteMethod(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure RegisterMethod(Method: TRttiMethod);
    procedure StartRegister(Method: IMethod);
  end;

  TMethodInfo = class(TInterfacedObject)
  private
    FMethod: TRttiMethod;

    FItParams: TArray<IIt>;
  protected
    function GetItParams: TArray<IIt>;
    function GetMethod: TRttiMethod;

    procedure SetItParams(const Value: TArray<IIt>);
    procedure SetMethod(const Value: TRttiMethod);
  end;

  TMethodInfoWillExecute = class(TMethodInfo, IMethod)
  private
    FProc: TProc;
  public
    constructor Create(Proc: TProc);

    procedure Execute(out Result: TValue);
  end;

  TMethodInfoWillReturn = class(TMethodInfo, IMethod)
  private
    FReturnValue: TValue;
  public
    constructor Create(const ReturnValue: TValue);

    procedure Execute(out Result: TValue);
  end;

  TMethodInfoCounter = class(TMethodInfo, IMethod)
  private
    FExecutionCount: Integer;
  public
    procedure Execute(out Result: TValue);
  end;

  TMethodInfoExpectOnce = class(TMethodInfoCounter, IMethodExpect)
  public
    function CheckExpectation: String;
  end;

var
  GItParams: TArray<IIt>;

implementation

{ TMethodInfoWillExecute }

constructor TMethodInfoWillExecute.Create(Proc: TProc);
begin
  inherited Create;

  FProc := Proc;
end;

procedure TMethodInfoWillExecute.Execute(out Result: TValue);
begin
  FProc;
end;

{ TMethodInfoWillReturn }

constructor TMethodInfoWillReturn.Create(const ReturnValue: TValue);
begin
  inherited Create;

  FReturnValue := ReturnValue;
end;

procedure TMethodInfoWillReturn.Execute(out Result: TValue);
begin
  Result := FReturnValue;
end;

{ TMethodInfoCounter }

procedure TMethodInfoCounter.Execute(out Result: TValue);
begin
  inherited;

  Inc(FExecutionCount);
end;

{ TMethodInfoExpectOnce }

function TMethodInfoExpectOnce.CheckExpectation: String;
begin
  Result := EmptyStr;

  if FExecutionCount = 0 then
    Result := 'Expected to call once the method but never called'
  else if FExecutionCount > 1 then
    Result := 'Expected to call once the method but was called 5 times';
end;

{ TMethodRegister }

procedure TMethodRegister.ExecuteMethod(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  for var RegisteredMethod in FMethods do
    if RegisteredMethod.Method = Method then
    begin
      var CanCall := True;

      for var A := Low(Args) to High(Args) do
        if not RegisteredMethod.ItParams[A].Compare(Args[A]) then
          CanCall := False;

      if CanCall then
      begin
        RegisteredMethod.Execute(Result);

        Exit;
      end;
    end;

  raise EMethodNotRegistered.Create(Method);
end;

procedure TMethodRegister.RegisterMethod(Method: TRttiMethod);
begin
  if not Assigned(FMethodRegistering) then
    raise EDidNotCallTheStartRegister.Create;

  if Length(GItParams) <> Length(Method.GetParameters) then
    raise EParamsRegisteredMismatch.Create;

  FMethodRegistering.ItParams := GItParams;
  FMethodRegistering.Method := Method;
  FMethods := FMethods + [FMethodRegistering];

  FMethodRegistering := nil;
end;

procedure TMethodRegister.StartRegister(Method: IMethod);
begin
  FMethodRegistering := Method;
  GItParams := nil;
end;

{ EDidNotCallTheStartRegister }

constructor EDidNotCallTheStartRegister.Create;
begin
  inherited Create('You must call StartRegister before call RegisterMethod');
end;

{ TMethodInfo }

function TMethodInfo.GetItParams: TArray<IIt>;
begin
  Result := FItParams;
end;

function TMethodInfo.GetMethod: TRttiMethod;
begin
  Result := FMethod;
end;

procedure TMethodInfo.SetItParams(const Value: TArray<IIt>);
begin
  FItParams := Value;
end;

procedure TMethodInfo.SetMethod(const Value: TRttiMethod);
begin
  FMethod := Value;
end;

{ EMethodNotRegistered }

constructor EMethodNotRegistered.Create(Method: TRttiMethod);
begin
  inherited CreateFmt('The calling method %s is not registered!', [Method.Name]);
end;

{ EParamsRegisteredMismatch }

constructor EParamsRegisteredMismatch.Create;
begin
  inherited Create('The procedure being called and the number of parameters registered is different!');
end;

end.

