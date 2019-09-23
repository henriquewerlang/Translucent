unit Delphi.Mock.VirtualInterface.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TVirtualInterfaceExTest = class
  public
    [Test]
    procedure WhenTheInterfaceDontHaveAGUIDWillRaiseAException;
    [Test]
    procedure IfTheInterfaceDontHaveMethodInfoAtiveWillRaiseAException;
  end;

  IInterfaceWithoutGUI = interface

  end;

  IInterfaceWithoutMethodInfo = interface
    ['{A514CB4D-326C-4266-BF8C-29DBBBDA08E0}']
    procedure Method;
  end;

implementation

uses Delphi.Mock.VirtualInterface;

{ TVirtualInterfaceExTest }

procedure TVirtualInterfaceExTest.IfTheInterfaceDontHaveMethodInfoAtiveWillRaiseAException;
begin
  Assert.WillRaise(
    procedure
    begin
      TVirtualInterfaceEx.Create(TypeInfo(IInterfaceWithoutMethodInfo));
    end, EInterfaceWithoutMethodInfo);
end;

procedure TVirtualInterfaceExTest.WhenTheInterfaceDontHaveAGUIDWillRaiseAException;
begin
  Assert.WillRaise(
    procedure
    begin
      TVirtualInterfaceEx.Create(TypeInfo(IInterfaceWithoutGUI));
    end, EInterfaceWithoutGUID);
end;

initialization
  TDUnitX.RegisterTestFixture(TVirtualInterfaceExTest);

end.
