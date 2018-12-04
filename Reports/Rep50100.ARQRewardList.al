report 50100 "ARQReward List"
{
    UseRequestPage = true;
    RDLCLayout = 'ARQRewardList.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Reward List';
    DefaultLayout = RDLC;
    dataset
    {
        dataitem(DataItemName; Reward)
        {
            DataItemTableView = order(ascending);
            RequestFilterFields = "Reward ID";

            column(RewardID; "Reward ID")
            {
                IncludeCaption = true;
            }
            column(MinimumPurchase; "Minimum Purchase")
            {
                IncludeCaption = true;
            }
            column(Description; Description)
            {
                IncludeCaption = true;
            }
            column(DiscountPercentage; "Discount Percentage")
            {
                IncludeCaption = true;
            }

            trigger OnAfterGetRecord()
            var
            begin

            end;
        }
    }
}