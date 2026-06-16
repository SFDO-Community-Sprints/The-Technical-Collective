/**
 * Tests for TC_FormIntake. Exercises successful charity and professional
 * submissions plus the abuse controls around public anonymous intake.
 */
@IsTest
private class TC_FormIntakeTest {

    private static final String DEFAULT_CLIENT_KEY = '198.51.100.10';

    private static TC_FormIntake.Result invoke(Map<String, Object> body) {
        return invoke(body, DEFAULT_CLIENT_KEY, true);
    }

    private static TC_FormIntake.Result invoke(Map<String, Object> body, String clientKey, Boolean addElapsedMs) {
        Map<String, Object> payload = new Map<String, Object>(body);
        if (addElapsedMs && !payload.containsKey('elapsedMs')) {
            payload.put('elapsedMs', 9000);
        }

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/tc/intake';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        TC_FormIntake.testClientKey = clientKey;
        return TC_FormIntake.submit();
    }

    private static Map<String, Object> charityPayload(String email) {
        return new Map<String, Object>{
            'formType' => 'charity',
            'organisationName' => 'Helping Hands',
            'firstName' => 'Ada',
            'lastName' => 'Lovelace',
            'email' => email,
            'phone' => '+44 20 7946 0000',
            'roleAtOrg' => 'Operations Lead',
            'websiteUrl' => 'https://helpinghands.org',
            'headOfficeAddress' => '1 Charity Way, London',
            'mission' => 'Feed the community',
            'languages' => new List<Object>{ 'English', 'French' },
            'powerOfUs' => 'Yes'
        };
    }

    private static Map<String, Object> professionalPayload(String email) {
        return new Map<String, Object>{
            'formType' => 'professional',
            'firstName' => 'Grace',
            'lastName' => 'Hopper',
            'email' => email,
            'companyName' => 'None',
            'experienceLevel' => '6+',
            'salesforceRole' => 'Developer',
            'productsSupported' => new List<Object>{ 'Sales Cloud', 'NPSP / Nonprofit Cloud' }
        };
    }

    @IsTest
    static void charity_ShouldCreateRecordsWithoutReturningIds_WhenValidSubmission() {
        Test.startTest();
        TC_FormIntake.Result result = invoke(charityPayload('ada@helpinghands.org'));
        Test.stopTest();

        Assert.isTrue(result.success, 'Valid charity submission should be accepted.');
        Assert.areEqual(null, result.accountId, 'Anonymous responses must not expose Account Ids.');
        Assert.areEqual(null, result.contactId, 'Anonymous responses must not expose Contact Ids.');

        Account account = [
            SELECT Id, Name, Website, Description
            FROM Account
            WHERE Name = 'Helping Hands'
            LIMIT 1
        ];
        Assert.areEqual('Helping Hands', account.Name, 'Charity submission should create the Account.');
        Assert.isTrue(
            account.Description.contains('Charity mission: Feed the community'),
            'Description should include the submitted mission.'
        );
        Assert.isTrue(
            account.Description.contains('Preferred working languages: English, French'),
            'Description should include multi-select values.'
        );

        Contact contact = [
            SELECT FirstName, LastName, Email, AccountId, Title
            FROM Contact
            WHERE Email = 'ada@helpinghands.org'
            LIMIT 1
        ];
        Assert.areEqual('Lovelace', contact.LastName, 'Charity Contact should preserve the submitted last name.');
        Assert.areEqual(account.Id, contact.AccountId, 'Charity Contact should be linked to the created Account.');
        Assert.areEqual('Operations Lead', contact.Title, 'Charity Contact should preserve the role title.');
    }

    @IsTest
    static void professional_ShouldCreateContactWithoutReturningId_WhenValidSubmission() {
        Test.startTest();
        TC_FormIntake.Result result = invoke(professionalPayload('grace@example.com'));
        Test.stopTest();

        Assert.isTrue(result.success, 'Valid professional submission should be accepted.');
        Assert.areEqual(null, result.contactId, 'Anonymous responses must not expose Contact Ids.');

        Contact contact = [
            SELECT LastName, Email, Description
            FROM Contact
            WHERE Email = 'grace@example.com'
            LIMIT 1
        ];
        Assert.areEqual('Hopper', contact.LastName, 'Professional Contact should preserve the submitted name.');
        Assert.isTrue(contact.Description.contains('Company name: None'), 'Description should include company name.');
        Assert.isTrue(
            contact.Description.contains('Products willing to support: Sales Cloud, NPSP / Nonprofit Cloud'),
            'Description should include selected products.'
        );
    }

    @IsTest
    static void charity_ShouldReject_WhenRequiredFieldsMissing() {
        TC_FormIntake.Result result = invoke(new Map<String, Object>{
            'formType' => 'charity',
            'organisationName' => 'X'
        });
        Assert.isFalse(result.success, 'Missing required charity fields should fail validation.');
    }

    @IsTest
    static void professional_ShouldReject_WhenEmailInvalid() {
        TC_FormIntake.Result result = invoke(new Map<String, Object>{
            'formType' => 'professional',
            'lastName' => 'Hopper',
            'email' => 'not-an-email'
        });
        Assert.isFalse(result.success, 'Invalid email should fail validation.');
    }

    @IsTest
    static void honeypot_ShouldReturnAcceptedWithoutCreatingRecord_WhenFilled() {
        Integer beforeCount = [SELECT COUNT() FROM Contact];

        TC_FormIntake.Result result = invoke(new Map<String, Object>{
            'formType' => 'professional',
            'lastName' => 'Bot',
            'email' => 'bot@example.com',
            'website_url2' => 'http://spam.example'
        });

        Assert.isTrue(result.success, 'Honeypot submissions should receive a generic accepted response.');
        Assert.areEqual(beforeCount, [SELECT COUNT() FROM Contact], 'Honeypot submissions must not create records.');
    }

    @IsTest
    static void timingTrap_ShouldReturnAcceptedWithoutCreatingRecord_WhenTooFast() {
        Integer beforeCount = [SELECT COUNT() FROM Contact];

        TC_FormIntake.Result result = invoke(new Map<String, Object>{
            'formType' => 'professional',
            'lastName' => 'Speedy',
            'email' => 'fast@example.com',
            'elapsedMs' => 200
        }, DEFAULT_CLIENT_KEY, false);

        Assert.isTrue(result.success, 'Too-fast submissions should receive a generic accepted response.');
        Assert.areEqual(beforeCount, [SELECT COUNT() FROM Contact], 'Too-fast submissions must not create records.');
    }

    @IsTest
    static void timingTrap_ShouldReturnAcceptedWithoutCreatingRecord_WhenMissing() {
        Integer beforeCount = [SELECT COUNT() FROM Contact];

        TC_FormIntake.Result result = invoke(professionalPayload('missing-elapsed@example.com'), DEFAULT_CLIENT_KEY, false);

        Assert.isTrue(result.success, 'Missing elapsedMs should receive a generic accepted response.');
        Assert.areEqual(beforeCount, [SELECT COUNT() FROM Contact], 'Missing elapsedMs must not create records.');
    }

    @IsTest
    static void timingTrap_ShouldReturnAcceptedWithoutCreatingRecord_WhenMalformed() {
        Map<String, Object> payload = professionalPayload('bad-elapsed@example.com');
        payload.put('elapsedMs', 'not-a-number');
        Integer beforeCount = [SELECT COUNT() FROM Contact];

        TC_FormIntake.Result result = invoke(payload, DEFAULT_CLIENT_KEY, false);

        Assert.isTrue(result.success, 'Malformed elapsedMs should receive a generic accepted response.');
        Assert.areEqual(beforeCount, [SELECT COUNT() FROM Contact], 'Malformed elapsedMs must not create records.');
    }

    @IsTest
    static void dedupe_ShouldUseSameResponseShape_WhenEmailRecentlySubmitted() {
        Map<String, Object> payload = professionalPayload('twice@example.com');

        Test.startTest();
        TC_FormIntake.Result first = invoke(payload, '198.51.100.20', true);
        TC_FormIntake.Result second = invoke(payload, '198.51.100.20', true);
        Test.stopTest();

        Assert.isTrue(first.success, 'First submission should be accepted.');
        Assert.isTrue(second.success, 'Duplicate submission should be accepted-looking.');
        Assert.areEqual(first.message, second.message, 'Duplicate response must match fresh success response.');
        Assert.areEqual(null, first.contactId, 'Fresh response must not expose Contact Id.');
        Assert.areEqual(null, second.contactId, 'Duplicate response must not expose Contact Id.');
        Assert.areEqual(
            1,
            [SELECT COUNT() FROM Contact WHERE Email = 'twice@example.com'],
            'Duplicate submission should not create another Contact.'
        );
    }

    @IsTest
    static void rateLimit_ShouldReturnAcceptedWithoutCreatingRecords_WhenClientExceedsWindow() {
        String clientKey = '198.51.100.30';

        Test.startTest();
        for (Integer i = 0; i < TC_FormIntake.MAX_SUBMISSIONS_PER_CLIENT + 1; i++) {
            TC_FormIntake.Result result = invoke(professionalPayload('rate-' + i + '@example.com'), clientKey, true);
            Assert.isTrue(result.success, 'Rate-limited submissions should not reveal rejection.');
        }
        Test.stopTest();

        Assert.areEqual(
            TC_FormIntake.MAX_SUBMISSIONS_PER_CLIENT,
            [SELECT COUNT() FROM Contact WHERE Email LIKE 'rate-%'],
            'Only submissions inside the per-client window should create Contacts.'
        );
    }

    @IsTest
    static void unknownType_ShouldFail() {
        TC_FormIntake.Result result = invoke(new Map<String, Object>{ 'formType' => 'nope' });
        Assert.isFalse(result.success, 'Unknown form type should fail validation.');
    }

    @IsTest
    static void emptyBody_ShouldFail() {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        TC_FormIntake.Result result = TC_FormIntake.submit();

        Assert.isFalse(result.success, 'Empty request body should fail validation.');
    }
}
