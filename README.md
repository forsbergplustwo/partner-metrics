# Partner Metrics

Partner Metrics provides an easy way to see useful metrics of your apps, themes and affiliate revenue from the Shopify Partner program. Currently Parnter Metrics provides metrics calculated on the Payouts data from Shopify, meaning we can see revenue related details.

## Usage

Parnter Metrics is hosted by @forsbergplustwo and free to use at:

https://partnermetrics.io

## Development

To get started:

1. Install dependencies: `bundle install`
2. Setup environment: Rename `.env.example` to `.env` and add details
3. Setup database: `bin/rake db:create && bin/rake db:migrate`
4. Start servers and background workers: `bin/dev`

Visit `localhost:4000`

To run tests:

```bash
bin/rake
```

## Contributing
We'd love for you to contribute to Partner Metrics, join us in making it better!

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

Parnter Metrics is released under the [GPLv3 License](https://github.com/forsbergplustwo/partner-metrics-saas/blob/main/LICENSE.md).
