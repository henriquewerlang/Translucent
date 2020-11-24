unit Delphi.Mock.Setup;

interface

uses System.Rtti, System.SysUtils, Delphi.Mock;

type
  TMockSetup<T> = class(TInterfacedObject, IMockSetup<T>, IMockSetupWhen<T>)
  public
    constructor Create(Instance: T);

    function Instance: T;
    function When: T;
    function WillExecute(Proc: TProc): IMockSetupWhen<T>;
    function WillReturn(const Value: TValue): IMockSetupWhen<T>;

    procedure Invoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  end;

implementation

{ TMockSetup<T> }

constructor TMockSetup<T>.Create(Instance: T);
begin

end;

function TMockSetup<T>.Instance: T;
begin

end;

procedure TMockSetup<T>.Invoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin

end;

function TMockSetup<T>.When: T;
begin

end;

function TMockSetup<T>.WillExecute(Proc: TProc): IMockSetupWhen<T>;
begin

end;

function TMockSetup<T>.WillReturn(const Value: TValue): IMockSetupWhen<T>;
begin

end;

end.
