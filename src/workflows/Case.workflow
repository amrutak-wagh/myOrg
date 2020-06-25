<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_All_Work_Orders_Approved</fullName>
        <description>Case: All Work Orders - Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_All_Work_Orders_have_been_Approved</template>
    </alerts>
    <alerts>
        <fullName>Case_Case_Closed_with_Approved_Notification</fullName>
        <ccEmails>vaibhavi.kulkarni@weare4c.com</ccEmails>
        <description>Case : Case Closed with Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Closure_with_Approved1</template>
    </alerts>
    <alerts>
        <fullName>Case_Provisional_Approval_Letter_Notification</fullName>
        <description>Case - Provisional Approval Letter Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Notify_Contact_Provisional_Approval</template>
    </alerts>
    <alerts>
        <fullName>Case_Termination_Notification_Account_Owner</fullName>
        <description>Case: Termination Notification Account Owner</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Contract_Termination_Acc_Owner</template>
    </alerts>
    <alerts>
        <fullName>Case_Termination_Notification_Customer</fullName>
        <description>Case: Termination Notification Customer</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Contract_Termination_Customer</template>
    </alerts>
    <alerts>
        <fullName>Lease_Termination_Case_Creation_Account_Owner_Notification</fullName>
        <ccEmails>vaibhavi.kulkarni@weare4c.com</ccEmails>
        <description>Lease Termination Case Creation Account Owner Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Termination_Case_Created_Account_Owner</template>
    </alerts>
    <alerts>
        <fullName>Lease_Termination_Case_Creation_Customer_Notification</fullName>
        <ccEmails>vaibhavi.kulkarni@weare4c.com</ccEmails>
        <description>Lease Termination Case Creation Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Termination_Case_Created_Customer</template>
    </alerts>
    <alerts>
        <fullName>Verify_Case_Status_Email_Alert</fullName>
        <description>Verify Case Status Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Verify_Case_Status</template>
    </alerts>
    <rules>
        <fullName>Send Mail To Contact On Case Creation</fullName>
        <actions>
            <name>Verify_Case_Status_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Encrypted_Contact_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
