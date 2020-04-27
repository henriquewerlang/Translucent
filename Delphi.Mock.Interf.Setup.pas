unit Delphi.Mock.Interf.Setup;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections, Delphi.Mock, Delphi.Mock.VirtualInterface;

type
  ENoParamsDefined = class(Exception);
  EParamsLengthDiffer = class(Exception);

  TMockInterfaceSetup<T: IInterface> = class(TVirtualInterfaceEx, IMockSetup<T>)
  private
    function Instance: T;
    function WillExecute(Proc: TProc): IMockSetupWhen<T>;
    function WillReturn(const Value: TValue): IMockSetupWhen<T>;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create;

    function When: T;
  end;

implementation

uses System.TypInfo;

{ TMockInterfaceSetup<T> }

constructor TMockInterfaceSetup<T>.Create;
begin
  inherited Create(TypeInfo(T), OnInvoke);
end;

function TMockInterfaceSetup<T>.Instance: T;
begin

end;

procedure TMockInterfaceSetup<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
end;

function TMockInterfaceSetup<T>.When: T;
begin
  QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
end;

function TMockInterfaceSetup<T>.WillExecute(Proc: TProc): IMockSetupWhen<T>;
begin

end;

function TMockInterfaceSetup<T>.WillReturn(const Value: TValue): IMockSetupWhen<T>;
begin

end;

end.

