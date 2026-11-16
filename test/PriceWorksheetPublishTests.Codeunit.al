/*
    Author: Niklas Dougherty <nd@abas.se>
    Date: 2026-11-16
    Description: Test unit for price calculus.
*/

namespace ABAS.ABAS_Price_Calculus;

using Microsoft.Inventory.Item;
using Microsoft.Pricing.PriceList;

codeunit 50114 "Price Worksheet Publish Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        TestLib: Codeunit "Price Worksheet Test Library";

    [Test]
    [HandlerFunctions('ConfirmYesHandler,MessageHandler')]
    procedure TestCopySalesPriceAndPublishActive()
    var
        Item: Record Item;
        Header: Record "Price List Header";
        Line: Record "Price List Line";
        Worksheet: TestPage "ABAS Price List Worksheet";
    begin
        this.TestLib.ResetWorksheet();
        this.TestLib.CreateItemWithPrices(Item, 100, 150, 140);
        this.TestLib.CreatePriceList(Header, Line, Item."No.", 90, Header."Amount Type"::Price, Header.Status::Active);

        Worksheet.OpenEdit();
        Worksheet."Price List Code".SetValue(Header.Code);
        Worksheet.PriceLines.First();
        this.TestLib.AreEqual(150, Worksheet.PriceLines.ItemSalesPrice.AsDecimal(), 'Sales price mismatch');

        Worksheet.ApplySalesPrice.Invoke();
        Worksheet.CommitPriceList.Invoke();
        Worksheet.Close();

        Line.Get(Header.Code, Line."Line No.");
        this.TestLib.AreEqual(150, Line."Unit Price", 'Published price mismatch');
        this.TestLib.AreEqual(Line.Status::Active, Line.Status, 'Line status should be Active');

        Item.Get(Item."No.");
        this.TestLib.AreEqual(150, Item."Unit Price", 'Item unit price not synced');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,MessageHandler')]
    procedure TestNetPriceVisibilityAndRowCopy()
    var
        Item: Record Item;
        Header: Record "Price List Header";
        Line: Record "Price List Line";
        Worksheet: TestPage "ABAS Price List Worksheet";
    begin
        this.TestLib.ResetWorksheet();
        this.TestLib.CreateItemWithPrices(Item, 100, 150, 135);
        this.TestLib.CreatePriceList(Header, Line, Item."No.", 80, Header."Amount Type"::Any, Header.Status::Draft);

        Worksheet.OpenEdit();
        Worksheet."Price List Code".SetValue(Header.Code);
        Worksheet.PriceLines.First();

        this.TestLib.IsTrue(Worksheet.PriceLines.ItemNetPrice.Visible(), 'Net price should be visible');
        this.TestLib.IsFalse(Worksheet.PriceLines.ItemSalesPrice.Visible(), 'Sales price should be hidden');

        Worksheet.PriceLines.CopyRowNetPrice.Invoke();
        Worksheet.CommitPriceList.Invoke();
        Worksheet.Close();

        Line.Get(Header.Code, Line."Line No.");
        this.TestLib.AreEqual(135, Line."Unit Price", 'Published net price mismatch');
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