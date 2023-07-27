/**
    CREATED BY: Eugene Lanets on 04/11/2023.
    AT REQUEST OF: FHP_Partial
    DESCRIPTION:
    
    Maintenance History:
    - Date         - Name              - Version   - Remarks
    - 04/11/2023   - Eugene Lanets     - 1.0       - APEX class created
*/
@IsTest
private class el_MoveOrderPDFTest {
    @testSetup
    static void setup() {
        Id standardPricebook = Test.getStandardPricebookId();

        Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                isActive = true
        );
        insert prod;

        PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
        );
        insert pbEntry;


        Warehouse__c warehouse = new Warehouse__c(Warehouse_Name__c = 'TestWarehouse');
        insert warehouse;

        Serial_Number__c serialNumber = new Serial_Number__c(Name = '123', Product__c = prod.Id, Warehouse__c = warehouse.Id, Active__c = true);
        insert serialNumber;
        Serial_Number__c serialNumber1 = new Serial_Number__c(Name = '456', Product__c = prod.Id, Warehouse__c = warehouse.Id, Active__c = true);
        insert serialNumber1;

        Account acc = new Account(Name = 'Test Account', ShippingStateCode = 'HI');
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Proposal';
        opp.closeDate = Date.today();
        opp.Shipping_State__c = 'NY';
        insert opp;

        OpportunityLineItem item = new OpportunityLineItem();
        item.PricebookEntryId = pbEntry.Id;
        item.OpportunityId = opp.Id;
        item.UnitPrice = 100;
        item.Quantity = 1;
        item.Serial_Number__c = serialNumber.Id;
        item.Warehouse__c = warehouse.Id;
        insert item;

        Move_Order__c mo = new Move_Order__c(Name = 'Test Move Order');
        insert mo;
        Move_Order_Item__c moi = new Move_Order_Item__c(Move_Order__c = mo.Id, Product__c = prod.Id, Qty__c = 2);
        insert moi;
    }

    @isTest
    static void testPreviewPDF() {
        // Get the test data
        Move_Order__c moveOrder = [SELECT Id FROM Move_Order__c LIMIT 1];

        // Call the previewPDF method
        Test.startTest();
        String previewId = el_MoveOrderPDF.previewPDF(moveOrder.Id);
        Test.stopTest();

        // Assert that the previewId is not empty
        System.assertNotEquals('', previewId);

        // Clean up the test data
        el_MoveOrderPDF.deletePreview(previewId);
    }

    @isTest
    static void testSavePDF() {
        // Get the test data
        Move_Order__c moveOrder = [SELECT Id FROM Move_Order__c LIMIT 1];

        // Call the savePDF method
        Test.startTest();
        String pdfTitle = el_MoveOrderPDF.savePDF(moveOrder.Id);
        Test.stopTest();

        // Assert that the pdfTitle is not empty
        System.assertNotEquals('', pdfTitle);

        // Clean up the test data
        delete [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :moveOrder.Id];
    }

    @IsTest
    static void getRecordTest(){
        Move_Order__c moveOrder = [SELECT Id FROM Move_Order__c LIMIT 1];
        Move_Order__c moveOrder2 = el_MoveOrderPDF.getRecord(moveOrder.Id);
        System.assertNotEquals(null, moveOrder2);
    }
}