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
 * custom fields are required. A honeypot field ("website_url2") blocks bots.
 */
@RestResource(urlMapping='/tc/intake')
global without sharing class TC_FormIntake {

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

        // Honeypot: real users never fill this hidden field. Pretend success.
        String honeypot = str(body.get('website_url2'));
        if (String.isNotBlank(honeypot)) {
            res.statusCode = 200;
            return new Result(true, 'Thank you for your submission!');
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

        Result r = new Result(true, 'Thank you for submitting your interest to the Technical Collective!');
        r.accountId = acc.Id;
        r.contactId = c.Id;
        res.statusCode = 200;
        return r;
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

        Result r = new Result(true, 'Thank you for submitting your interest to the Technical Collective!');
        r.contactId = c.Id;
        res.statusCode = 200;
        return r;
    }

    // ---- helpers -------------------------------------------------------------
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
