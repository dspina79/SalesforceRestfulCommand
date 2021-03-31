@RestResource(urlMapping='/CommandCenter/*')
global with sharing class RESTCommandCenter implements Callable {
    /**
     * List of Commands with their function endpoints
     */

    private static Map<String, String> commandListing = new Map<String, String> {
        'dailyAcctUpdate' => 'Performs daily updates of new accounts.',
        'clearInactives' => 'Deletes inactive accounts',
        'openOpps' => 'Retrieves open opportunities.'
    };


    
    @HttpPost
    global static void runCommand() {
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        String command = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        Map<String, Object> results = execute(command);
        resp.statusCode = Integer.valueOf(results.get('StatusCode'));
        resp.responseBody = Blob.valueOf(String.valueOf(results.get('Body')));
    }

    public static Map<String, Object> execute(String command) {
        Map<String, Object> result = new Map<String, Object> {
            'StatusCode' => 500,
            'Body' => ''
        };

        try {
            String methodDescription = commandListing.get(command);
            if (methodDescription == null) {
                throw new RESTCommandCenterException('Command not found.');
            }

            Callable instance = (Callable) Type.forName('RESTCommandCenter').newInstance();
            String instanceResult = (String) instance.call(command, null);

            result.put('StatusCode', 200);
            result.put('Body', instanceResult);

        } catch(Exception ex) {
            result.put('StatusCode', 500);
            result.put('Body', 'Error: ' + ex.getMessage());
        }

        return result;
    }

    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'dailyAcctUpdate' {
                return AccountUpdater.updateRecentAccounts();
            }
            when 'clearInactives' {
                return AccountUpdater.deleteInactiveAccounts();
            }
            when 'openOpps' {
                Integer opens = OpportunityQuery.getOpenOpportunities();
                return 'Open Opportunities: ' + opens; 
            }
            when else  {
                throw new RESTCommandCenterException('Command provides was not callable.');
            }
        }

    }

    public class RESTCommandCenterException extends Exception {

    }
}
