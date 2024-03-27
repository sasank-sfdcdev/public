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
 * Alon Waisman, 2/27/2023: Added support for fetching field labels and type (so they don't need to be added in the table config)
 * Alon Waisman, 3/27/2024: Simplified a few lines in fetchDataMap and removed 'Id' from the SOQL query to avoid an error when the user includes it in the provided list of fields
**/
public with sharing class datatableController {

    @AuraEnabled(Cacheable=true)
    public static Map<String, Map<String, String>> fieldInfo(String objectName, String[] fieldNames){
        try {
            Map<String, Map<String, String>> fieldInfoByAPIName = new Map<String, Map<String, String>>();

            Map<String, String> specialDatatableTypesByDisplayType = new Map<String, String>{
                'boolean'  => 'boolean',
                'currency' => 'currency',
                'date'     => 'date-local',
                'datetime' => 'date',
                'double'   => 'number',
                'email'    => 'email',
                'integer'  => 'number',
                'location' => 'location',
                'long'     => 'number',
                'percent'  => 'percent',
                'phone'    => 'phone',
                'time'     => 'date',
                'url'      => 'url'
            };

            Schema.SObjectType sobjectType = ((SObject)Type.forName('', objectName).newInstance()).getSObjectType();

            for (String fieldName : fieldNames) {
                Schema.DescribeFieldResult description = fieldDescription(sobjectType, fieldName);
                String datatableType = specialDatatableTypesByDisplayType.get(String.valueOf(description.getType()).toLowerCase());

                fieldInfoByAPIName.put(fieldName,
                    new Map<String, String>{'label' => description.getLabel(), 'type' => datatableType != null ? datatableType : 'string'}
                );
            }

            return fieldInfoByAPIName;
        }
         catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        private static Schema.DescribeFieldResult fieldDescription(Schema.SObjectType sobjectType, String fieldName) {
            Map<String, Schema.SObjectField> fieldsByName = sobjectType.getDescribe().fields.getMap();

            if (fieldName.contains('.')) {
                String relationship = fieldName.split('\\.')[0];
                fieldName = fieldName.removeStart(relationship + '.');
                relationship = relationship.endsWith('__r') ? relationship.replace('__r', '__c') : relationship + 'Id';
                Schema.SObjectType parentSobjectType = fieldsByName.get(relationship).getDescribe().getReferenceTo()[0];
                return fieldDescription(parentSobjectType, fieldName);
            } else {
                return fieldsByName.get(fieldName).getDescribe();
            }
        }


    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> fetchDataMapCached(Map<String, Object> params) {
        return fetchDataMap(params);
    }

    @AuraEnabled
    public static Map<String, Object> fetchDataMap(Map<String, Object> params) {
        String objectName     = (String)params.get('objectName');
        String fields         = (String)params.get('fields');
        String queryFilters   = (String)params.get('queryFilters');
        String sortBy         = (String)params.get('sortBy');
        String queryType      = (String)params.get('queryType');
        String soslSearchTerm = (String)params.get('soslSearchTerm');
        Boolean sortAsc       = (Boolean)params.get('sortAsc') ?? false;
        Integer limitRecords  = Integer.valueOf(params.get('limitRecords'));

        try{
            //Initial checks
            String limitRecordsStr = String.valueOf(Integer.valueOf(limitRecords));

            //Declare query string
            String query;

            //Query initialization for Soql and Sosl
            if(queryType == 'SOQL'){
                query = 'SELECT ' + fields + ' FROM ' + objectName;
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
