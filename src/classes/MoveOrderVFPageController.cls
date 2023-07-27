/**
 * Created by lanec on 29.05.2020.
 */

public with sharing class MoveOrderVFPageController {
    public Move_Order__c moveOrder {get;set;}
    public Datetime generationDatetime {get;set;}
    public Date todaysDate {get;set;}
    public Id moveOrderId {get;set;}
    public List<ItemsWrapper> itemsData {get;set;}
    public String header {get;set;}

    public MoveOrderVFPageController (){
        todaysDate = Date.today();
        generationDatetime = Datetime.now();
        moveOrderId = (Id)ApexPages.CurrentPage().getParameters().get('qid');
        itemsData = new List<ItemsWrapper>();
        header = 'Piano Moving Work Order';
    }

    public Move_Order__c getMoveOrder() {
        return moveOrder;
    }

    public PageReference init(){
        moveOrder = [SELECT Id, RecordType.Name, Name, Ordered_By1__c, Salesperson__c,
                Order_Date__c, Moving_Company__c, Requested_Pickup_Date__c,
                Requested_Delivery_Date__c, Bench_Type__c, Accessories__c, Move_From_Phone__c, Move_To_Phone__c, 
                Steps_at_Pickup__c,   Steps_at_Delivery__c, Trade_in_Piano__c, What_to_do_w_piano_picked_up__c, Target_Delivery__c,
                Special_Instructions__c, Opportunity__r.Binder__c, Opportunity__r.QB_Class__c, Moving_Company__r.Name, Piano_to_Pick_up__c, COD__c,
                From_Address_Formula__c, To_Address_Formula__c, Do_Not_Unbox__c, Move_Order_Header__c, Update_Move_Order__c, COD_Amount__c,
                BillTo__c, New_Move_From_Phone__c, Shipping_PhoneNumber__c, Delivery_Contact_Phone__c, Mover_Terms__c
        FROM Move_Order__c WHERE Id = :moveOrderId];

        if(moveOrder.Move_Order_Header__c != null && moveOrder.Update_Move_Order__c == true){
            header += ' - Updated '+ moveOrder.Move_Order_Header__c;
        }

        List<Move_Order_Item__c> items = [SELECT id, Product_Name__c, Product__r.Name, Serial_Number__r.Name, Serial_Number_text__c, Qty__c, RecordType.DeveloperName FROM Move_Order_Item__c WHERE Move_Order__c =: moveOrderId];

        for(Move_Order_Item__c itm : items){
            itemsData.add(new ItemsWrapper(itm));
        }

        return null;
    }

    public class ItemsWrapper {
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public String serialNumber {get;set;}

        public ItemsWrapper(Move_Order_Item__c item){
            this.quantity = item.Qty__c;
            if(item.RecordType.DeveloperName == 'Pickup_Item'){
                this.productName = item.Product_Name__c;
                this.serialNumber = item.Serial_Number_text__c;
            }else {
                this.productName = item.Product__r.Name;
                this.serialNumber = item.Serial_Number__r.Name;
            }
        }
    }
    public void saveAttachment() {
    }
}