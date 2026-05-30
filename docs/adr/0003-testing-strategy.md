# Testing strategy: seeds + inline setup, Minitest, rendered Phlex views

We use Minitest (Rails default) with seeds loaded once for the sticker catalog (994 rows). Test users are created inline using the real DumpParser + CollectionImporter — no factories gem.

For clipboard/copy assertions, we render Phlex views to HTML strings via `.call`, parse with Nokogiri, and extract `data-clipboard-text-value` attributes. This tests the actual user-facing output without coupling to private methods.

Integration tests cover happy-path page loads and routing. Service unit tests cover parsers, TradeComparer, and CollectionImporter with varied inputs and edge cases.

We chose this over FactoryBot because the domain has few models and the real parsers serve as natural setup helpers — exercising them in tests is a bonus, not overhead.
