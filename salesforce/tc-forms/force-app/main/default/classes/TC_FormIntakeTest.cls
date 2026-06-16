/**
 * Tests for TC_FormIntake. Exercises charity + professional happy paths,
 * validation failures, the honeypot, and bad input.
 */
@IsTest
private class TC_FormIntakeTest {

    private static TC_FormIntake.Result invoke(Map<String, Object> body) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/tc/intake';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        return TC_FormIntake.submit();
    }

    @IsTest
    static void charity_createsAccountAndContact() {
        Map<String, Object> b = new Map<String, Object>{
            'formType' => 'charity',
            'organisationName' => 'Helping Hands',
            'firstName' => 'Ada',
            'lastName' => 'Lovelace',
            'email' => 'ada@helpinghands.org',
            'phone' => '+44 20 7946 0000',
            'roleAtOrg' => 'Operations Lead',
            'websiteUrl' => 'https://helpinghands.org',
            'headOfficeAddress' => '1 Charity Way, London',
            'mission' => 'Feed the community',
            'languages' => new List<Object>{ 'English', 'French' },
            'powerOfUs' => 'Yes'
        };
        Test.startTest();
        TC_FormIntake.Result r = invoke(b);
        Test.stopTest();

        System.assertEquals(true, r.success, r.message);
        System.assertNotEquals(null, r.accountId);
        System.assertNotEquals(null, r.contactId);

        Account a = [SELECT Name, Website, Description FROM Account WHERE Id = :r.accountId];
        System.assertEquals('Helping Hands', a.Name);
        System.assert(a.Description.contains('Charity mission: Feed the community'));
        System.assert(a.Description.contains('Preferred working languages: English, French'));

        Contact c = [SELECT FirstName, LastName, Email, AccountId, Title FROM Contact WHERE Id = :r.contactId];
        System.assertEquals('Lovelace', c.LastName);
        System.assertEquals(r.accountId, c.AccountId);
        System.assertEquals('Operations Lead', c.Title);
    }

    @IsTest
    static void professional_createsContact() {
        Map<String, Object> b = new Map<String, Object>{
            'formType' => 'professional',
            'firstName' => 'Grace',
            'lastName' => 'Hopper',
            'email' => 'grace@example.com',
            'companyName' => 'None',
            'experienceLevel' => '6+',
            'salesforceRole' => 'Developer',
            'productsSupported' => new List<Object>{ 'Sales Cloud', 'NPSP / Nonprofit Cloud' }
        };
        Test.startTest();
        TC_FormIntake.Result r = invoke(b);
        Test.stopTest();

        System.assertEquals(true, r.success, r.message);
        System.assertNotEquals(null, r.contactId);
        Contact c = [SELECT LastName, Email, Description FROM Contact WHERE Id = :r.contactId];
        System.assertEquals('Hopper', c.LastName);
        System.assert(c.Description.contains('Company name: None'));
        System.assert(c.Description.contains('Products willing to support: Sales Cloud, NPSP / Nonprofit Cloud'));
    }

    @IsTest
    static void charity_missingRequired_fails() {
        TC_FormIntake.Result r = invoke(new Map<String, Object>{
            'formType' => 'charity', 'organisationName' => 'X'  // no lastName/email
        });
        System.assertEquals(false, r.success);
    }

    @IsTest
    static void professional_invalidEmail_fails() {
        TC_FormIntake.Result r = invoke(new Map<String, Object>{
            'formType' => 'professional', 'lastName' => 'Hopper', 'email' => 'not-an-email'
        });
        System.assertEquals(false, r.success);
    }

    @IsTest
    static void honeypot_silentlySucceedsWithoutRecord() {
        Integer before = [SELECT COUNT() FROM Contact];
        TC_FormIntake.Result r = invoke(new Map<String, Object>{
            'formType' => 'professional', 'lastName' => 'Bot', 'email' => 'bot@x.com',
            'website_url2' => 'http://spam.example'
        });
        System.assertEquals(true, r.success);
        System.assertEquals(before, [SELECT COUNT() FROM Contact]);
    }

    @IsTest
    static void timingTrap_tooFast_dropsRecord() {
        Integer before = [SELECT COUNT() FROM Contact];
        TC_FormIntake.Result r = invoke(new Map<String, Object>{
            'formType' => 'professional', 'lastName' => 'Speedy', 'email' => 'fast@example.com',
            'elapsedMs' => 200   // way under the 2500ms threshold -> treated as a bot
        });
        System.assertEquals(true, r.success);                       // looks successful to the bot
        System.assertEquals(before, [SELECT COUNT() FROM Contact]); // but nothing was created
    }

    @IsTest
    static void timingTrap_humanSpeed_succeeds() {
        TC_FormIntake.Result r = invoke(new Map<String, Object>{
            'formType' => 'professional', 'lastName' => 'Human', 'email' => 'human@example.com',
            'elapsedMs' => 9000
        });
        System.assertEquals(true, r.success, r.message);
        System.assertNotEquals(null, r.contactId);
    }

    @IsTest
    static void dedupe_sameEmailWithinWindow_skipsSecondInsert() {
        Map<String, Object> b = new Map<String, Object>{
            'formType' => 'professional', 'lastName' => 'Twice', 'email' => 'twice@example.com'
        };
        Test.startTest();
        TC_FormIntake.Result first  = invoke(b);
        TC_FormIntake.Result second = invoke(b);   // same email again
        Test.stopTest();

        System.assertEquals(true, first.success);
        System.assertNotEquals(null, first.contactId);
        System.assertEquals(true, second.success);          // still looks successful
        System.assertEquals(null, second.contactId);        // but no new record
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'twice@example.com']);
    }

    @IsTest
    static void unknownType_fails() {
        TC_FormIntake.Result r = invoke(new Map<String, Object>{ 'formType' => 'nope' });
        System.assertEquals(false, r.success);
    }

    @IsTest
    static void emptyBody_fails() {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        TC_FormIntake.Result r = TC_FormIntake.submit();
        System.assertEquals(false, r.success);
    }
}
