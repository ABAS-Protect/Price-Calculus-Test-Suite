/*
    Author: Niklas Dougherty <nd@abas.se>
    Date: 2026-11-16
    Description: Test unit for price calculus.
*/

namespace ABAS.ABAS_Price_Calculus;

using Microsoft.Inventory.Item;
using Microsoft.Pricing.PriceList;

codeunit 50112 "Price Worksheet Test Library"
{
    procedure ResetWorksheet()
    var
        WorksheetHeader: Record "Worksheet Header";
    begin
        WorksheetHeader.DeleteAll();
    end;

    procedure CreateItemWithPrices(var Item: Record Item; Cost: Decimal; SalesPrice: Decimal; NetPrice: Decimal)
    begin
        Item.Init();
        Item."No." := CopyStr(CreateGuid(), 2, 10);
        Item.Description := 'Test ' + Item."No.";
        Item."Replenishment System" := Item."Replenishment System"::Purchase;
        Item."Unit Cost" := Cost;
        Item."COMP Sales Price" := SalesPrice;
        Item."COMP Net Price" := NetPrice;
        Item.Insert(true);
    end;

    procedure CreatePriceList(var Header: Record "Price List Header"; var Line: Record "Price List Line"; ItemNo: Code[20]; Price: Decimal; AmtType: Enum "Price Amount Type"; TargetStatus: Enum "Price Status")
    begin
        Header.Init();
        Header.Code := CopyStr(CreateGuid(), 2, 10);
        Header."Price Type" := Header."Price Type"::Sale;
        Header."Amount Type" := AmtType;
        Header.Status := Header.Status::Draft;
        Header.Insert(true);

        this.AddLine(Header, Line, ItemNo, '', 10000, Price);

        if TargetStatus = TargetStatus::Active then begin
            Header.Status := Header.Status::Active;
            Header.Modify(false);
            Line.Status := Line.Status::Active;
            Line.Modify(false);
        end;
    end;

    procedure AddLine(Header: Record "Price List Header"; var Line: Record "Price List Line"; ItemNo: Code[20]; Variant: Code[10]; LineNo: Integer; Price: Decimal)
    begin
        Line.Init();
        Line."Price List Code" := Header.Code;
        Line."Line No." := LineNo;
        Line."Price Type" := Header."Price Type";
        if ItemNo <> '' then begin
            Line."Asset Type" := Line."Asset Type"::Item;
            Line."Asset No." := ItemNo;
        end;
        Line."Variant Code" := Variant;
        Line."Amount Type" := Header."Amount Type";
        Line."Unit Price" := Price;
        Line.Status := Line.Status::Draft;
        Line.Insert(false);
    end;

    procedure AreEqual(Expected: Variant; Actual: Variant; Msg: Text)
    begin
        if Format(Expected) <> Format(Actual) then
            Error('%1. Expected: %2, Actual: %3', Msg, Expected, Actual);
    end;

    procedure IsTrue(Condition: Boolean; Msg: Text)
    begin
        if not Condition then
            Error(Msg);
    end;

    procedure IsFalse(Condition: Boolean; Msg: Text)
    begin
        if Condition then
            Error(Msg);
    end;
}