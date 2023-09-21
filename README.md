# Partner Metrics

Partner Metrics is an open-source project providing you with metrics of your app, theme and affiliate revenue from the Shopify Partner program. Currently it calculates metrics based on monthly and yearly subscriptions, one-time charges and usage charges from Shopify.

This project is not officially related to Shopify in any way.

## Usage

Partner Metrics was created by [@forsbergplustwo](@forsbergplustwo), and will remain free to use at:

##### https://partnermetrics.io

## Development

### Upgrading

The app in this repo was recently upgraded to Rails 7. If you had the earlier version running locally, you can upgrade by performing the following actions on your existing local app:

```
bin/rails db:migrate
bin/rails db:encryption:init
bin/rails create_initial_imports
bin/rails migrate_partner_api_credentials
```

Note: We recommend deleting your existing metrics data and re-importing to take advantage of improvements to churn calculations + yearly subscriptions support.

### First time setup

1. Rename `.env.example` to `.env` and update redis path if needed.
1. Delete `config/credentials.yml.enc`
2. Create and add your own credentials `bin/rails credentials:edit` (use config/credentials.example.yml as template)
3. Setup encrypted attributes support: `bin/rails db:encryption:init` and add to credentials
4. Setup dependencies, environment & database: `bin/setup`
5. Start web server and sidekiq workers with: `bin/dev`

Visit `localhost:4000`

To run tests:

```bash
bin/rails test

# including system tests
bin/rails test:all
```

## Contributing
We'd love for you to contribute join us in making it better! In general, please follow the "fork-and-pull" Git workflow.

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
