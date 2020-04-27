unit Delphi.Mock.Interf;

interface

uses System.Rtti, System.Generics.Collections, System.SysUtils, Delphi.Mock, Delphi.Mock.VirtualInterface;

type
  TMockInterface<T: IInterface> = class(TVirtualInterfaceEx, IMock<T>)
  private
    function Expect: IMockExpectSetup<T>;
    function Setup: IMockSetup<T>;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create; reintroduce;
  end;

implementation

uses System.TypInfo, Delphi.Mock.Interf.Setup, Delphi.Mock.Interf.Expect, Delphi.Mock.Method;

{ TMockInterface<T> }

constructor TMockInterface<T>.Create;
begin
  inherited Create(TypeInfo(T), OnInvoke);
end;

function TMockInterface<T>.Expect: IMockExpectSetup<T>;
begin
end;

//function TMockInterface<T>.Instance: T;
//begin
//  QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
//end;

procedure TMockInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin

end;

function TMockInterface<T>.Setup: IMockSetup<T>;
begin
  Result := TMockInterfaceSetup<T>.Create;
end;

end.

