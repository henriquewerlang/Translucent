unit Delphi.Mock.Classes.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockClassTest = class
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
    [Test]
    procedure WhenRegisterAnExpectationMustReturnAEmptyStringIfTheExpectationIsConclued;
    [Test]
    procedure WhenRegisterExpectationsAndNoOneIsCalledMustReturnAMessage;
    [Test]
    procedure WhenMoreThenOneExpectationFailMustReturnMessageOfAllExpectations;
    [Test]
    procedure WhenRegisterACustomExpectationMustCallThisExpectation;
    [Test]
    procedure WhenTheNeverExpectationIsExecutedMustReturnAMessageInExpectation;
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

uses System.Rtti, System.SysUtils, Delphi.Mock, Delphi.Mock.Classes;

{ TMockClassTest }

procedure TMockClassTest.IfDontFindTheConstructorMustRaiseAnException;
begin
  var Mock: TMockClass<TMyClass> := nil;

  Assert.WillRaise(
    procedure
    begin
      Mock := TMock.CreateClass<TMyClass>([1234]);
    end, EConstructorNotFound);

  Mock.Free;
end;

procedure TMockClassTest.WhenCreateAClassMustCallTheCorrectConstructor;
begin
  var Mock := TMock.CreateClass<TMyClass>(['Value']);

  Assert.AreEqual('Create.Param', Mock.Instance.FConstructorCalled);

  Mock.Free;
end;

procedure TMockClassTest.WhenCreateAMockClassMustReturnAInstance;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Assert.IsNotNull(Mock.Instance);

  Mock.Free;
end;

procedure TMockClassTest.WhenMoreThenOneExpectationFailMustReturnMessageOfAllExpectations;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Expect.Once.When.Execute;

  Mock.Expect.Once.When.MyFunction;

  Assert.AreEqual('Expected to call the method "Execute" once but never called'#13#10'Expected to call the method "MyFunction" once but never called', Mock.CheckExpectations);

  Mock.Free;
end;

procedure TMockClassTest.WhenRegisterACustomExpectationMustCallThisExpectation;
begin
  var Executed := False;
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Expect.CustomExpect(
    function (Params: TArray<TValue>): String
    begin
      Executed := True;
    end).When.Execute;

  Mock.Instance.Execute;

  Assert.IsTrue(Executed);

  Mock.Free;
end;

procedure TMockClassTest.WhenRegisterAnExpectationMustReturnAEmptyStringIfTheExpectationIsConclued;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Expect.Once.When.Execute;

  Mock.Instance.Execute;

  Assert.AreEqual(EmptyStr, Mock.CheckExpectations);

  Mock.Free;
end;

procedure TMockClassTest.WhenRegisterAWillExecuteMustCallTheProcedureRegistred;
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

procedure TMockClassTest.WhenRegisterAWillReturnMustReturnTheValueRegistred;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Setup.WillReturn(123456).When.MyFunction;

  Assert.AreEqual(123456, Mock.Instance.MyFunction);

  Mock.Free;
end;

procedure TMockClassTest.WhenRegisterExpectationsAndNoOneIsCalledMustReturnAMessage;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Expect.Once.When.Execute;

  Assert.AreEqual('Expected to call the method "Execute" once but never called', Mock.CheckExpectations);

  Mock.Free;
end;

procedure TMockClassTest.WhenTheNeverExpectationIsExecutedMustReturnAMessageInExpectation;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Expect.Never.When.Execute;

  Mock.Instance.Execute;

  Assert.AreEqual('Expected to never be called the procedure "Execute", but was called 1 times', Mock.CheckExpectations);

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
  // Avoid memory leak in tests.
  TMock.CreateClass<TMyClass>.Free;

end.
