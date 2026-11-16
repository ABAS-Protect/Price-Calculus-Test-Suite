/*
    Author: Niklas Dougherty <nd@abas.se>
    Date: 2026-11-16
    Description: Test unit for price calculus.
*/

namespace ABAS.ABAS_Price_Calculus;

page 50116 "Price Worksheet Test Runner"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Price Worksheet Test Runner';

    actions
    {
        area(Processing)
        {
            action(RunAllTests)
            {
                Caption = 'Run All Tests';
                ApplicationArea = All;
                Tooltip = 'Run the test suites';
                Image = TestFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Price Worksheet Test Runner");
                end;
            }
        }
    }
}