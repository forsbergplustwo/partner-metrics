# Partner Metrics

Partner Metrics is an open-source project providing you with metrics of your app, theme and affiliate revenue from the Shopify Partner program. Currently it calculates metrics based on the Payouts data from Shopify.

This project is not officially related to Shopify in any way.

*Disclaimer: IThis project was created over about a week in 2015 when I was new to programming. We've added a few features over the years and kept it running, but other than that it's kind of a time capsule. I am proud that it's proved so useful to so many over the years, but be warned.. there is still code in this repo that could be better organized and structured.*

## Usage

Partner Metrics was created by [@forsbergplustwo](@forsbergplustwo), and will remain free to use at:

##### https://partnermetrics.io

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

*Note: As uploads use S3, you'll need to add details to the .env file for them to work. Alternatively, [replace S3 with ActiveStorage](https://github.com/forsbergplustwo/partner-metrics/issues/20).*

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
