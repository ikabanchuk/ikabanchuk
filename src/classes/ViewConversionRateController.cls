public without sharing class ViewConversionRateController {

    @AuraEnabled
    public static List<String> getConversionRate(String opportunityId, String baseCode, String opportunityCurrency) {

        //validate method input
        if (String.isEmpty(baseCode) || String.isEmpty(opportunityCurrency)) return new List<String>{
                'error', 'Please, validate currency set up on the opportunity.'
        };

        try {
            Decimal convertedAmount;
            Decimal opportunityAmount = [SELECT Id, Amount FROM Opportunity WHERE Id = :opportunityId LIMIT 1].Amount;
            Map<String, Object> exchangeRates = getExchangeRates();
            Object opportunityCurrencyRate = exchangeRates.get(opportunityCurrency);
            convertedAmount = (opportunityAmount / (Decimal) opportunityCurrencyRate);
            return new List<String>{
                    'success', String.valueOf(opportunityCurrencyRate), String.valueOf(convertedAmount.setScale(2))
            };
        } catch (Exception ex) {
            system.debug(LoggingLevel.error, '--- error: ' + + ex.getLineNumber() + ex.getMessage());
            return new List<String>{
                    'error', 'Server error: ' + ex.getLineNumber() + ex.getMessage()
            };
        }
    }

    private static Map<String, Object> getExchangeRates() {

        Map<String, Object> exchangeRates = new Map<String, Object>();
        String accessKey = RemoteAccessUtils__c.getInstance().ConversionRateAccessKey__c;
        String requestUrl = RemoteAccessUtils__c.getInstance().ConversionRateRequestURL__c + accessKey;// + '&base=' + baseCode + '&symbols=' + opportunityCurrencyRate;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestUrl);
        request.setMethod('GET');
        HttpResponse res = http.send(request);
        Map<String, Object> exchangeRateDetails = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        exchangeRates = (Map<String, Object>) exchangeRateDetails.get('rates');
        return exchangeRates;
    }
}