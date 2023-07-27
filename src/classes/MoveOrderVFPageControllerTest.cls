/**
 * Created by lanec on 01.06.2020.
 */
@IsTest
public with sharing class MoveOrderVFPageControllerTest {
    @TestSetup
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

    @IsTest
    static void testInit() {
        // Create an instance of the controller
        MoveOrderVFPageController controller = new MoveOrderVFPageController();
        controller.moveOrderId = [SELECT Id FROM Move_Order__c LIMIT 1].Id; // Get a valid Move_Order__c Id for testing

        // Call the init() method
        Test.startTest();
        PageReference result = controller.init();
        Test.stopTest();

        // Assert that the Move_Order__c and Move_Order_Item__c data is populated correctly in the controller
        System.assertNotEquals(null, controller.moveOrder);
        System.assertNotEquals(null, controller.itemsData);
        System.assertEquals(1, controller.itemsData.size()); // Assuming only one Move_Order_Item__c record is created in the setup
    }
}