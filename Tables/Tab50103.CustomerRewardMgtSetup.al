table 50103 "Customer Rewards Mgt. Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }

        field(2; "Customer Rewards Ext.Mgt. C_ID"; Integer)
        {
            Caption = 'Customer Rewards Ext. Mgt. Codeunit ID';
            TableRelation = "CodeUnit Metadata".ID;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}