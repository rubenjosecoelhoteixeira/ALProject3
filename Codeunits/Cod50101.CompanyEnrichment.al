codeunit 50101 "LAB CRS Company Enrichment"
{
    procedure EnrichCompanyData(var Cust: Record Customer)
    var
        Handled: Boolean;
    begin
        OnBeforeEnrichCompanyData(Cust, Handled);
        DoEnrichCompanyData(Cust, Handled);
        OnAfterEnrichCompanyData(Cust);
    end;

    local procedure DoEnrichCompanyData(var Cust: Record Customer; Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsNameAValidDomain(Cust.Name) then
            exit;
        if not ConfirmCompanyEnrichment(Cust.Name) then
            exit;

        InitCustomerRecord(Cust);
        PopulateCustomerWithFetchedData(Cust, FetchDataFromWebservice(cust.Name));
        SaveValuesInRecord(Cust);
    end;

    local procedure IsNameAValidDomain(DomainName: Text): Boolean
    var
        Domains: List of [Text];
        Domain: Text;
    begin

        GetDomainList(Domains);
        foreach Domain in Domains do
            if DomainName.EndsWith(Domain) then
                exit(true);
    end;

    local procedure GetDomainList(var Domains: List of [Text])
    begin
        with Domains do begin
            Add('.com');
            Add('.org');
            Add('.net');
            Add('.be');
            Add('.dk');
            Add('.de');
            Add('.nl');
            Add('.co.uk');
            Add('.no');
            Add('.pl');
            Add('.se');
        end;
    end;

    local procedure ConfirmCompanyEnrichment(DomainName: Text) ReturnValue: Boolean
    var
        ConfirmQst: Label 'Do you want to collect information about the company associated with %1?', Comment = '%1=Domain name';
    begin
        ReturnValue := Confirm(ConfirmQst, true, DomainName);
    end;

    local procedure FetchDataFromWebservice(DomainName: Text) ResponseJson: JsonObject
    var
        ContentJson: JsonObject;
        ContentText: Text;
        HttpContent: HttpContent;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        UrlLbl: Label 'https://api.fullcontact.com/v3/company.enrich', Locked = true;
        ApiKeyLbl: Label '09jK4s8pl2lJrpnbluWsiM3PZXeDNd0f', Locked = true;
        NoConnectionErr: Label 'Internet connection failure';
        ResponseErr: Label 'An error occurred\Status code: %1\Reason: %2';
    begin
        ContentJson.Add('domain', DomainName);
        ContentJson.WriteTo(ContentText);
        HttpContent.WriteFrom(ContentText);

        HttpClient.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Bearer %1', ApiKeyLbl));
        if not HttpClient.Post(UrlLbl, HttpContent, HttpResponseMessage) then
            error(NoConnectionErr);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(ResponseErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase());

        HttpResponseMessage.Content().ReadAs(ContentText);
        ResponseJson.ReadFrom(ContentText);
    end;

    local procedure InitCustomerRecord(var Cust: Record Customer)
    begin
        with Cust do begin
            "Home Page" := '';
            Address := '';
            City := '';
            "Post Code" := '';
            "Country/Region Code" := '';
        end;
    end;

    local procedure PopulateCustomerWithFetchedData(var Cust: Record Customer; ContentJson: JsonObject)
    var
        LocationsJson: JsonArray;
        LocationJson: JsonObject;
        JsonToken: JsonToken;
    begin
        with Cust do begin
            if ContentJson.Get('name', JsonToken) then
                Name := CopyStr(JsonToken.AsValue().AsText(), 1, 50);
            if ContentJson.Get('website', JsonToken) then
                "Home Page" := CopyStr(JsonToken.AsValue().AsText(), 1, 80);
            if ContentJson.SelectToken('$.details.locations', JsonToken) then begin
                LocationsJson := JsonToken.AsArray();
                if LocationsJson.Get(0, JsonToken) then begin
                    LocationJson := JsonToken.AsObject();
                    if LocationJson.Get('addressLine1', JsonToken) then
                        Address := CopyStr(JsonToken.AsValue().AsText(), 1, 50);
                    if LocationJson.Get('city', JsonToken) then
                        City := CopyStr(JsonToken.AsValue().AsText(), 1, 30);
                    if LocationJson.Get('postalCode', JsonToken) then
                        "Post Code" := CopyStr(JsonToken.AsValue().AsText(), 1, 20);
                    if LocationJson.Get('countryCode', JsonToken) then
                        "Country/Region Code" := CopyStr(JsonToken.AsValue().AsText(), 1, 10);
                end;
            end;
        end;
    end;

    local procedure SaveValuesInRecord(var Cust: Record Customer)
    begin
        Cust.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEnrichCompanyData(var Cust: Record Customer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEnrichCompanyData(var Cust: Record Customer)
    begin
    end;
}