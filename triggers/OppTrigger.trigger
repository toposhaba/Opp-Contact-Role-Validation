trigger OppTrigger on Opportunity (before insert,before update) 
{
    if(OppTriggerHandler.executeTrigger)
    {
        if(Trigger.isBefore && !FeatureManagement.checkPermission('Bypass_Opp_Contact_Req'))
        {
            OppTriggerHandler.validateOppStage(Trigger.new,Trigger.oldMap);
        }
    } 
}