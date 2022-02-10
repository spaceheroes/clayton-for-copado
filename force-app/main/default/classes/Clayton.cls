global class Clayton extends Auth.AuthProviderPluginClass {
               
    public static final String RESOURCE_CALLBACK = '/services/authcallback/';

    public static final String METADATA_OBJ = 'clayton__Clayton_OAuth__mdt'; 

    public static final String METADATA_PROVIDER_NAME = 'clayton__ProviderName__c';
    public static final String METADATA_AUTHORIZE_URL = 'clayton__AuthorizeUrl__c	';
    public static final String METADATA_TOKEN_URL = 'clayton__TokenUrl__c';
    public static final String METADATA_CALLBACK_URL = 'clayton__CallbackUrl__c';
    public static final String METADATA_SCOPE = 'clayton__Scope__c';
    public static final String METADATA_CLIENT_ID = 'clayton__ClientId__c';
    public static final String METADATA_CLIENT_SECRET = 'clayton__ClientSecret__c';

    public static final String DEFAULT_AUTHORIZE_URL = 'https://app.clayton.io/oauth2/authorize';
    public static final String DEFAULT_TOKEN_URL = 'https://app.clayton.io/oauth2/token';

    global String getCustomMetadataType() {
        return METADATA_OBJ;
    }

    private String getCallbackUrl(Map<string,string> config) {
        final String generatedUrl = URL.getSalesforceBaseUrl().toExternalForm() + RESOURCE_CALLBACK + config.get(METADATA_PROVIDER_NAME);
        System.debug('Callback URL ' + generatedUrl);
        return getPropertyValue(config, METADATA_CALLBACK_URL, generatedUrl);
    }

    private String getPropertyValue(Map<string,string> config, String propertyName, String defaultValue) {
        final String propertyValue = config.get(propertyName);

        return String.isEmpty(propertyValue) ? defaultValue : propertyValue;
    }

    global PageReference initiate(Map<string,string> config, String stateToPropagate) {
        final PageReference pageRef = new PageReference(getPropertyValue(config, METADATA_AUTHORIZE_URL, DEFAULT_AUTHORIZE_URL));
        pageRef.getParameters().put('response_type','code');
        pageRef.getParameters().put('client_id',config.get(METADATA_CLIENT_ID));
        pageRef.getParameters().put('scope',config.get(METADATA_SCOPE));
        pageRef.getParameters().put('redirect_uri',getCallbackUrl(config));
        pageRef.getParameters().put('state',stateToPropagate);
        System.debug('Callback URL with parameters ' + pageRef.getUrl());
        return pageRef;
     }

    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> config, Auth.AuthProviderCallbackState state ) {
        final PageReference pageRef = new PageReference(getPropertyValue(config, METADATA_TOKEN_URL, DEFAULT_TOKEN_URL));
        pageRef.getParameters().put('grant_type','authorization_code');
        pageRef.getParameters().put('code',state.queryParameters.get('code'));
        pageRef.getParameters().put('client_id',config.get(METADATA_CLIENT_ID));
        pageRef.getParameters().put('redirect_uri',getCallbackUrl(config));
        System.debug('Token URL ' + pageRef.getUrl());

        Blob headerValue = Blob.valueOf(config.get(METADATA_CLIENT_ID) + ':' + config.get(METADATA_CLIENT_SECRET));
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(pageRef.getUrl());
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization',authorizationHeader);
        req.setMethod('POST');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        
        System.debug('Token Response Body: '+responseBody);
        System.debug('Token Response Status: ' + res.getStatus() + ' ' + res.getStatusCode());
        final TokenResponse tokenResponse = deserializeToken(responseBody);

        return new Auth.AuthProviderTokenResponse(config.get(METADATA_PROVIDER_NAME)
                                                  , tokenResponse.access_token
                                                  , tokenResponse.refresh_token
                                                  , state.queryParameters.get('state'));
     }

     public override Auth.OAuthRefreshResult refresh(Map<String,String> config, String refreshToken) {
        final PageReference pageRef = new PageReference(getPropertyValue(config, METADATA_TOKEN_URL, DEFAULT_TOKEN_URL));
        pageRef.getParameters().put('grant_type','refresh_token');
        pageRef.getParameters().put('refresh_token',refreshToken);
        pageRef.getParameters().put('client_id',config.get(METADATA_CLIENT_ID));
        pageRef.getParameters().put('client_secret',config.get(METADATA_CLIENT_SECRET));
        System.debug('Refresh Token URL ' + pageRef.getUrl());

        HttpRequest req = new HttpRequest();
        req.setEndpoint(pageRef.getUrl());
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        
        System.debug('Refresh Token Response Body: '+responseBody);
        System.debug('Refresh Token Response Status: ' + res.getStatus() + ' ' + res.getStatusCode());
        final TokenResponse tokenResponse = deserializeToken(responseBody);

        return new Auth.OAuthRefreshResult(tokenResponse.access_token, tokenResponse.refresh_token);
    }

      global Auth.UserData  getUserInfo(Map<string,string> config, Auth.AuthProviderTokenResponse response) { 
        final Auth.UserData userData = new Auth.UserData(
            config.get(METADATA_PROVIDER_NAME) // identifier
          , null // firstName
          , null // lastName
          , null // fullName
          , null // email
          , null // link
          , null // userName
          , null  //locale
          , config.get(METADATA_PROVIDER_NAME) //provider
          , null // siteLoginUrl
          , new Map<String,String>());


      return userData;
     }

    @testVisible
    private TokenResponse deserializeToken(String responseBody) {
        TokenResponse parsedResponse = (TokenResponse) System.JSON.deserialize(responseBody, TokenResponse.class);
        return parsedResponse;
    }

     public class TokenResponse {
        public String access_token {get;set;}
        public String refresh_token {get;set;}
        public String scope {get;set;}
        public String token_type {get;set;}
        public Integer expires_in {get;set;}
     }

}