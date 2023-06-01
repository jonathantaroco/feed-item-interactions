/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class ConversationController {

    @AuraEnabled(cacheable=true)
    public static List<Message> getCaseMessages(String caseId) {
        
        List<Message> messages = new List<Message>();
        
        // Get all email messages related to the case
        List<EmailMessage> emails = [SELECT Id, TextBody, FromAddress, FromName, ToAddress, Subject, CreatedDate, Incoming
                                     FROM EmailMessage
                                     WHERE ParentId = :caseId
                                     ORDER BY CreatedDate DESC];
        
        // Get all feed items related to the case
        List<FeedItem> feedItems = [SELECT Id, Body, CreatedBy.Name, CreatedDate, Type, RelatedRecordId , CreatedBy.Profile.Name
                                    FROM FeedItem
                                    WHERE ParentId = :caseId
                                    AND Type IN ('TextPost', 'ContentPost', 'LinkPost')
                                    ORDER BY CreatedDate DESC];
        
        // Merge email messages and feed items into a single list, sorted by created date
        messages.addAll(convertToMessages(emails));
        messages.addAll(convertToMessages(feedItems));
        messages.sort();
        return messages;
    }
    
    private static List<Message> convertToMessages(List<EmailMessage> emails) {
        List<Message> messages = new List<Message>();
        for (EmailMessage email : emails) {
            messages.add(new Message(email));
        }
        return messages;
    }
    
    private static List<Message> convertToMessages(List<FeedItem> feedItems) {
        List<Message> messages = new List<Message>();
        for (FeedItem feedItem : feedItems) {
            messages.add(new Message(feedItem));
        }
        return messages;
    }
    
    public class Message implements Comparable {
        @AuraEnabled
        public String body { get; private set; }
        @AuraEnabled
        public String createdByName { get; private set; }
        @AuraEnabled
        public String toAddress { get; private set; }
        @AuraEnabled
        public Datetime createdDate { get; private set; }
        @AuraEnabled
        public String type { get; private set; }
        @AuraEnabled
        public String relatedRecordName { get; private set; }
        @AuraEnabled
        public Id relatedRecordId { get; private set; }
        @AuraEnabled
        public Boolean isIncoming { get; private set; }
        @AuraEnabled
        public Boolean isOutboundEmail { get; private set; }
        @AuraEnabled
        public Boolean isEmail { get; private set; }
        @AuraEnabled
        public Boolean isTextPost { get; private set; }
        @AuraEnabled
        public String profile {get; private set;}
        @AuraEnabled
        public Id keyId {get; private set;}
        
        public Message(EmailMessage email) {
            this.body = email.TextBody;
            this.createdByName = email.FromName;
            this.toAddress = email.ToAddress;
            this.createdDate = email.CreatedDate;
            this.type = 'Email';
            this.relatedRecordName = email.Subject;
            this.relatedRecordId = email.Id;
            this.isIncoming = email.Incoming;
            this.isOutboundEmail = !email.Incoming;
            this.isEmail = true;
            this.isTextPost = false;
            this.keyId = email.Id;
        }
        
        public Message(FeedItem feedItem) {
            this.body = feedItem.Body;
            this.createdByName = feedItem.CreatedBy.Name;
            this.createdDate = feedItem.CreatedDate;
            this.type = 'Post';
            this.relatedRecordId = feedItem.RelatedRecordId;
            this.isIncoming = false;
            this.isOutboundEmail = false;
            this.isEmail = false;
            this.isTextPost = true;
            this.profile = feedItem.CreatedBy.Profile.Name;
            this.keyId = feedItem.Id;
            
            if(this.profile == 'Support Portal Client')
                this.isIncoming = true;
            else {
                this.isIncoming = false;
            }
        }

        public Integer compareTo(Object message) {
            Message msgInstance = (Message) message;
            
            if(this.createdDate < msgInstance.createdDate) {
                return 1;
            }

            if(this.createdDate == msgInstance.createdDate) {
                return 0;
            }

            return -1;
        }
    }
}