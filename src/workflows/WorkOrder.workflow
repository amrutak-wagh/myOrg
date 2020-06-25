<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Work_Orders_Approved_Notifications</fullName>
        <ccEmails>vaibhavi.kulkarni@weare4c.com</ccEmails>
        <description>Work Orders Approved Notifications</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Work_Orders_Approved</template>
    </alerts>
    <rules>
        <fullName>Work Orders Approved</fullName>
        <actions>
            <name>Work_Orders_Approved_Notifications</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Security Inspection</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
