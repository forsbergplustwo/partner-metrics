# Partner Metrics

Partner Metrics is an open-source project providing you with metrics of your app, theme and affiliate revenue from the Shopify Partner program. Currently it calculates metrics based on the Payouts data from Shopify.

This project is not officially related to Shopify in any way.

*Disclaimer: IThis project was created over about a week in 2015 when I was new to programming. We've added a few features over the years and kept it running, but other than that it's kind of a time capsule. I am proud that it's proved so useful to so many over the years, but be warned.. there is still code in this repo that could be better organized and structured.*

## Usage

Partner Metrics was created by [@forsbergplustwo](@forsbergplustwo), and will remain free to use at:

##### https://partnermetrics.io

## Development

### Upgrading
```
bin/rails db:migrate
bin/rails db:encryption:init
bin/rails create_initial_import
bin/rails migrate_partner_api_credentials
```

To get started:

1. Setup dependencies, environment & database: `bin/setup`
2. Create and add credentials `bin/rails credentials:edit` (use config/credentials.sample.yml as template)
3. Start servers and sidekiq workers: `bin/dev`

Visit `localhost:4000`

To run tests:

```bash
bin/rails test

# including system tests

bin/rails test:all
```

## S3 - Minimum setup guide

### 1. Sign up for or login to [Amazon AWS](https://aws.amazon.com)
### 2. Create an S3 Bucket:
* In the AWS console, search for S3 and click the offering in the drop down menu.
* In the S3 Management Console, click the "Create Bucket" button.
* In the bucket creation wizard - name it something cool. (eg... "ice-bucket")
* Take note of the region your bucket is in. In my case I used the default presented ("us-east-2").
* Leave all other default settings alone. Click create to finalize the creation of the bucket.

### 2b. Allow CORS
* While looking at the individual bucket overview of the bucket you just created, click into the "Permissions" tab. Scroll down to "Cross-origin resource sharing (CORS)" and paste in the following:
```
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "HEAD",
            "POST",
            "PUT"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 3000
    }
]
```
Note: *Make sure to update the `AllowedOrigins` details above with your production app details, if your app is being made public.*

### 3. Create a user in IAM:
* Go back to the AWS console. This time search for IAM (Identity access management) and click it in the dropdown.
* Click "Add User"
* Name your user `Partner Metrics S3 User` (or something else if you'd like) and give it only programmatic access.
* On the next screen you'll set the permissions. Click the tab for "Attach Existing Policies Directly". Next, search for S3 and click the checkbox next to AmazonS3FullAccess.
* Leave all the other settings alone and create the new user.
* Take note of the access key ID and secret access key.


### 4. Add credentials to .env
* Go to your .env file and adjust the 4 AWS relevant definitions
```
S3_BUCKET=[aws bucket handle from step 2]
AWS_REGION=[aws bucket region from step 2]
AWS_ACCESS_KEY_ID=[access key id from step 3]
AWS_SECRET_ACCESS_KEY=[secret access key from step 3]
```
* Restart your server if running just to be safe.


## Contributing
We'd love for you to contribute join us in making it better!

The codebase could use some updates, so small PRs improving small things like code structure, readability and test of simple scenarios are more than welcome. It would be great to build up the test suite to make future development easier for everyone.

In general, please follow the "fork-and-pull" Git workflow.

1. Check out the Issues page, feel free to pick an existing issue or add a new one with clear title and description.
2. Fork and clone the repo on GitHub
3. Create a new branch for your fix or code improvement
4. Run `standardrb --fix` to safely-autofix any linter or formatter corrections
5. Commit changes to your own branch
6. Push your work back up to your fork
7. Submit a Pull request so that @forsbergplustwo can review your changes. Please link your PR to the existing issue if you are solving one.

## Testing
We have a handful of MiniTests and Fixtures in the codebase, and welcome more. Please write MiniTests for new code you create.

## Code of Conduct
Everyone interacting in Partner Metrics repository is expected to follow the [Code of Conduct](https://github.com/forsbergplustwo/partner-metrics-saas/blob/main/CODE_OF_CONDUCT.md).

## License

Partner Metrics is released under the [GPLv3 License](https://github.com/forsbergplustwo/partner-metrics-saas/blob/main/LICENSE.md).
