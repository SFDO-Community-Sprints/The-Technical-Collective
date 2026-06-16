/* =============================================================================
   TC application forms — data-driven renderer.

   Builds the Charity and Professional sign-up forms, posts them to the
   Technical Collective Salesforce Site endpoint, then shows a thank-you and
   redirects the user back to where they were.

   Usage on a page:
     <div data-tc-form="charity"        data-redirect="charity-nonprofit.html"></div>
     <div data-tc-form="professional"   data-redirect="junior-professional.html"></div>
   and include this script. No other markup needed.
   ============================================================================= */
(function () {
  'use strict';

  // Public Salesforce Site endpoint (guest user creates Account/Contact).
  var ENDPOINT = 'https://technicalcollective.my.salesforce-sites.com/forms/services/apexrest/tc/intake';

  // ---- field definitions ----------------------------------------------------
  // type: text | email | tel | url | textarea | select | checkboxes | radios
  var CHARITY = {
    title: 'Interest form for charities',
    intro: 'Tell us about your organisation and your Salesforce setup. Fields marked * are required.',
    sections: [
      { heading: 'About you', fields: [
        { name: 'organisationName', label: 'Organisation name', type: 'text', required: true },
        { name: 'firstName', label: 'First name', type: 'text', required: true },
        { name: 'lastName',  label: 'Surname',    type: 'text', required: true },
        { name: 'roleAtOrg', label: 'Title / role at organisation', type: 'text' },
        { name: 'email', label: 'Email', type: 'email', required: true },
        { name: 'phone', label: 'Phone number', type: 'tel' },
        { name: 'headOfficeAddress', label: 'Head office address', type: 'textarea' },
        { name: 'websiteUrl', label: 'Website URL', type: 'url' },
        { name: 'optIn', label: 'Communications', type: 'checkboxes', options: [
          'I opt in to be contacted by the Technical Collective and to have my data stored and processed on Salesforce, Slack and Google.' ] }
      ]},
      { heading: 'About your organisation', fields: [
        { name: 'businessGoals', label: 'What specific business goal(s) are you hoping to address through this partnership?', type: 'textarea' },
        { name: 'mission', label: "What is your charity's mission?", type: 'textarea' },
        { name: 'orgSize', label: 'Size of your organisation (how many staff)', type: 'text' },
        { name: 'countries', label: 'What countries do you currently work in?', type: 'text' },
        { name: 'languages', label: 'What languages do you prefer working in?', type: 'text' },
        { name: 'timing', label: 'Best time of year to run a project? Any times off limits?', type: 'textarea' },
        { name: 'charityOther', label: 'Anything else we should know about your charity?', type: 'textarea' }
      ]},
      { heading: 'Your Salesforce configuration', fields: [
        { name: 'usingSalesforce', label: 'Are you currently using Salesforce? If not, what are you using?', type: 'textarea' },
        { name: 'salesforceUsage', label: 'What are you using Salesforce for? (fundraising, case management, etc.)', type: 'textarea' },
        { name: 'powerOfUs', label: 'Do you have the 10 free licenses through the Power of Us programme?', type: 'radios',
          required: true, options: ['Yes', 'No', "Not sure or we don't have Salesforce yet"] },
        { name: 'licensesTotal', label: 'How many Salesforce licenses do you have total?', type: 'text' },
        { name: 'licensesAvailable', label: 'How many Salesforce licenses do you have available?', type: 'text' },
        { name: 'existingProducts', label: 'What existing Salesforce products are you using? (NPSP, Nonprofit Cloud, Sales Cloud…)', type: 'textarea' },
        { name: 'integrations', label: 'What integrations are you currently using, if any?', type: 'textarea' },
        { name: 'usesSandbox', label: 'Do you use a Salesforce sandbox for updates and testing?', type: 'radios', options: ['Yes', 'No', 'Unsure'] },
        { name: 'hasDocumentation', label: 'Do you have system documentation?', type: 'text' },
        { name: 'hasSupport', label: 'Do you currently have Salesforce support, internally or externally?', type: 'radios', options: ['Yes', 'No', 'Some'] },
        { name: 'internalSupport', label: 'Internal support: team size, capacity, who maintains your platform?', type: 'textarea' },
        { name: 'externalSupport', label: 'External support: partners or consulting firms currently working with you?', type: 'textarea' }
      ]},
      { heading: 'Your goals and project needs', fields: [
        { name: 'painPoints', label: 'Top pain points you think Salesforce can help solve?', type: 'textarea' },
        { name: 'worksWell', label: 'What is working well with your Salesforce platform?', type: 'textarea' },
        { name: 'projectIdentified', label: 'Do you have a project identified, or need help identifying one?', type: 'textarea' },
        { name: 'staffAvailable', label: 'How many people on your staff are available to work with us?', type: 'text' },
        { name: 'timeAvailable', label: 'How much time does your team have to work with us?', type: 'text' },
        { name: 'otherInfo', label: 'Any other information that would be helpful?', type: 'textarea' }
      ]}
    ]
  };

  var PROFESSIONAL = {
    title: 'Sign-up form for Salesforce professionals',
    intro: 'Please provide your contact information and credentials. Fields marked * are required.',
    sections: [
      { heading: 'Your details', fields: [
        { name: 'firstName', label: 'First name', type: 'text', required: true },
        { name: 'lastName',  label: 'Last name',  type: 'text', required: true },
        { name: 'address',   label: 'Address',    type: 'textarea', required: true },
        { name: 'companyName', label: 'Company name', type: 'text', required: true, help: "If not currently with a company, write 'None'." },
        { name: 'email', label: 'Email address', type: 'email', required: true },
        { name: 'phone', label: 'Phone number', type: 'tel' },
        { name: 'languages', label: 'What languages do you speak?', type: 'checkboxes', options: ['English', 'French', 'Italian', 'Other'] }
      ]},
      { heading: 'Your experience', fields: [
        { name: 'motivation', label: 'What is your motivation for volunteering?', type: 'textarea' },
        { name: 'nonprofitExperience', label: 'Do you have Salesforce nonprofit / charity experience?', type: 'radios', options: ['Yes', 'No'] },
        { name: 'experienceLevel', label: 'How much Salesforce experience do you have?', type: 'radios',
          options: ['None — I am a newbie', '1–2 years', '3–5 years', '6+ years'] },
        { name: 'certifications', label: 'Which Salesforce certifications do you hold?', type: 'textarea' },
        { name: 'trailheadUrl', label: 'Trailhead profile link', type: 'url' },
        { name: 'linkedinUrl', label: 'LinkedIn profile link', type: 'url' }
      ]},
      { heading: 'Availability & focus', fields: [
        { name: 'commitment', label: 'Commitment / availability', type: 'radios',
          options: ['1–5 hours per week', '6–10 hours per week', 'More than 10 hours per week'] },
        { name: 'availabilityTimeframe', label: 'Availability timeframe (start date / end date)', type: 'text' },
        { name: 'salesforceRole', label: 'Salesforce role', type: 'radios',
          options: ['Admin', 'Developer', 'Architect', 'Business Analyst', 'Marketer', 'Other'] },
        { name: 'productsSupported', label: 'Salesforce products you are willing to support', type: 'checkboxes',
          help: 'New professionals: what you would like to support as part of your project.',
          options: ['Sales Cloud', 'Service Cloud', 'NPSP / Nonprofit Cloud', 'Experience Cloud',
                    'Marketing Cloud', 'Marketing Cloud Account Engagement (Pardot)', 'Mulesoft', 'Other'] }
      ]}
    ]
  };

  var FORMS = { charity: CHARITY, professional: PROFESSIONAL };

  // ---- helpers ---------------------------------------------------------------
  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  var uid = 0;
  function fieldId() { uid += 1; return 'tcf_' + uid; }

  var inputBase = 'mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-slate-800 ' +
                  'focus:border-brand focus:ring-2 focus:ring-brand/30 focus:outline-none';

  function renderField(f) {
    var id = fieldId();
    var req = f.required ? ' <span class="text-rose-500">*</span>' : '';
    var help = f.help ? '<p class="mt-1 text-xs text-slate-500">' + esc(f.help) + '</p>' : '';
    var label = '<label for="' + id + '" class="block text-sm font-medium text-slate-700">' + esc(f.label) + req + '</label>';
    var ctrl = '';

    if (f.type === 'textarea') {
      ctrl = '<textarea id="' + id + '" name="' + esc(f.name) + '" rows="3" class="' + inputBase + '"' +
             (f.required ? ' required' : '') + '></textarea>';
    } else if (f.type === 'select') {
      ctrl = '<select id="' + id + '" name="' + esc(f.name) + '" class="' + inputBase + '"' + (f.required ? ' required' : '') + '>' +
             '<option value="">Please choose…</option>' +
             f.options.map(function (o) { return '<option>' + esc(o) + '</option>'; }).join('') + '</select>';
    } else if (f.type === 'radios' || f.type === 'checkboxes') {
      var inputType = f.type === 'radios' ? 'radio' : 'checkbox';
      ctrl = '<div class="mt-2 space-y-1.5">' + f.options.map(function (o) {
        return '<label class="flex items-start gap-2 text-sm text-slate-700">' +
          '<input type="' + inputType + '" name="' + esc(f.name) + '" value="' + esc(o) + '" ' +
          'class="mt-0.5 rounded border-slate-300 text-brand focus:ring-brand/30"' + (f.required && inputType === 'radio' ? ' required' : '') + '>' +
          '<span>' + esc(o) + '</span></label>';
      }).join('') + '</div>';
      // radios/checkboxes: label sits above without "for"
      label = '<span class="block text-sm font-medium text-slate-700">' + esc(f.label) + req + '</span>';
    } else {
      ctrl = '<input id="' + id + '" name="' + esc(f.name) + '" type="' + esc(f.type) + '" class="' + inputBase + '"' +
             (f.required ? ' required' : '') + '>';
    }
    return '<div>' + label + ctrl + help + '</div>';
  }

  function renderForm(def) {
    var sections = def.sections.map(function (s) {
      var fields = s.fields.map(renderField).join('');
      return '<fieldset class="space-y-4">' +
        '<legend class="text-base font-bold text-slate-900 border-b border-slate-200 pb-2 mb-4 w-full">' + esc(s.heading) + '</legend>' +
        '<div class="grid sm:grid-cols-2 gap-x-5 gap-y-4">' + fields + '</div></fieldset>';
    }).join('<div class="h-6"></div>');

    return '<form novalidate class="space-y-7">' +
      // honeypot — hidden from real users
      '<div aria-hidden="true" style="position:absolute;left:-9999px;top:-9999px;" tabindex="-1">' +
      '<label>Website<input type="text" name="website_url2" tabindex="-1" autocomplete="off"></label></div>' +
      sections +
      '<div data-form-error class="hidden rounded-lg bg-rose-50 border border-rose-200 text-rose-700 text-sm px-4 py-3"></div>' +
      '<div class="flex items-center gap-3">' +
        '<button type="submit" class="px-7 py-3 rounded-xl bg-brand text-white font-semibold hover:bg-brand-dark transition disabled:opacity-60 disabled:cursor-not-allowed">Submit application</button>' +
        '<span data-form-busy class="hidden text-sm text-slate-500">Submitting…</span>' +
      '</div></form>';
  }

  // Collect values; checkboxes/multi -> arrays.
  function collect(form) {
    var data = {};
    var els = form.querySelectorAll('input, textarea, select');
    els.forEach(function (el) {
      if (!el.name) return;
      if (el.type === 'checkbox') {
        if (el.checked) { (data[el.name] = data[el.name] || []).push(el.value); }
      } else if (el.type === 'radio') {
        if (el.checked) data[el.name] = el.value;
      } else {
        data[el.name] = el.value;
      }
    });
    return data;
  }

  function mount(host) {
    var type = host.getAttribute('data-tc-form');
    var def = FORMS[type];
    if (!def) return;
    var redirect = host.getAttribute('data-redirect') || '';

    host.innerHTML =
      '<div data-form-stage>' +
        '<h3 class="text-xl font-bold text-slate-900">' + esc(def.title) + '</h3>' +
        '<p class="mt-1 text-sm text-slate-600">' + esc(def.intro) + '</p>' +
        '<div class="mt-6">' + renderForm(def) + '</div>' +
      '</div>' +
      '<div data-thanks-stage class="hidden text-center py-10">' +
        '<div class="mx-auto h-14 w-14 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center">' +
          '<svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>' +
        '</div>' +
        '<h3 class="mt-5 text-2xl font-bold text-slate-900">Thank you!</h3>' +
        '<p class="mt-2 text-slate-600">Thank you for submitting your interest to the Technical Collective. We’ll be in touch.</p>' +
        '<p data-redirect-note class="mt-4 text-sm text-slate-400"></p>' +
      '</div>';

    var form = host.querySelector('form');
    var formStage = host.querySelector('[data-form-stage]');
    var thanksStage = host.querySelector('[data-thanks-stage]');
    var errBox = host.querySelector('[data-form-error]');
    var busy = host.querySelector('[data-form-busy]');
    var submitBtn = form.querySelector('button[type="submit"]');

    // Spam timing trap: record when the form became available; the elapsed time
    // is sent on submit so the server can drop instant (bot) submissions.
    var renderedAt = Date.now();

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      errBox.classList.add('hidden');

      // Native validation for required fields.
      if (!form.checkValidity()) {
        form.reportValidity();
        return;
      }

      var payload = collect(form);
      payload.formType = type;
      payload.elapsedMs = Date.now() - renderedAt;

      submitBtn.disabled = true;
      busy.classList.remove('hidden');

      fetch(ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).then(function (r) {
        return r.json().then(function (j) { return { ok: r.ok, body: j }; });
      }).then(function (res) {
        if (res.ok && res.body && res.body.success) {
          // Show thank-you, then redirect back to the page they were on.
          formStage.classList.add('hidden');
          thanksStage.classList.remove('hidden');
          if (redirect) {
            var note = host.querySelector('[data-redirect-note]');
            var secs = 4;
            note.textContent = 'Returning to the page in ' + secs + 's…';
            var tick = setInterval(function () {
              secs -= 1;
              note.textContent = secs > 0 ? 'Returning to the page in ' + secs + 's…' : 'Redirecting…';
              if (secs <= 0) { clearInterval(tick); window.location.href = redirect; }
            }, 1000);
          }
        } else {
          throw new Error((res.body && res.body.message) || 'Submission failed.');
        }
      }).catch(function (err) {
        errBox.textContent = err.message || 'Something went wrong. Please try again, or email techcollectiveproject@gmail.com.';
        errBox.classList.remove('hidden');
      }).then(function () {
        submitBtn.disabled = false;
        busy.classList.add('hidden');
      });
    });
  }

  function init() {
    document.querySelectorAll('[data-tc-form]').forEach(mount);
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else { init(); }
})();
