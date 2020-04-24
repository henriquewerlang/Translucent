unit Delphi.Mock.Interf.Setup;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections, Delphi.Mock, Delphi.Mock.VirtualInterface;

type
  ENoParamsDefined = class(Exception);
  EParamsLengthDiffer = class(Exception);

  TMockSetupInterface<T: IInterface> = class(TVirtualInterfaceEx, IMockSetup<T>)
  private
    FMethod: IMethodInfo;
    FMethodRegister: IMethodRegister;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create(MethodRegister: IMethodRegister; Method: IMethodInfo);

    function When: T;
  end;

implementation

uses System.TypInfo;

{ TMockSetupInterface<T> }

constructor TMockSetupInterface<T>.Create(MethodRegister: IMethodRegister; Method: IMethodInfo);
begin
  inherited Create(TypeInfo(T), OnInvoke);

  FMethod := Method;
  FMethodRegister := MethodRegister;
end;

procedure TMockSetupInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  var LengthArg := Pred(Length(Args));

  if LengthArg > 0 then
    if Length(GItParams) = 0 then
      raise ENoParamsDefined.Create('You have to use de "It" function to register params to execution!')
    else if Length(GItParams) <> LengthArg then
      raise EParamsLengthDiffer.Create('The length of params and it params, must be the same!');

  FMethodRegister.RegisterMethod(Method, FMethod);

  FMethod.FillItParams;
end;

function TMockSetupInterface<T>.When: T;
begin
  QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
end;

end.

