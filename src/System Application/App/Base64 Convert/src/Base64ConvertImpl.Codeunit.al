// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

using System;

codeunit 4111 "Base64 Convert Impl."
{
    Access = Internal;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure ToBase64(String: Text): Text
    begin
        exit(ToBase64(String, false));
    end;

    procedure ToBase64(String: Text; InsertLineBreaks: Boolean): Text
    begin
        exit(ToBase64(String, InsertLineBreaks, TextEncoding::UTF8, 0));
    end;

    procedure ToBase64(String: Text; TextEncoding: TextEncoding): Text
    begin
        exit(ToBase64(String, false, TextEncoding, 0));
    end;

    procedure ToBase64(String: Text; TextEncoding: TextEncoding; Codepage: Integer): Text
    begin
        exit(ToBase64(String, false, TextEncoding, Codepage));
    end;

    procedure ToBase64(String: Text; InsertLineBreaks: Boolean; TextEncoding: TextEncoding): Text
    begin
        exit(ToBase64(String, InsertLineBreaks, TextEncoding, 0));
    end;

    procedure ToBase64(String: Text; InsertLineBreaks: Boolean; TextEncoding: TextEncoding; Codepage: Integer): Text
    var
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        Base64FormattingOptions: DotNet Base64FormattingOptions;
        Base64String: Text;
    begin
        if String = '' then
            exit('');

        if InsertLineBreaks then
            Base64FormattingOptions := Base64FormattingOptions.InsertLineBreaks
        else
            Base64FormattingOptions := Base64FormattingOptions.None;
        case TextEncoding of
            TextEncoding::UTF16:
                Base64String := Convert.ToBase64String(Encoding.Unicode().GetBytes(String), Base64FormattingOptions);
            TextEncoding::MSDos,
            TextEncoding::Windows:
                Base64String := Convert.ToBase64String(Encoding.GetEncoding(Codepage).GetBytes(String), Base64FormattingOptions);
            else
                Base64String := Convert.ToBase64String(Encoding.UTF8().GetBytes(String), Base64FormattingOptions);
        end;

        exit(Base64String);
    end;

    procedure ToBase64(InStream: InStream): Text
    begin
        exit(ToBase64(InStream, false));
    end;

    procedure ToBase64(InStream: InStream; InsertLineBreaks: Boolean): Text
    var
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        InputArray: DotNet Array;
        Base64FormattingOptions: DotNet Base64FormattingOptions;
        Base64String: Text;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);
        InputArray := MemoryStream.ToArray();

        if InsertLineBreaks then
            Base64String := Convert.ToBase64String(InputArray, Base64FormattingOptions.InsertLineBreaks)
        else
            Base64String := Convert.ToBase64String(InputArray);

        MemoryStream.Close();
        exit(Base64String);
    end;

    [NonDebuggable]
    procedure ToBase64(SecretString: SecretText): SecretText
    var
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        Base64FormattingOptions: DotNet Base64FormattingOptions;
    begin
        if SecretString.IsEmpty() then
            exit;
        Base64FormattingOptions := Base64FormattingOptions.None;
        exit(Convert.ToBase64String(Encoding.UTF8().GetBytes(SecretString.Unwrap()), Base64FormattingOptions));
    end;

    procedure ToBase64Url(String: Text; TextEncoding: TextEncoding; Codepage: Integer): Text
    var
        Base64String: Text;
    begin
        Base64String := ToBase64(String, false, TextEncoding, Codepage);
        exit(RemoveUrlUnsafeChars(Base64String));
    end;

    procedure ToBase64Url(String: Text): Text
    begin
        exit(ToBase64Url(String, TextEncoding::UTF8, 0));
    end;

    procedure ToBase64Url(String: Text; TextEncoding: TextEncoding): Text
    begin
        exit(ToBase64Url(String, TextEncoding, 0));
    end;

    procedure ToBase64Url(InStream: InStream): Text
    var
        Base64String: Text;
    begin
        Base64String := ToBase64(InStream, false);
        exit(RemoveUrlUnsafeChars(Base64String));
    end;

    [NonDebuggable]
    procedure ToBase64Url(SecretString: SecretText): SecretText
    var
        Base64SecretString: SecretText;
        Base64String: Text;
    begin
        Base64SecretString := ToBase64(SecretString);
        if Base64SecretString.IsEmpty() then
            exit;
        Base64String := Base64SecretString.Unwrap();
        exit(RemoveUrlUnsafeChars(Base64String));
    end;

    [NonDebuggable]
    local procedure RemoveUrlUnsafeChars(Base64String: Text): Text
    var
        TB: TextBuilder;
        Ch: Char;
    begin
        foreach Ch in Base64String do
            case Ch of
                '+':
                    TB.Append('-');
                '/':
                    TB.Append('_');
                '=':
                    continue;
                else
                    TB.Append(Ch);
            end;

        exit(TB.ToText());
    end;

    procedure FromBase64(Base64String: Text; TextEncoding: TextEncoding): Text
    begin
        exit(FromBase64(Base64String, TextEncoding, 1252));
    end;

    procedure FromBase64(Base64String: Text; TextEncoding: TextEncoding; CodePage: Integer): Text
    var
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        OutputString: Text;
    begin
        if Base64String = '' then
            exit('');

        case TextEncoding of
            TextEncoding::UTF16:
                OutputString := Encoding.Unicode().GetString(Convert.FromBase64String(Base64String));
            TextEncoding::MSDos,
            TextEncoding::Windows:
                OutputString := Encoding.GetEncoding(CodePage).GetString(Convert.FromBase64String(Base64String));
            else
                OutputString := Encoding.UTF8().GetString(Convert.FromBase64String(Base64String));
        end;
        exit(OutputString);
    end;

    procedure FromBase64(Base64String: Text): Text
    begin
        exit(FromBase64(Base64String, TextEncoding::UTF8, 0));
    end;

    procedure FromBase64(Base64String: Text; OutStream: OutStream)
    var
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        ConvertedArray: DotNet Array;
    begin
        if Base64String <> '' then begin
            ConvertedArray := Convert.FromBase64String(Base64String);
            MemoryStream := MemoryStream.MemoryStream(ConvertedArray);
            MemoryStream.WriteTo(OutStream);
            MemoryStream.Close();
        end;
    end;

    [NonDebuggable]
    procedure FromBase64(Base64SecretString: SecretText): SecretText
    var
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
    begin
        if Base64SecretString.IsEmpty() then
            exit;
        exit(Encoding.UTF8().GetString(Convert.FromBase64String(Base64SecretString.Unwrap())));
    end;
}
