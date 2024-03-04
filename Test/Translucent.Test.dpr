program Translucent.Test;

{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  Translucent in '..\Translucent.pas',
  Translucent.Method in '..\Translucent.Method.pas',
  Translucent.It.Test in 'Translucent.It.Test.pas',
  Translucent.Classes in '..\Translucent.Classes.pas',
  Translucent.Intf in '..\Translucent.Intf.pas',
  Translucent.Classes.Test in 'Translucent.Classes.Test.pas',
  Translucent.Intf.Test in 'Translucent.Intf.Test.pas',
  Translucent.Method.Test in 'Translucent.Method.Test.pas',
  Translucent.It in '..\Translucent.It.pas';

begin
  TestInsight.DUnitX.RunRegisteredTests;
end.

