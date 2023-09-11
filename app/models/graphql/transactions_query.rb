require "shopify_partner_api"

Graphql::TransactionsQuery = ShopifyPartnerAPI.client.parse <<~GRAPHQL
  query($createdAtMin: DateTime, $cursor: String, $first: Integer) {
    transactions(createdAtMin: $createdAtMin, after: $cursor, first: $first) {
      edges {
        cursor
        node {
          id,
          createdAt,
          # Apps
          ... on AppSubscriptionSale {
            netAmount {
              amount
            },
            app {
              name
            },
            shop {
              myshopifyDomain
            }
          },
          ... on AppOneTimeSale {
            netAmount {
              amount
            },
            app {
              name
            },
            shop {
              myshopifyDomain
            }
          },
          ... on AppSaleAdjustment {
            netAmount {
              amount
            },
            app {
              name
            },
            shop {
              myshopifyDomain
            }
          },
          ... on AppSaleCredit {
            netAmount {
              amount
            },
            app {
              name
            },
            shop {
              myshopifyDomain
            }
          },
          ... on AppUsageSale {
            netAmount {
              amount
            },
            app {
              name
            },
            shop {
              myshopifyDomain
            }
          },
          # skipped LegacyTransaction, not sure what it is
          ... on ReferralAdjustment {
            amount {
              amount
            },
            shop {
              myshopifyDomain
            }
          },
          ... on ReferralTransaction {
            amount {
              amount
            },
            shopNonNullable: shop {
              myshopifyDomain
            }
          },
          ... on ServiceSale {
            netAmount {
              amount
            },
            shop {
              myshopifyDomain
            }
          },
          ... on ServiceSaleAdjustment {
            netAmount {
              amount
            },
            shop {
              myshopifyDomain
            }
          },
          # skipped TaxTransaction
          ... on ThemeSale {
            netAmount {
              amount
            },
            theme {
              name # may not match CSV import behaviour
            },
            shop {
              myshopifyDomain
            }
          },
          ... on ThemeSaleAdjustment {
            netAmount {
              amount
            },
            theme {
              name # may not match CSV import behaviour
            },
            shop {
              myshopifyDomain
            }
          },
        }
      },
      pageInfo {
          hasNextPage
      }
    }
  }
GRAPHQL
