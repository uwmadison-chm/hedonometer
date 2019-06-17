# LinkSurvey support

A LinkSurvey is one where the participant responds via a website (for example, 
Qualtrics survey) instead of via text message.

They are sent a text message with a link that works for 30 minutes (by 
default) and then expires. If they click it in time, it forwards them to the 
Qualtrics URL (or any other URL of your choosing).

Currently, the only replacements supported in the URL are `{{PID}}` and 
`{{SMID}}`.

## Qualtrics linking

To use a Qualtrics survey, you need to get your participant IDs into the 
Qualtrics data. Here's the recipe!

### In Qualtrics:

If you already have embedded data in your Qualtrics survey, skip to 4.

1. Go to Survey Flow on the Survey tab in Qualtrics
2. Click Add a New Element Here
3. Set Embedded Data
4. Create New Field, name it "PID"
5. Create New Field, name it "SMID"
6. Save Flow
7. Go to Distributions tab and choose Anonymous Link.
   Copy and paste the link (which will look like
   https://uwmadison.c01.qualtrics.com/...)

### In hedonometer:

1. Go to /admin
2. Click Edit on your survey if you already have a LinkSurvey,
   or click Create a survey and then choose LinkSurvey.
3. Paste the qualtrics link from above into the Url field.
   At the end, add `?PID={{PID}}&SMID={{SMID}}`. This is the
   magic sauce so that hedonometer will send the participant
   external key and scheduled message id through to Qualtrics.

## End of survey

After the participant is done, if you redirect to a permanent URL, they won't 
be confused by an extra window. We recommend you redirect to:

https://webtasks.keck.waisman.wisc.edu/h2/r/complete

1. Go to Survey Options in the Survey tab.
2. Scroll down to Survey Termination.
3. Choose "Redirect to a full URL" and paste in the above URL.


