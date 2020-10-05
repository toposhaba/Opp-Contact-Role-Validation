/**
  * @author David Evans
  * @date 10/02/2020
 *  @description Opportunity Trigger Helper class
 */

public without sharing class OppTriggerHandler 
{
    public static Boolean executeTrigger = true;
    
    /**
	 * @description To check required contact roles on opportunity before moving it to a specific stage
	 * @param List<Opportunity> newList
	 * @param Map<Id,Opportunity> oldMap
	 * @return 
	*/
	public static void validateOppStage(List<Opportunity> newList,Map<Id,Opportunity> oldMap)
    {
       Set<Id> oppIds = new Set<Id>();
        
       //fetch opp stage and contact role mappings
       Map<String,List<String>> mappings = getOppStageContactMapping();
        
       for(Opportunity opp : newList)
       {
           oppIds.add(opp.Id);
       }
        
       //fetch opp contact roles mapping
       Map<Id,Set<String>> oppRoleMap = getOppContactRoles(oppIds);
        
       for(Opportunity opp : newList)
       {
           String oppStage = opp.StageName;
           String oppOldStage = opp.Id !=null && oldMap.containsKey(opp.Id) ? oldMap.get(opp.Id).StageName : null;
           
           if(oppStage != oppOldStage && mappings.containsKey(oppStage))
           {
               //get list of contact roles to be present for opp stage
               List<String> requiredRoles = mappings.get(oppStage);
               
               if(oppRoleMap.containsKey(opp.Id))
               {
                   for(String role : requiredRoles)
                   {
                       if(!oppRoleMap.get(opp.Id).contains(role))
                       {
                           opp.StageName.addError('Following Contact Role records should be present before moving opportunity to '+oppStage + ' stage. ' + String.join(requiredRoles,','));
                       }
                   }
               }
               else
               {
                   opp.StageName.addError('Following Contact Role records should be present before moving opportunity to '+oppStage + ' stage. ' + String.join(requiredRoles,','));
               }
           }
       }
       
    }
    
    /**
	 * @description Get opp stage and corresponding contact roles mapping
	 * @param
	 * @return Map<String,List<String>>
	 * @example 
	*/
    public static Map<String,List<String>> getOppStageContactMapping()
    {
        Map<String,List<String>> mappings = new Map<String,List<String>>();
        
        for(Opp_Stage_Contact_Role_Mapping__mdt config : [SELECT Opp_Stage__c,Contact_Roles__c FROM Opp_Stage_Contact_Role_Mapping__mdt])
        {
            mappings.put(config.Opp_Stage__c,config.Contact_Roles__c.split(','));
        }
        
        return mappings; 
    }
    
    /**
	 * @description Get contact roles by opportunity
	 * @param Set<Id> oppIds
	 * @return Map<Id,Set<String>> Map of opp Id and associated roles
	 * @example 
	*/
    public static Map<Id,Set<String>> getOppContactRoles(Set<Id> oppIds)
    {
        Map<Id,Set<String>> oppRoleMap = new Map<Id,Set<String>>();
        
        for(OpportunityContactRole contactRole : [SELECT OpportunityId,Role FROM OpportunityContactRole WHERE OpportunityId IN:oppIds])
        {
            if(oppRoleMap.containsKey(contactRole.OpportunityId))
            {
                oppRoleMap.get(contactRole.OpportunityId).add(contactRole.Role);
            }
            else
            {
                oppRoleMap.put(contactRole.OpportunityId,new Set<String>{contactRole.Role}); 
            }
        }
        
        return oppRoleMap;
    }
}