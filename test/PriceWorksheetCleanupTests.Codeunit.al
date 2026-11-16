/*
    Author: Niklas Dougherty <nd@abas.se>
    Date: 2026-11-16
    Description: Test unit for price calculus.
*/

namespace ABAS.ABAS_Price_Calculus;

using Microsoft.Inventory.Item;
using Microsoft.Pricing.PriceList;

codeunit 50113 "Price Worksheet Cleanup Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        TestLib: Codeunit "Price Worksheet Test Library";

    [Test]
    procedure TestMarkupAndCommentCacheRefresh()
    var
        Item: Record Item;
        Header: Record "Price List Header";
        Line1: Record "Price List Line";
        Line2: Record "Price List Line";
        Worksheet: TestPage "ABAS Price List Worksheet";
    begin
        this.TestLib.ResetWorksheet();
        this.TestLib.CreateItemWithPrices(Item, 100, 120, 110);
        this.TestLib.CreatePriceList(Header, Line1, Item."No.", 100, Header."Amount Type"::Price, Header.Status::Draft);
        this.TestLib.AddLine(Header, Line2, Item."No.", 'V1', 20000, 100);

        Worksheet.OpenEdit();
        Worksheet."Price List Code".SetValue(Header.Code);

        Worksheet.PriceLines.First();
        Worksheet.PriceLines.ItemMarkup.SetValue(25);
        Worksheet.PriceLines.ItemComment.SetValue('Test Note');

        Worksheet.PriceLines.Next();
        this.TestLib.AreEqual(25, Worksheet.PriceLines.ItemMarkup.AsInteger(), 'Cache did not refresh markup');
        this.TestLib.AreEqual('Test Note', Worksheet.PriceLines.ItemComment.Value(), 'Cache did not refresh comment');
        Worksheet.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,MessageHandler')]
    procedure TestDuplicateAndShadowListCleanup()
    var
        Item: Record Item;
        Header: Record "Price List Header";
        ShadowHeader: Record "Price List Header";
        Line1: Record "Price List Line";
        EmptyLine: Record "Price List Line";
        DupLine: Record "Price List Line";
        ShadowLine: Record "Price List Line";
        Worksheet: TestPage "ABAS Price List Worksheet";
    begin
        this.TestLib.ResetWorksheet();
        this.TestLib.CreateItemWithPrices(Item, 50, 80, 75);
        this.TestLib.CreatePriceList(Header, Line1, Item."No.", 60, Header."Amount Type"::Price, Header.Status::Draft);
        this.TestLib.AddLine(Header, EmptyLine, '', '', 20000, 0);
        this.TestLib.AddLine(Header, DupLine, Item."No.", '', 30000, 80);

        this.CreateShadowList(ShadowHeader, ShadowLine, 'J09999', Item."No.");

        Worksheet.OpenEdit();
        Worksheet."Price List Code".SetValue(Header.Code);
        Worksheet.ApplySalesPrice.Invoke();
        Worksheet.CommitPriceList.Invoke();
        Worksheet.Close();

        DupLine.SetRange("Price List Code", Header.Code);
        this.TestLib.AreEqual(1, DupLine.Count(), 'Empty and duplicate lines were not removed');
        this.TestLib.IsFalse(ShadowHeader.Get('J09999'), 'Shadow price list was not deleted');
    end;

    local procedure CreateShadowList(var Header: Record "Price List Header"; var Line: Record "Price List Line"; CodeVal: Code[20]; ItemNo: Code[20])
    begin
        if Header.Get(CodeVal) then
            Header.Delete(true);
        Header.Init();
        Header.Code := CodeVal;
        Header."Price Type" := Header."Price Type"::Sale;
        Header.Status := Header.Status::Active;
        Header.Insert(false);
        this.TestLib.AddLine(Header, Line, ItemNo, '', 10000, 50);
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
    end;
}