/**
 * @File Name          : datatableController.cls
 * @Description        : 
 * @Author             : Sasank Subrahmanyam V
 * @Group              : 
 * @Last Modified By   : Sasank Subrahmanyam V
 * @Last Modified On   : 8/4/2019, 10:17:06 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/1/2019, 1:50:15 PM   Sasank Subrahmanyam V     Initial Version
**/
public with sharing class datatableController {

    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> fetchDataMapCached(Map<String, Object> params) {
        return fetchDataMap(params);
    }

    @AuraEnabled
    public static Map<String, Object> fetchDataMap(Map<String, Object> params) {

        String objectName = params.containsKey('objectName') ? (String)params.get('objectName') : null;
        String fields = params.containsKey('fields') ? (String)params.get('fields') : null;
        String queryFilters = params.containsKey('queryFilters') ? (String)params.get('queryFilters') : null;
        String sortBy = params.containsKey('sortBy') ? (String)params.get('sortBy') : null;
        String queryType = params.containsKey('queryType') ? (String)params.get('queryType') : null;
        String soslSearchTerm = params.containsKey('soslSearchTerm') ? (String)params.get('soslSearchTerm') : null;
        Boolean sortAsc = params.containsKey('sortAsc') ? (Boolean)params.get('sortAsc') : false;
        Integer limitRecords = params.containsKey('limitRecords') ? Integer.valueOf(params.get('limitRecords')) : null;
        
        try{
            //Initial checks
            String limitRecordsStr = String.valueOf(Integer.valueOf(limitRecords));
            
            //Declare query string
            String query;
            
            //Query initialization for Soql and Sosl
            if(queryType == 'SOQL'){
                query = 'SELECT Id, ' + fields + ' FROM ' + objectName;
            }
            else if(queryType == 'SOSL') {
                query = 'Id, ' + fields;
            }

            //Adding filters
            if(String.isNotBlank(queryFilters)){
                query += ' WHERE ' + queryFilters;
            }
            
            //Adding order by and limit records
            if(String.isNotBlank(sortBy) && queryType == 'SOQL'){
                query += ' ORDER BY ' + sortBy + (sortAsc?' ASC ':' DESC ');
            }
            
            if(String.isNotBlank(limitRecordsStr)) {
                query += ' LIMIT ' + limitRecordsStr;
            }
            
            //Log the query before getting query results from database
            Map<String, Object> returnMap = new Map<String, Object>();
            List<sObject> sObjectsList = new List<sObject>();
            if(queryType == 'SOQL'){
                system.debug('query => '+query);
                sObjectsList = Database.query(query);
            }
            else if(queryType == 'SOSL') {
                query = 'FIND \'' + String.escapeSingleQuotes(soslSearchTerm) + '\' IN ALL FIELDS RETURNING ' + objectName + '(' + query + ')';
                system.debug('query => '+query);
                sObjectsList = Search.query(query)[0];
            }

            returnMap.put('records', sObjectsList);
            
            //Log the result
            system.debug('returnMap => '+returnMap);
            
            return returnMap;     
        }
        catch(Exception ex) {
            system.debug('Error => '+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }   
    }

}