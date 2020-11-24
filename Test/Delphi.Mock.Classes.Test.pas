unit Delphi.Mock.Classes.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockTest = class
  public
    [Test]
    procedure WhenCreateAMockClassMustReturnAInstance;
    [Test]
    procedure WhenRegisterAWillExecuteMustCallTheProcedureRegistred;
    [Test]
    procedure WhenRegisterAWillReturnMustReturnTheValueRegistred;
    [Test]
    procedure WhenCreateAClassMustCallTheCorrectConstructor;
    [Test]
    procedure IfDontFindTheConstructorMustRaiseAnException;
  end;

  TMyClass = class
  private
    FConstructorCalled: String;
  public
    constructor Create(Param: String); overload;
    constructor Create(Param1: String; Param2: Integer); overload;

    function MyFunction: Integer; virtual;

    procedure Execute; virtual;
  end;

implementation

uses Delphi.Mock, Delphi.Mock.Classes;

{ TMockTest }

procedure TMockTest.IfDontFindTheConstructorMustRaiseAnException;
begin
  var Mock: TMock<TMyClass> := nil;

  Assert.WillRaise(
    procedure
    begin
      Mock := TMock.CreateClass<TMyClass>([1234]);
    end, EConstructorNotFound);

  Mock.Free;
end;

procedure TMockTest.WhenCreateAClassMustCallTheCorrectConstructor;
begin
  var Mock := TMock.CreateClass<TMyClass>(['Value']);

  Assert.AreEqual('Create.Param', Mock.Instance.FConstructorCalled);

  Mock.Free;
end;

procedure TMockTest.WhenCreateAMockClassMustReturnAInstance;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Assert.IsNotNull(Mock.Instance);

  Mock.Free;
end;

procedure TMockTest.WhenRegisterAWillExecuteMustCallTheProcedureRegistred;
begin
  var Executed := False;
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Setup.WillExecute(
    procedure
    begin
      Executed := True;
    end).When.Execute;

  Mock.Instance.Execute;

  Assert.IsTrue(Executed);

  Mock.Free;
end;

procedure TMockTest.WhenRegisterAWillReturnMustReturnTheValueRegistred;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Setup.WillReturn(123456).When.MyFunction;

  Assert.AreEqual(123456, Mock.Instance.MyFunction);

  Mock.Free;
end;

{ TMyClass }

constructor TMyClass.Create(Param: String);
begin
  FConstructorCalled := 'Create.Param';
end;

constructor TMyClass.Create(Param1: String; Param2: Integer);
begin
  FConstructorCalled := 'Create.Param1.Param2';
end;

procedure TMyClass.Execute;
begin

end;

function TMyClass.MyFunction: Integer;
begin
  Result := 0;
end;

initialization
  TDUnitX.RegisterTestFixture(TMockTest);

  // Avoid memory leak in tests.
  TMock.CreateClass<TMyClass>.Free;

end.
