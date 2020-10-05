@isTest
private class Test_OppTrigger 
{
	static testMethod void testValidateOppStage()
    {
        Account acc = new Account(Name = 'test acc');
        insert acc;
        
        List<Contact> contacts = new List<Contact>();
        
        Contact c1 = new Contact(LastName = 'test1',AccountId = acc.Id);
        Contact c2 = new Contact(LastName = 'test2',AccountId = acc.Id);
        
        contacts.add(c1);
        contacts.add(c2);
        insert contacts;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp '+ datetime.now();
        opp.CloseDate = Date.today().addDays(5);
        Opp.StageName = 'Prospecting';
        insert opp;
        
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
        
        OpportunityContactRole cr1 = new OpportunityContactRole(ContactId = c1.id,OpportunityId = opp.id,Role = 'Business User');
        OpportunityContactRole cr2 = new OpportunityContactRole(ContactId = c2.id,OpportunityId = opp.id,Role = 'Decision Maker');
        
        oppContactRoles.add(cr1);
        oppContactRoles.add(cr2);
        insert oppContactRoles;
        
        try
        {
           opp.StageName = 'Closed Won';
           update opp;  
        }
        catch(Exception e)
        {
            String errMsg = e.getMessage();
            system.assert(errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
       
    }
}