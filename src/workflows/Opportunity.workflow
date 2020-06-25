<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Opportunity_Expire_120_days_left</fullName>
        <ccEmails>amruta.kumbhakarn@theblueflamelabs.com</ccEmails>
        <description>Opportunity Expire : 120 days left</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_Contract_120_days_Before_Opp_Expiry</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Amount_from_Synced_Quote</fullName>
        <field>Amount__c</field>
        <formula>SyncedQuote.Total_Quote_Amount__c</formula>
        <name>Update Amount from Synced Quote</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Is_renewal</fullName>
        <field>Is_renewal__c</field>
        <literalValue>1</literalValue>
        <name>Update Is renewal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Is_renewal_Opportunity</fullName>
        <field>Is_renewal__c</field>
        <literalValue>1</literalValue>
        <name>Update Is renewal Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Opportinity %3A Expiry Alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Opportunity_Expire_120_days_left</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Lease_End_Date__c</offsetFromField>
            <timeLength>-120</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Opportunity Expiry Alert</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Opportunity_Expire_120_days_left</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Lease_End_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Amount From Synced Quote</fullName>
        <actions>
            <name>Update_Amount_from_Synced_Quote</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(SyncedQuoteId)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Is renewal if Parent opportunity is blank</fullName>
        <actions>
            <name>Update_Is_renewal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(NOT(ISBLANK(Lease_End_Date__c)), Is_renewal__c = false,  ISPICKVAL(StageName, &apos;Active&apos;), OR(ISCHANGED(Lease_End_Date__c), ISCHANGED(StageName)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
