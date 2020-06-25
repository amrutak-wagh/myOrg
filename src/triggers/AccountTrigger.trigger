trigger AccountTrigger on Account (after insert, after update) {
    if(trigger.isAfter)
    {
        if(trigger.isinsert)
        {
            AccountIntegrationUtil.sendAccountsToOracle(trigger.new);
        }
        if(trigger.isupdate)
        {
            AccountIntegrationUtil.updateContactStatusYardiIntegration(trigger.new, trigger.oldMap);
            AccountIntegrationUtil.updateContactStatusOracleIntegration(trigger.new, trigger.oldMap);
            
        }
        
    }

}