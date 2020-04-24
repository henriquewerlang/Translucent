unit Delphi.Mock.Classs;

interface

uses System.SysUtils, System.Rtti, Delphi.Mock;

type
  TMockClass<T: class> = class(TInterfacedObject, IMock<T>)
  public
    constructor Create; reintroduce;

    function CheckExpectations: String;
    function Expect: IMockExpectSetup<T>;
    function Instance: T;
    function WillExecute(Proc: TProc): IMockSetup<T>;
    function WillReturn(const Value: TValue): IMockSetup<T>;
  end;

implementation

{ TMockClass<T> }

function TMockClass<T>.CheckExpectations: String;
begin

end;

constructor TMockClass<T>.Create;
begin
  inherited Create;

  TVirtualMethodInterceptor.Create(T);
end;

function TMockClass<T>.Expect: IMockExpectSetup<T>;
begin

end;

function TMockClass<T>.Instance: T;
begin

end;

function TMockClass<T>.WillExecute(Proc: TProc): IMockSetup<T>;
begin

end;

function TMockClass<T>.WillReturn(const Value: TValue): IMockSetup<T>;
begin

end;

end.
