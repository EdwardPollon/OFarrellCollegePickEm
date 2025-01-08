public class GoogleGeminiCallout {

    @AuraEnabled
    public static String callGoogleGemini(String prompt){

        String googleGeminiResponse = '';
        Http http = new Http();
    	HttpRequest req = new HttpRequest();
        // set endpoint URL using named credential and HTTP method
    	req.setEndpoint('callout:GoogleGemini' + '?key=' + 'AIzaSyA9mqS9fnrZ-hJzOuSBwp_DsrDiVdqG2fg');
        req.setHeader('Content-Type', 'application/json');
    	req.setMethod('POST');
        
        //set request body
        String requestBody = '{"contents":[{"parts":[{"text":"'+prompt+'"}]}]}';
        req.setBody(requestBody);
        
        //send the request and get the response
    	HTTPResponse res = http.send(req);
        
        System.debug('Response code: ' + res.getStatusCode());
        System.debug('Response message: ' + res.getStatus());
        if(res.getStatusCode() == 200){
            //success
            GoogleGeminiResponseWrapper obj = GoogleGeminiResponseWrapper.parse(res.getBody());
            for(GoogleGeminiResponseWrapper.cls_candidates candidate : obj.candidates){
                for( GoogleGeminiResponseWrapper.cls_parts part : candidate.content.parts){
                    googleGeminiResponse = part.text;
                    System.debug('Response from GoogleGemini: ' + part.text);
                    break;
                }
                break;
            }
        }
        return googleGeminiResponse;
    }
}