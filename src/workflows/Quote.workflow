<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Quote_210_days</fullName>
        <ccEmails>amruta.kumbhakarn@theblueflamelabs.com</ccEmails>
        <description>Notify Quote : 210 days</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_Renewal_Quote_210_days</template>
    </alerts>
    <alerts>
        <fullName>Notify_Quote_60_days</fullName>
        <ccEmails>amruta.kumbhakarn@theblueflamelabs.com</ccEmails>
        <description>Notify Quote : 60 days</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_Renewal_Quote_60_days</template>
    </alerts>
    <alerts>
        <fullName>Notify_Quote_95_days</fullName>
        <ccEmails>amruta.kumbhakarn@theblueflamelabs.com</ccEmails>
        <description>Notify Quote : 95 days</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_Renewal_Quote_95_days</template>
    </alerts>
    <alerts>
        <fullName>Notify_Quote_renewal_after_30_days</fullName>
        <description>Notify Quote renewal after 30 days</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_Renewal_Quote_30_days</template>
    </alerts>
    <alerts>
        <fullName>Proposal_Rejected</fullName>
        <description>Proposal Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Rejection_Notification</template>
    </alerts>
    <alerts>
        <fullName>Quote_Cancelled_Quotes</fullName>
        <description>Quote: Cancelled Quotes</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Cancelled_Quotes</template>
    </alerts>
    <alerts>
        <fullName>Quote_Quote_Accepted</fullName>
        <description>Quote: Quote Accepted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Quote_Accepted</template>
    </alerts>
    <alerts>
        <fullName>Quote_Quote_Approved</fullName>
        <description>Quote: Quote Approved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Quote_Approved</template>
    </alerts>
    <alerts>
        <fullName>Quote_Rejection_Notification</fullName>
        <ccEmails>Anshul.Garg@weare4c.com</ccEmails>
        <description>Quote: Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Rejection_Notification</template>
    </alerts>
    <alerts>
        <fullName>Quote_SoftBooking_Expires</fullName>
        <ccEmails>amruta.kumbhakarn@theblueflamelabs.com</ccEmails>
        <description>Quote : SoftBooking Expires</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_SoftBooking_Expires</template>
    </alerts>
    <alerts>
        <fullName>Quote_Soft_Booking_Extension_Approved</fullName>
        <description>Quote - Soft Booking Extension - Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Soft_Book_Ext_Approved</template>
    </alerts>
    <alerts>
        <fullName>Quote_Soft_Booking_Extension_Rejected</fullName>
        <description>Quote - Soft Booking Extension - Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Soft_Book_Ext_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Owner_of_the_Approval</fullName>
        <ccEmails>Anshul.Garg@weare4c.com</ccEmails>
        <description>Send Email to Owner of the Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Quote_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Manually_Submitted</fullName>
        <field>Manually_submitted__c</field>
        <literalValue>1</literalValue>
        <name>Manually Submitted?</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pre_Approval_Allowed</fullName>
        <field>Pre_Approval_Allowed__c</field>
        <literalValue>1</literalValue>
        <name>Pre Approval Allowed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Approved_Via_Approval_Process</fullName>
        <field>Quote_Approved_Via_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Quote Approved Via Approval Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Rejected_Checkbox</fullName>
        <field>Quote_Rejected_Via_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Quote Rejected Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Update_Status_To_Under_Review</fullName>
        <field>Status</field>
        <literalValue>Under Approval</literalValue>
        <name>Quote-Update Status To Under Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Pre_Approval_Flag</fullName>
        <field>Pre_Approval_Allowed__c</field>
        <literalValue>0</literalValue>
        <name>Reset Pre Approval Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Quote_Approved_Checkbox</fullName>
        <field>Quote_Approved_Via_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Quote Approved Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Quote_Rejected_Checkbox</fullName>
        <field>Quote_Rejected_Via_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Quote Rejected Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Soft_Booking_Extension_checkbox</fullName>
        <field>Soft_Booking_Extension_Submitted__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Soft Booking Extension checkbox.</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Submitted_Checkbox</fullName>
        <field>Manually_submitted__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Submitted Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Booking_Expiry_Date</fullName>
        <description>Updates the soft booking expiry date to +15 after approval from the manager.</description>
        <field>Booking_expiry_Date__c</field>
        <formula>Booking_expiry_Date__c +15</formula>
        <name>Update Booking Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Record_Type_on_Approval</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Approved_Quote</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Quote Record Type on Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Status_Synched</fullName>
        <field>Status</field>
        <literalValue>Synched</literalValue>
        <name>Update Quote Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Status_Upon_Approval</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Update Quote Status Upon Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Status_Upon_Rejection</fullName>
        <field>Status</field>
        <literalValue>Rejected</literalValue>
        <name>Update Quote Status Upon Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Status_upon_Submission</fullName>
        <field>Status</field>
        <literalValue>Under Approval</literalValue>
        <name>Update Quote Status upon Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Draft</fullName>
        <description>Changes the record type to Draft after previously being approved and locked.</description>
        <field>RecordTypeId</field>
        <lookupValue>New_Quote</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Draft</fullName>
        <field>Status</field>
        <literalValue>Draft</literalValue>
        <name>Update Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Under_Approval</fullName>
        <field>Status</field>
        <literalValue>Under Approval</literalValue>
        <name>Update Status Under Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Draft</fullName>
        <field>Status</field>
        <literalValue>Draft</literalValue>
        <name>Update Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_integration_status</fullName>
        <field>Integration_Status__c</field>
        <literalValue>Ready To Sync</literalValue>
        <name>Update integration status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_quote_status</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Update quote status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_rejected_status</fullName>
        <field>Status</field>
        <literalValue>Rejected</literalValue>
        <name>Update rejected status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_soft_booking</fullName>
        <field>Soft_Book__c</field>
        <literalValue>1</literalValue>
        <name>Update soft booking</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>change_booking_expiry_date</fullName>
        <field>Booking_expiry_Date__c</field>
        <name>change booking expiry date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify Renewal Quote Creation</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Type__c</field>
            <operation>equals</operation>
            <value>Renewal</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Quote_60_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Quote.CreatedDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Quote_95_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Quote.CreatedDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Quote Record Type Update</fullName>
        <actions>
            <name>Uncheck_Quote_Approved_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Uncheck_Quote_Rejected_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Uncheck_Submitted_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Record_Type_to_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the record type to New Quote if the status is changed to Draft. This also removes the flag for approved checkbox used for validations.</description>
        <formula>ISPICKVAL((Status),&quot;Draft&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Renewal Quote Creation</fullName>
        <actions>
            <name>Notify_Quote_renewal_after_30_days</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Type__c</field>
            <operation>equals</operation>
            <value>Renewal</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Quote.CreatedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
