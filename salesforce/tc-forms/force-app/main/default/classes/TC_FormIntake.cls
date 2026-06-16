/**
 * TC_FormIntake
 * Public REST endpoint for The Technical Collective sign-up forms.
 *
 * Exposed through a Salesforce Site and called by the (static) website forms.
 *   POST /services/apexrest/tc/intake
 *
 * Two form types, distinguished by the JSON "formType":
 *   - "charity"      -> creates an Account (the organisation) + a primary Contact
 *   - "professional" -> creates a Contact
 *
 * Core fields map to standard fields; every other questionnaire answer is
 * written as a clean, labelled block in the record's Description field, so no
 * custom fields are required. Server-side abuse controls limit automated use.
 */
@RestResource(urlMapping='/tc/intake')
global without sharing class TC_FormIntake {

    private static final String ACCEPTED_MESSAGE = 'Thank you for submitting your interest to the Technical Collective!';
    // Submissions completed faster than this (milliseconds) are treated as bots.
    private static final Decimal MIN_ELAPSED_MS = 2500;
    // Submissions claiming an implausibly old rendered form are also dropped.
    private static final Decimal MAX_ELAPSED_MS = 7200000;
    // A given email may only create one record within this window (hours).
    private static final Integer DEDUPE_WINDOW_HOURS = 24;
    private static final Integer RATE_LIMIT_WINDOW_SECONDS = 3600;
    @TestVisible private static final Integer MAX_SUBMISSIONS_PER_CLIENT = 5;
    @TestVisible private static Map<String, Integer> testRateLimitCounts = new Map<String, Integer>();
    @TestVisible private static String testClientKey;

    // ---- response shape ------------------------------------------------------
    global class Result {
        global Boolean success;
        global String message;
        global String accountId;
        global String contactId;
        global Result(Boolean s, String m) { this.success = s; this.message = m; }
    }

    @HttpPost
    global static Result submit() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        Map<String, Object> body;
        try {
            String raw = RestContext.request.requestBody != null
                ? RestContext.request.requestBody.toString() : '';
            body = (Map<String, Object>) JSON.deserializeUntyped(raw);
        } catch (Exception e) {
            res.statusCode = 400;
            return new Result(false, 'Invalid request.');
        }
        if (body == null) {
            res.statusCode = 400;
            return new Result(false, 'Empty request.');
        }

        if (!passesSubmissionGuards(body, res)) {
            return accepted(res);
        }

        String formType = str(body.get('formType')).toLowerCase();
        try {
            if (formType == 'charity') {
                return handleCharity(body, res);
            } else if (formType == 'professional') {
                return handleProfessional(body, res);
            } else {
                res.statusCode = 400;
                return new Result(false, 'Unknown form type.');
            }
        } catch (Exception e) {
            res.statusCode = 500;
            return new Result(false, 'We could not save your submission. Please try again later.');
        }
    }

    // ---- charity: Account + Contact -----------------------------------------
    private static Result handleCharity(Map<String, Object> b, RestResponse res) {
        String orgName   = str(b.get('organisationName'));
        String firstName = str(b.get('firstName'));
        String lastName  = str(b.get('lastName'));
        String email     = str(b.get('email'));

        if (String.isBlank(orgName) || String.isBlank(lastName) || String.isBlank(email)) {
            res.statusCode = 400;
            return new Result(false, 'Please complete the required fields.');
        }
        if (!looksLikeEmail(email)) {
            res.statusCode = 400;
            return new Result(false, 'Please enter a valid email address.');
        }
        if (!allowClientSubmission(res)) {
            return accepted(res);
        }
        // Dedupe: this email already applied recently -> look successful, skip insert.
        if (recentlySubmitted(email)) {
            return accepted(res);
        }

        Account acc = new Account();
        acc.Name = orgName;
        putIf(acc, 'Website', str(b.get('websiteUrl')));
        putIf(acc, 'Phone', str(b.get('phone')));
        setBillingAddress(acc, str(b.get('headOfficeAddress')));
        acc.Description = buildBlock(new List<String[]>{
            new String[]{ 'Business goal(s) for partnership', str(b.get('businessGoals')) },
            new String[]{ 'Charity mission', str(b.get('mission')) },
            new String[]{ 'Organisation size (staff)', str(b.get('orgSize')) },
            new String[]{ 'Countries worked in', str(b.get('countries')) },
            new String[]{ 'Preferred working languages', str(b.get('languages')) },
            new String[]{ 'Best/worst time of year for a project', str(b.get('timing')) },
            new String[]{ 'Anything else about the charity', str(b.get('charityOther')) },
            new String[]{ 'Currently using Salesforce?', str(b.get('usingSalesforce')) },
            new String[]{ 'What Salesforce is used for', str(b.get('salesforceUsage')) },
            new String[]{ 'Power of Us 10 free licenses?', str(b.get('powerOfUs')) },
            new String[]{ 'Total Salesforce licenses', str(b.get('licensesTotal')) },
            new String[]{ 'Available Salesforce licenses', str(b.get('licensesAvailable')) },
            new String[]{ 'Existing Salesforce products', str(b.get('existingProducts')) },
            new String[]{ 'Current integrations', str(b.get('integrations')) },
            new String[]{ 'Uses a sandbox?', str(b.get('usesSandbox')) },
            new String[]{ 'Has system documentation?', str(b.get('hasDocumentation')) },
            new String[]{ 'Has Salesforce support (internal/external)?', str(b.get('hasSupport')) },
            new String[]{ 'Internal support detail', str(b.get('internalSupport')) },
            new String[]{ 'External support detail', str(b.get('externalSupport')) },
            new String[]{ 'Top pain points', str(b.get('painPoints')) },
            new String[]{ 'What works well today', str(b.get('worksWell')) },
            new String[]{ 'Project identified or need help?', str(b.get('projectIdentified')) },
            new String[]{ 'Staff available to work with us', str(b.get('staffAvailable')) },
            new String[]{ 'Time team has to work with us', str(b.get('timeAvailable')) },
            new String[]{ 'Other helpful information', str(b.get('otherInfo')) },
            new String[]{ 'Comms opt-in', str(b.get('optIn')) }
        });
        insert acc;

        Contact c = new Contact();
        c.AccountId = acc.Id;
        c.FirstName = firstName;
        c.LastName  = String.isNotBlank(lastName) ? lastName : orgName;
        c.Email     = email;
        putIf(c, 'Phone', str(b.get('phone')));
        putIf(c, 'Title', str(b.get('roleAtOrg')));
        insert c;

        return accepted(res);
    }

    // ---- professional: Contact ----------------------------------------------
    private static Result handleProfessional(Map<String, Object> b, RestResponse res) {
        String firstName = str(b.get('firstName'));
        String lastName  = str(b.get('lastName'));
        String email     = str(b.get('email'));

        if (String.isBlank(lastName) || String.isBlank(email)) {
            res.statusCode = 400;
            return new Result(false, 'Please complete the required fields.');
        }
        if (!looksLikeEmail(email)) {
            res.statusCode = 400;
            return new Result(false, 'Please enter a valid email address.');
        }
        if (!allowClientSubmission(res)) {
            return accepted(res);
        }
        // Dedupe: this email already applied recently -> look successful, skip insert.
        if (recentlySubmitted(email)) {
            return accepted(res);
        }

        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName  = lastName;
        c.Email     = email;
        putIf(c, 'Phone', str(b.get('phone')));
        setMailingAddress(c, str(b.get('address')));
        // Company name on a Contact has no standard home; keep it in the block.
        c.Description = buildBlock(new List<String[]>{
            new String[]{ 'Company name', str(b.get('companyName')) },
            new String[]{ 'Languages spoken', str(b.get('languages')) },
            new String[]{ 'Motivation for volunteering', str(b.get('motivation')) },
            new String[]{ 'Has nonprofit/charity Salesforce experience?', str(b.get('nonprofitExperience')) },
            new String[]{ 'Salesforce experience level', str(b.get('experienceLevel')) },
            new String[]{ 'Salesforce certifications held', str(b.get('certifications')) },
            new String[]{ 'Trailhead profile', str(b.get('trailheadUrl')) },
            new String[]{ 'LinkedIn profile', str(b.get('linkedinUrl')) },
            new String[]{ 'Commitment / availability', str(b.get('commitment')) },
            new String[]{ 'Availability timeframe', str(b.get('availabilityTimeframe')) },
            new String[]{ 'Salesforce role', str(b.get('salesforceRole')) },
            new String[]{ 'Products willing to support', str(b.get('productsSupported')) }
        });
        insert c;

        return accepted(res);
    }

    // ---- helpers -------------------------------------------------------------
    private static Result accepted(RestResponse res) {
        res.statusCode = 200;
        return new Result(true, ACCEPTED_MESSAGE);
    }

    private static Boolean passesSubmissionGuards(Map<String, Object> body, RestResponse res) {
        String honeypot = str(body.get('website_url2'));
        if (String.isNotBlank(honeypot)) {
            res.statusCode = 200;
            return false;
        }

        Object elapsedRaw = body.get('elapsedMs');
        if (elapsedRaw == null) {
            res.statusCode = 200;
            return false;
        }

        try {
            Decimal elapsed = Decimal.valueOf(String.valueOf(elapsedRaw));
            if (elapsed < MIN_ELAPSED_MS || elapsed > MAX_ELAPSED_MS) {
                res.statusCode = 200;
                return false;
            }
        } catch (Exception e) {
            res.statusCode = 200;
            return false;
        }
        return true;
    }

    private static Boolean allowClientSubmission(RestResponse res) {
        String clientKey = clientRateLimitKey();
        if (String.isBlank(clientKey)) {
            res.statusCode = 200;
            return false;
        }
        if (Test.isRunningTest()) {
            Integer count = testRateLimitCounts.containsKey(clientKey) ? testRateLimitCounts.get(clientKey) : 0;
            count++;
            testRateLimitCounts.put(clientKey, count);
            return count <= MAX_SUBMISSIONS_PER_CLIENT;
        }

        String cacheKey = 'tc_form_intake_' + EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(clientKey))
        );
        try {
            Object rawCount = Cache.Org.get(cacheKey);
            Integer count = rawCount == null ? 0 : Integer.valueOf(String.valueOf(rawCount));
            count++;
            Cache.Org.put(cacheKey, count, RATE_LIMIT_WINDOW_SECONDS);
            return count <= MAX_SUBMISSIONS_PER_CLIENT;
        } catch (Exception e) {
            res.statusCode = 200;
            return false;
        }
    }

    private static String clientRateLimitKey() {
        if (Test.isRunningTest() && String.isNotBlank(testClientKey)) {
            return testClientKey;
        }
        RestRequest req = RestContext.request;
        if (req == null) return '';
        if (String.isNotBlank(req.remoteAddress)) return req.remoteAddress;

        List<String> headerNames = new List<String>{
            'True-Client-IP', 'CF-Connecting-IP', 'X-Salesforce-SIP', 'X-Forwarded-For'
        };
        for (String headerName : headerNames) {
            String value = req.headers != null ? req.headers.get(headerName) : null;
            if (String.isBlank(value)) continue;
            return value.split(',')[0].trim();
        }
        return '';
    }

    private static String str(Object o) {
        if (o == null) return '';
        if (o instanceof List<Object>) {
            List<String> parts = new List<String>();
            for (Object item : (List<Object>) o) parts.add(String.valueOf(item));
            return String.join(parts, ', ');
        }
        return String.valueOf(o).trim();
    }

    private static Boolean looksLikeEmail(String e) {
        return String.isNotBlank(e) && Pattern.matches('^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$', e);
    }

    // True if a Contact with this email was created within the dedupe window.
    // Limits the same address (or a bot replaying one payload) to one record.
    private static Boolean recentlySubmitted(String email) {
        if (String.isBlank(email)) return false;
        Datetime cutoff = Datetime.now().addHours(-DEDUPE_WINDOW_HOURS);
        return [
            SELECT COUNT()
            FROM Contact
            WHERE Email = :email AND CreatedDate >= :cutoff
        ] > 0;
    }

    // Set a field only when there's a value, and trim to the field's max length.
    private static void putIf(SObject rec, String field, String val) {
        if (String.isBlank(val)) return;
        Integer max = rec.getSObjectType().getDescribe().fields.getMap()
            .get(field).getDescribe().getLength();
        rec.put(field, val.length() > max ? val.substring(0, max) : val);
    }

    private static void setBillingAddress(Account a, String addr) {
        if (String.isBlank(addr)) return;
        a.BillingStreet = addr.length() > 255 ? addr.substring(0, 255) : addr;
    }
    private static void setMailingAddress(Contact c, String addr) {
        if (String.isBlank(addr)) return;
        c.MailingStreet = addr.length() > 255 ? addr.substring(0, 255) : addr;
    }

    // Build a labelled "Question: Answer" block, skipping blank answers.
    private static String buildBlock(List<String[]> pairs) {
        List<String> lines = new List<String>();
        for (String[] p : pairs) {
            if (String.isNotBlank(p[1])) lines.add(p[0] + ': ' + p[1]);
        }
        String block = String.join(lines, '\n');
        return block.length() > 32000 ? block.substring(0, 32000) : block;
    }
}
