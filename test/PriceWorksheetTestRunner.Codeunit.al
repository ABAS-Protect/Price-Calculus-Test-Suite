/*
    Author: Niklas Dougherty <nd@abas.se>
    Date: 2026-11-16
    Description: Keep tests isolated.
*/

namespace ABAS.ABAS_Price_Calculus;

codeunit 50115 "Price Worksheet Test Runner"
{
    Subtype = TestRunner;
    TestIsolation = Codeunit;

    var
        PassedCount: Integer;

    trigger OnRun()
    begin
        this.PassedCount := 0;
        Codeunit.Run(Codeunit::"Price Worksheet Cleanup Tests");
        Codeunit.Run(Codeunit::"Price Worksheet Publish Tests");
        Message('All %1 tests passed successfully.', this.PassedCount);
    end;

    trigger OnAfterTestRun(CodeunitId: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions; Success: Boolean)
    begin
        if Success then
            this.PassedCount += 1
        else
            Error('Test failed in %1.%2: %3', CodeunitName, FunctionName, GetLastErrorText());
    end;
}