@IsTest 
public class ClaytonTest { 

    private static final String OAUTH_TOKEN = 'testToken'; 
    private static final String STATE = 'mocktestState'; 
    private static final String REFRESH_TOKEN = 'refreshToken'; 
    private static final String PROVIDER_NAME = 'Clayton'; 
    private static final String SCOPE = 'testScope'; 
    private static final String CLIENT_ID = 'testClientId'; 
    private static final String CLIENT_SECRET = 'testClientSecret'; 
    private static final String STATE_TO_PROPOGATE = 'testState'; 
    private static final String AUTHORIZE_URL = 'https://app.clayton.io/oauth2/authorize'; 
    private static final String TOKEN_URL = 'https://app.clayton.io/oauth2/token'; 
    private static final String CALLBACK_URL = 'http://localhost/services/authcallback/orgId/Clayton'; 
    private static final String API_USER_URL = 'www.concursolutions.com/user/api'; 


    public static final String METADATA_PROVIDER_NAME = 'clayton__ProviderName__c';
    public static final String METADATA_AUTHORIZE_URL = 'clayton__AuthorizeUrl__c	';
    public static final String METADATA_TOKEN_URL = 'clayton__TokenUrl__c';
    public static final String METADATA_CALLBACK_URL = 'clayton__CallbackUrl__c';
    public static final String METADATA_SCOPE = 'clayton__Scope__c';
    public static final String METADATA_CLIENT_ID = 'clayton__ClientId__c';
    public static final String METADATA_CLIENT_SECRET = 'clayton__ClientSecret__c';

    private static Map<String,String> setupAuthProviderConfig () 
    { 
        Map<String,String> authProviderConfiguration = new Map<String,String>(); 
        authProviderConfiguration.put(METADATA_PROVIDER_NAME, PROVIDER_NAME);
        authProviderConfiguration.put(METADATA_CLIENT_ID, CLIENT_ID); 
        authProviderConfiguration.put(METADATA_CLIENT_SECRET, CLIENT_SECRET); 
        authProviderConfiguration.put(METADATA_AUTHORIZE_URL, AUTHORIZE_URL); 
        authProviderConfiguration.put(METADATA_TOKEN_URL, TOKEN_URL); 
        authProviderConfiguration.put(METADATA_CALLBACK_URL,CALLBACK_URL); 
        authProviderConfiguration.put(METADATA_SCOPE,SCOPE); 
        return authProviderConfiguration; 
    
    } 
    
    @isTest
    public static void testInitiateMethod() 
    { 
        String stateToPropogate = 'mocktestState'; 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        Clayton claytonProviderAuth = new Clayton(); 

        final PageReference expectedUrl = new PageReference(authProviderConfiguration.get(METADATA_AUTHORIZE_URL));
        expectedUrl.getParameters().put('response_type','code');
        expectedUrl.getParameters().put('client_id',authProviderConfiguration.get(METADATA_CLIENT_ID));
        expectedUrl.getParameters().put('scope',authProviderConfiguration.get(METADATA_SCOPE));
        expectedUrl.getParameters().put('redirect_uri',authProviderConfiguration.get(METADATA_CALLBACK_URL));
        expectedUrl.getParameters().put('state',STATE_TO_PROPOGATE);

        PageReference actualUrl = claytonProviderAuth.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
    } 

    @isTest
    public static void testHandleCallback() 
    { 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        Clayton claytonProviderAuth = new Clayton(); 

        Test.setMock(HttpCalloutMock.class, new ClaytonMockHttpResponseGenerator()); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',STATE_TO_PROPOGATE); 
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        Auth.AuthProviderTokenResponse actualAuthProvResponse = claytonProviderAuth.handleCallback(authProviderConfiguration, cbState); 
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse('Clayton', OAUTH_TOKEN, REFRESH_TOKEN, STATE_TO_PROPOGATE); 
    
        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider); 
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken); 
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken); 
        System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state); 

    } 

    @isTest
    public static void testGetUserInfo() 
    { 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        Clayton claytonProviderAuth = new Clayton(); 

        Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(PROVIDER_NAME, OAUTH_TOKEN ,'sampleOauthSecret', STATE_TO_PROPOGATE); 
        Auth.UserData actualUserData = claytonProviderAuth.getUserInfo(authProviderConfiguration, response) ; 
        Auth.UserData expectedUserData = new Auth.UserData(
            authProviderConfiguration.get(METADATA_PROVIDER_NAME) // identifier
          , null // firstName
          , null // lastName
          , null // fullName
          , null // email
          , null // link
          , null // userName
          , null  //locale
          , authProviderConfiguration.get(METADATA_PROVIDER_NAME) //provider
          , null // siteLoginUrl
          , new Map<String,String>());
    
        System.assertNotEquals(expectedUserData,null); 
        System.assertEquals(expectedUserData.firstName, actualUserData.firstName); 
        System.assertEquals(expectedUserData.lastName, actualUserData.lastName); 
        System.assertEquals(expectedUserData.fullName, actualUserData.fullName); 
        System.assertEquals(expectedUserData.email, actualUserData.email); 
        System.assertEquals(expectedUserData.username, actualUserData.username); 
        System.assertEquals(expectedUserData.locale, actualUserData.locale); 
        System.assertEquals(expectedUserData.provider, actualUserData.provider); 
        System.assertEquals(expectedUserData.siteLoginUrl, actualUserData.siteLoginUrl); 
    } 

    public class ClaytonMockHttpResponseGenerator implements HttpCalloutMock 
    { 

        public HTTPResponse respond(HTTPRequest req) 
        { 
            String body = '{"access_token": "'+OAUTH_TOKEN+'","refresh_token":"'+REFRESH_TOKEN+'"}';
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            res.setBody(body); 
            res.setStatusCode(200); 
            return res; 
        } 
    
    } 
}