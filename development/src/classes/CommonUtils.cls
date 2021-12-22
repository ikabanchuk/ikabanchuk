public with sharing class CommonUtils {

    /**
     * Retrieves field picklist values.
     *
     * @param objApiName object name.
     * @param fieldName field name.
     *
     * @return returns list of values per label
     */
    @AuraEnabled
    public static List<Map<String, String>> getValuesPickList(String objApiName, String fieldName) {

        List<Map <String, String>> options = new List<Map<String, String>>();
        Map<String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickListValue : pickListValues) {
            Map<String, String> values = new Map<String, String>{
                    'label' => pickListValue.getLabel(),
                    'value' => pickListValue.getValue()
            };
            options.add(values);
        }
        return options;
    }

    /**
    * Retrieves label of the field.
    *
    * @param objApiName object name.
    * @param fieldName field name.
    *
    * @return returns label of the field
    */
    @AuraEnabled
    public static String getFieldLabel(String objApiName, String fieldName) {

        if (String.isBlank(objApiName) || String.isBlank(fieldName)) return null;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get(objApiName);
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
        String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();

        return fieldLabel;
    }

    /**
 * Dynamically retrieves all accessible fields and clones records.
 *
 * @param sObjects objects to clone.
 * @param objectType sObject type of the record to clone.
 *
 * @return return the cloned sObject collection.
 */
    public static List<sObject> cloneObjects(List<sObject> sObjects, Schema.SObjectType objectType) {

        List<Id> sObjectIds = new List<Id>{
        };
        List<String> sObjectFields = new List<String>{
        };
        List<sObject> clonedSObjects = new List<sObject>{
        };

        if (objectType != null) {
            sObjectFields.addAll(
                    objectType.getDescribe().fields.getMap().keySet());
        }

        if (sObjects != null && !sObjects.isEmpty() && !sObjectFields.isEmpty()) {
            for (sObject objectInstance : sObjects) {
                sObjectIds.add(objectInstance.Id);
            }

            String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);
            for (Integer i = 1; i < sObjectFields.size(); i++) {
                allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
            }
            allSObjectFieldsQuery += ' FROM ' + objectType.getDescribe().getName() +
                    ' WHERE ID IN (\'' + sObjectIds.get(0) +
                    '\'';
            for (Integer i = 1; i < sObjectIds.size(); i++) {
                allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
            }
            allSObjectFieldsQuery += ')';
            try {
                for (SObject sObjectFromDatabase : Database.query(allSObjectFieldsQuery)) {
                    clonedSObjects.add(sObjectFromDatabase.clone(false, true));
                }
            } catch (exception e) {

            }
        }
        // return the cloned sObject collection
        return clonedSObjects;
    }

    /**
     * Build path to redirect to view record in LEX
     *
     * @param objectName object to redirect.
     * @param recordId record id to redirect.
     * @param requestedMode view, edit mode to redirect.
     *
     * @return String as a link to redirect
     */
    public static String getLEXFRedirect(String objectName, String recordId, String requestedMode) {

        return '/lightning/r/' + objectName + '/' + recordId + '/' + requestedMode + '?0.source=alohaHeader';
    }

    /**
     * Get picklist values
     *
     * @param objectName object to retrieve picklist values.
     * @param fieldAPIName field API Name.
     *
     * @return Map of key value pairs.
     */
    public static Map<String, String> getPicklistValues(String objectAPIName, String fieldAPIName) {

        Map<String, String> pickListValuesMap = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectAPIName);
        Schema.DescribeSObjectResult descResult = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = descResult.fields.getMap().get(fieldAPIName).getDescribe();
        Boolean isFieldNotRequired = fieldResult.isNillable();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            if (isFieldNotRequired) {
                pickListValuesMap.put('--None--', '');
            }
            if (pickListVal.isActive()) {
                pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
        }
        return pickListValuesMap;
    }

    /**
     * Get picklist element if field values from string
     *
     * @param objectName object to retrieve string values.
     * @param fieldAPIName field API Name.
     *
     * @return Map of key value pairs.
     */
    public static Map<String, String> getPicklistValuesFromString(String objectAPIName, String fieldAPIName, String fieldAPILabelName) {

        Map<String, String> resultMap = new Map<String, String>();
        List<SObject> databaseFieldValues = new List<SObject>();
        if (String.isBlank(fieldAPILabelName) || fieldAPIName.contains(fieldAPILabelName)) {
            databaseFieldValues = Database.query('Select Id, ' + fieldAPIName + ' From ' + objectAPIName);
        } else {
            databaseFieldValues = Database.query('Select Id, ' + fieldAPIName + ', ' + fieldAPILabelName + ' From ' + objectAPIName);
        }
        for (Sobject field : databaseFieldValues) {
            if (String.isBlank(fieldAPILabelName)) {
                resultMap.put(String.valueOf(field.get(fieldAPIName)), String.valueOf(field.get(fieldAPIName)));
            } else {
                resultMap.put(String.valueOf(field.get(fieldAPILabelName)) + ' <' + String.valueOf(field.get(fieldAPIName)) + '>', String.valueOf(field.get(fieldAPIName)));
            }
        }
        return resultMap;
    }

    /**
     * Stores the blob content as a new file to the requested document content.
     *
     * @param content The blob content of the customSObject document to store.
     */
    public static Id storeFile(Blob content, SObject customSObject) {

        // first, a content version is created, this automatically creates a content document
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';// S means stored in Salesforce
        contentVersion.PathOnClient = null;//customSObject.Name + '.' + customSObject.Extension__c;
        contentVersion.Title = contentVersion.PathOnClient;
        contentVersion.VersionData = content;
        insert contentVersion;

        // second, get the id of the automatically created content document
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

        // third, create content document link in order to share the document with all other Salesforce users
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = null;//customSObject.Id;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;

        // the id of the content version is returned
        // as of the delete batch is working with content version ids
        return contentVersion.Id;
    }

    /**
     * Formats a date using the default date format.
     */
    public static String formatDate(Date d) {
        return formatDate(d, 'yyyy-MM-dd');
    }

    /**
     * Formats a date using Java SimpleDateFormat.
     */
    public static String formatDate(Date d, String format) {
        return Datetime.newInstance(d.year(), d.month(), d.day()).format(format);
    }

    /**
 * Helper function to map the English country names to ISO code.
 *
 * @param country The English country name.
 * @return The according ISO code.
 */
    public static String convertCountryToIsoCode(String country) {

        Map<String, String> isoCodes = new Map<String, String>{
                'Andorra' => 'AD',
                'Austria' => 'AT',
                'Belgium' => 'BE',
                'Czech Republic' => 'CZ',
                'England' => 'EN',
                'France' => 'FR',
                'Germany' => 'DE',
                'Italy' => 'IT',
                'Luxembourg' => 'LU',
                'Monaco' => 'MC',
                'Netherlands' => 'NL',
                'Poland' => 'PL',
                'Slovakia' => 'SK',
                'Spain' => 'ES',
                'United States' => 'US',
                'United Kingdom' => 'GB',
                'Malta' => 'MT',
                'Croatia' => 'HR',
                'San Marino' => 'SM'
        };

        return isoCodes.get(country);
    }


    /**
     * Helper function to map the Salesforce English language name to ISO codes
     *
     * @param language The English name of a language.
     * @param country The name of the country.
     *
     * @return The according ISO code.
     */
    public static String convertLanguageAndCountryToIsoCode(String language, String country) {

        Map<String, String> isoCodes = new Map<String, String>{
                'Dutch' => 'nl-NL',
                'English' => 'en-GB',
                'Flemish' => 'nl-BE',
                'French' => 'fr-FR',
                'German' => 'de-DE',
                'Italian' => 'it-IT',
                'Polish' => 'pl-PL',
                'Spanish' => 'es-ES',
                'Walloon' => 'fr-BE'
        };

        String returnValue = isoCodes.get(language);
        if (returnValue == 'de-DE' && country == 'Austria') {
            returnValue = 'de-AT';
        } else {
            if (returnValue == 'fr-BE' && country == 'Luxembourg') {
                returnValue = 'fr-LU';
            }
        }

        return returnValue;
    }

    /**
   * Verify whether or not a user has access to custom feature declaratively through profiles and permission sets
   *
   * @param customPermissionDeveloperName Developer Name name of a custom Permission.
   *
   * @return Tru if user has an access to the feature
   */
    public static Boolean getCustomPermissionAccess(String customPermissionDeveloperName) {

        Set <Id> permissionSetIds = new Set < Id >();
        List <User> userWithAccess = new List < User >();
        for (SetupEntityAccess access : [
                SELECT ParentId
                FROM SetupEntityAccess
                WHERE SetupEntityId IN (
                        SELECT Id
                        FROM CustomPermission
                        WHERE DeveloperName = :''
                )
        ]) {
            permissionSetIds.add(access.ParentId);
        }//label.OPPORTUNITY_EDITLOCKED_PERMISSION

        userWithAccess = [
                SELECT Username
                FROM User
                WHERE Id IN (
                        SELECT AssigneeId
                        FROM PermissionSetAssignment
                        WHERE PermissionSetId IN :permissionSetIds AND AssigneeId = :UserInfo.getUserId()
                )
        ];

        return userWithAccess.isEmpty() ? false : true;
    }

}