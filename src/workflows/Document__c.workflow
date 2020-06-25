<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Customer_DDA_Name_Reservation_Certificate_Alert_Alert</fullName>
        <description>Case: Customer DDA Name Reservation Certificate Alert Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_DDA_Name_Reservation_Certification_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Contact_of_new_Document</fullName>
        <description>Notify Contact of new Document</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Document_Created</template>
    </alerts>
    <rules>
        <fullName>Notify Document Owner - Approved</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Document__c.Document_Status__c</field>
            <operation>equals</operation>
            <value>Accepted</value>
        </criteriaItems>
        <description>Update the Document Owner when the record has been approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
