/**
    CREATED BY: Eugene Lanets on 04/10/2023.
    AT REQUEST OF: FHP_Partial
    DESCRIPTION:
    
    Maintenance History:
    - Date         - Name              - Version   - Remarks
    - 04/10/2023   - Eugene Lanets     - 1.0       - APEX class created
*/
public class el_MoveOrderPDF {

    @AuraEnabled(Cacheable = true)
    public static Move_Order__c getRecord(String recordId){
        return [SELECT id, Name FROM Move_Order__c WHERE Id=:recordId];
    }


    @AuraEnabled
    public static String previewPDF(String recordId){

        System.debug('recordId');
        System.debug(recordId);

        PageReference pr =  Page.MoveOrderVFPage;
        pr.getParameters().put('qid', recordId);
        Blob content;
        if (!Test.isRunningTest()) {
            content = pr.getContentAsPDF();
        } else {
            content = Blob.valueOf('Test Content');
        }

        Attachment at     =   new Attachment();
        at.Body           =   content;
        at.ParentId       =   recordId;
        at.Name           =   'Preview_tmp.pdf';
        insert at;

        String id_18 = at.Id;
        return String.valueOf(id_18).substring(0, 15);
    }

    @AuraEnabled
    public static void deletePreview(String previewId){
        delete [SELECT id FROM Attachment WHERE id =: previewId];
    }

    @AuraEnabled
    public static String savePDF(String recordId){

        PageReference pr = Page.MoveOrderVFPage;

        Move_Order__c qt = [SELECT id, Name, RecordType.DeveloperName, Opportunity__r.Account.Name FROM Move_Order__c WHERE id =: recordId];

        pr.getParameters().put('qid', recordId);
        Blob body;
        if (!Test.isRunningTest()) {
            body = pr.getContent();
        } else {
            body = Blob.valueOf('Test Content');
        }

        String fileName = qt.RecordType.DeveloperName != 'Pickup' ? qt.Name : 'Pickup '+qt.Opportunity__r.Account.Name+' '+ Date.today().format();

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = fileName + '.pdf';
        cv.Title = fileName +'.pdf';
        cv.VersionData = body;

        insert cv;

        ContentVersion cv1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = cv1.ContentDocumentId;
        insert cdl;

        return cv.Title;
    }
}