public class poc {
    
    
    @AuraEnabled(Cacheable = true)
    public static String getAccountName(String accId) {
        Set<Id> accIds = new Map<Id,Account>([SELECT Id, Name FROM Account LIMIT 10000]).keySet();
        System.debug('accIds => '+accIds);
        return 'Hello World';
    }
    
    public static void met1(List<Id> ids, Map<Id,List<Contact>> accMap){
        List<Account> accs = [SELECT Id, Name, (SELECT Name FROM Contacts) FROM Account];
        for(Account acc: accs) {
            accMap.put(acc.Id, acc.Contacts);
        }
    }
 
    public static void met2(Map<Id,List<Contact>> accMap){
        System.debug('contacts map => '+accMap);
    }
    
    static List<Id> ids = new List<Id>();
    Set<String> hmPhones = new Set<String>();
    
    public Set<String> check(String searchKey) {
        hmPhones.add('19645372835');
        hmPhones.add('19645372545');
        hmPhones.add('19645456835');
        List<List<SObject>> searchResults = [FIND :searchKey IN ALL FIELDS RETURNING 
                                             Account(Name),
                                             Contact(Name)];
        
        //hmPhones is a set already having some values before this operation
        
        Set<String> targetPhones = new Set<String>();
        Account[] msgs = searchResults[0].clone();
        Contact[] contacts = searchResults[1].clone();
        for(Account msg : msgs)
            targetPhones.add(String.valueOf(msg.Name));
        for(Contact con : contacts)
            targetPhones.add(String.valueOf(con.Name));                                        
        hmPhones.addAll(targetPhones);
        return hmPhones;
    } 
    
    public String calledFrom{get;set;}
    public void calledFromButton(){
        calledFrom = 'button';
        mainMethod();
    }
    
    public void invokedFromLink(){
        calledFrom = 'link';
        mainMethod();
    }
    
    public void mainMethod(){
        // main logic
    }
    
    @AuraEnabled
    public static List<Account> getProduct2(List<String> Ids) {
        
        
        Set<String> filterIds = new Set<String>(Ids);
        
        system.debug('productsetids' + Ids);
        List<Account> products = [SELECT Id, Name FROM Account WHERE Id =:filterIds];
        
        System.debug('returnedproducts' + products );
        return products;
    }
}