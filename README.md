EM-Ripple
=========
Ripple is a peer-to-peer payment system. EM-Ripple is a client library for the
ripple public websocket API. Build trading bots, interfaces and utilities with it.

Usage
-----
After installing the gem 'em-ripple', require 'em-ripple' in your EventMachine program.
See the generated documentation (if you're using the source repository, run `rake doc` to
generate documentation) for callbacks.

Examples
--------
``
require 'eventmachine'
require 'em-ripple'

EM.run do

  # States and Flags
  permit_trading = false
  start_ledger_index = 0

  pending_orders = []

  # Caches

  order_books = Hash.new
  best_bid = Hash.new
  best_ask = Hash.new
  spread = Hash.new

  # Ripple Client Setup

  ripple = EMRipple::Ripple::Client.new(host: 's1.ripple.net', port: 443)
  boondaburra_wallet = ripple.open_wallet(name: 'boondaburra', password: 'foobar9000(yeah, nah. not the actual password mates)', blobvault: 'https://blobvault.payward.com')

  # this happens serially before other registered events fire
  # gives us the ability to set up caches and such
  ripple.on_rippled_connection do
    fill_order_book_caches
    resume_trading!
  end

  ripple.on_rippled_disconnect do
    halt_trading!
  end

  ripple.on_rippled_reconnection do
    fill_order_book_caches
    resume_trading!
  end

  # Rippled has disconnected from the ripple network
  ripple.on_network_disconnect do
    halt_trading!
  end

  # Rippled has reconnected to the ripple peer network
  ripple.on_network_reconnect do
    fill_order_book_caches
    resume_trading!
  end

  # Issuer Addresses
  bitstamp_ripple_address = 'rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B' # works a treat
  weexchange_ripple_address = 'r9vbV3EHvXWjSkeQ6CAcYVPGeq7TuiXY2dX' # NOT VERIFIED, EXAMPLE (also, with deliberate typo in case you don't read this)

  # Ensure Trading Wallet Limits are properly set for arbitrage trading

  boondaburra_wallet.trust_line.create(issuer: bitstamp_ripple_address, currency: 'usd', quantity: 15_000)
  boondaburra_wallet.trust_line.create(issuer: bitstamp_ripple_address, currency: 'btc', quantity: 1_000)
  boondaburra_wallet.trust_line.create(issuer: weexchange_ripple_address, currency: 'usd', quantity: 15_000)
  boondaburra_wallet.trust_line.create(issuer: weexchange_ripple_address, currency: 'btc', quantity: 1_000)

  # Arbitrage Bitstamp and WeExchange BTC/USD Order Books

  # Take/Make Liquidity
  bitstamp_btc_usd_order_book = ripple.order_book(from: 'BTC', to: 'USD', issuer: bitstamp_ripple_address)
  weexchange_btc_usd_order_book = ripple.order_book(from: 'BTC', to: 'USD', issuer: weexchange_ripple_address)

  # Cache management
  def fill_order_book_caches
    clear_order_book_caches

    start_ledger_index = ripple.in_one_ledger do

      # fill bitstamp btc/usd order book cache
      order_books[:bitstamp][:btc_usd][:bids] = bitstamp_btc_usd_order_book.bids
      order_books[:bitstamp][:btc_usd][:asks] = bitstamp_btc_usd_order_book.asks

      # fill weexchange btc/usd order book cache
      order_books[:weexchange][:btc_usd][:bids] = weexchange_btc_usd_order_book.bids
      order_books[:weexchange][:btc_usd][:asks] = weexchange_btc_usd_order_book.asks

    end
  end

  def clear_order_book_caches
    order_books[:bitstamp] = Hash.new
    order_books[:weexchange] = Hash.new

    order_books[:bitstamp][:btc_usd] = Hash.new
    order_books[:weexchange][:btc_usd] = Hash.new
  end

  def add_order_to_cache(exchange, currency, order_type, order)
    order_books[exchange][currency][order_type] << order
    recompute_exchange_currency_stats_on_order_change(exchange, currency)
  end

  def remove_order_from_cache(exchange, currency, order_type, order)
    order_books[exchange][currency][order_type] -= order
    recompute_exchange_currency_stats_on_order_change(exchange, currency)
  end

  def best_bid(exchange, currency)
    best_bid[exchange][currency]
  end

  def recompute_best_bid(exchange, currency)
    best_bid[exchange] ||= Hash.new
    best_bid[exchange][currency] = order_books[exchange][currency][:bids].max_by(&:price)
  end

  def best_ask(exchange, currency)
    best_ask[exchange][currency]
  end

  def recompute_best_ask(exchange, currency)
    best_ask[exchange] ||= Hash.new
    best_ask[exchange][currency] = order_books[exchange][currency][:asks].min_by(&:price)
  end

  def spread(exchange, currency)
    spread[exchange][currency]
  end

  def recompute_spread(exchange, currency)
    spread[exchange] ||= Hash.new
    spread[exchange][currency] = best_ask(exchange, currency) - best_bid(exchange_currency)
  end

  def recompute_exchange_stats_on_order_change(exchange, currency)
    recompute_best_bid(exchange, currency)
    recompute_best_ask(exchange, currency)
    recompute_spread(exchange, currency)
  end

  ##
  # Instrument exchange order books
  ##

  bitstamp_btc_usd_order_book.asks.when_created(from_ledger_index: start_ledger_index) do |ask|
    receive_order(:bitstamp, :btc_usd, :asks, ask)
  end

  bitstamp_btc_usd_order_book.asks.when_cancelled(from_ledger_index: start_ledger_index) do |ask|
    cancel_order(:bitstamp, :btc_usd, :asks, ask)
  end

  bitstamp_btc_usd_order_book.bids.when_created(from_ledger_index: start_ledger_index) do |bid|
    receive_order(:bitstamp, :btc_usd, :bids, bid)
  end

  bitstamp_btc_usd_order_book.bids.when_cancelled(from_ledger_index: start_ledger_index) do |bid|
    cancel_order(:bitstamp, :btc_usd, :bids, bid)
  end

  weexchange_btc_usd_order_book.asks.when_created(from_ledger_index: start_ledger_index) do |ask|
    receive_order(:weexchange, :btc_usd, :asks, ask)
  end

  weexchange_btc_usd_order_book.asks.when_cancelled(from_ledger_index: start_ledger_index) do |ask|
    cancel_order(:weexchange, :btc_usd, :asks, ask)
  end

  weexchange_btc_usd_order_book.bids.when_created(from_ledger_index: start_ledger_index) do |bid|
    receive_order(:weexchange, :btc_usd, :bids, bid)
  end

  weexchange_btc_usd_order_book.bids.when_cancelled(from_ledger_index: start_ledger_index) do |bid|
    cancel_order(:weexchange, :btc_usd, :bids, bid)
  end

  # Trading Management
  def halt_trading!
    permit_trading = false
  end

  def resume_trading!
    permit_trading = true
  end

  def add_order_to_pending_orders(order)
    pending_orders << order
  end

  def remove_order_from_pending_orders(order)
    pending_orders -= order
  end

  # @10Hz Check for pending orders and send to Rippled for network submission
  EM::PeriodicTimer.new(0.1) do

    # don't proceed unless trading is enabled
    return unless permit_trading

    pending_orders.each do |order|

      # don't process orders which have been committed
      next unless order.committed?

      # instrument order
      order.on_failure do |reason|
        inform_strategies_of_failed_order(order, reason)
        remove_order_from_pending_orders(order)
      end
      order.on_success do |transaction|
        inform_strategies_of_successful_order(order, transaction)
        remove_order_from_pending_orders(order)
      end

      # submit the order to the network via rippled
      order.commit!

    end

  end

  # Exchange Order Management

  def receive_order(exchange, currency, order_type, order)
    add_order_to_cache(exchange, currency, order_type, order)
    inform_strategies_of_new_offer(exchange, currency, order_type, order)
  end

  def cancel_order(exchange, currency, order_type, order)
    remove_order_from_cache(exchange, currency, order_type, order)
    inform_strategies_of_cancelled_order(exchange, currency, order_type, order)
  end

  def submit_order(exchange, currency, order_type, order)
    add_order_to_pending_orders(exchange, currency, order_type, order)
    order_pending!
  end

  def cancel_order(exchange, currency, order_type, order)
    if ripple.order.filled?(order)
      raise 'unable to cancel filled order'
    else
      add_order_to_pending_orders(exchange, currency, :cancellation, ripple.order.create_cancellation_order(order))
    end
  end

  # Trading Strategies

  def inform_strategies_of_new_offer(exchange, currency, order_type, order)
    reevaluate_market!
  end

  def inform_strategies_of_cancelled_order
    reevaluate_market!
  end

  def inform_strategies_of_failed_order(order, reason)
    reevaluate_market!
  end

  def inform_strategies_of_successful_order(order, transaction)
    reevaluate_market!
  end

  def reevaluate_market!
    EM.defer do
      take_bitstamp_liquidity if taking_bitstamp_liquidity_is_possible?
      take_weexchange_liquidity if taking_weexchange_liquidity_is_possible?
    end

    EM.defer do
      make_bitstamp_liquidity if making_bitstamp_liquidity_is_possible?
      make_weexchange_liquidity if making_weexchange_liquidity_is_possible?
    end
  end

  # Take liquidity
  def taking_bitstamp_liquidity_is_possible?
   bitstamp_btc_best_ask = best_ask(:bitstamp, :btc_usd)
   weexchange_btc_best_ask = best_ask(:weexchange, :btc_usd)

   bitstamp_btc_best_bid = best_bid(:bitstamp, :btc_usd)
   weexchange_btc_best_bid = best_bid(:weexchange, :btc_usd)

   bitstamp_btc_best_bid > weexchange_btc_best_bid
  end

  def taking_weexchange_liquidity_is_possible?
    bitstamp_btc_best_ask = best_ask(:bitstamp, :btc_usd)
    weexchange_btc_best_ask = best_ask(:weexchange, :btc_usd)

    bitstamp_btc_best_bid = best_bid(:bitstamp, :btc_usd)
    weexchange_btc_best_bid = best_bid(:weexchange, :btc_usd)

    bitstamp_btc_best_bid < weexchange_btc_best_bid
  end

  def take_bitstamp_liquidity
    # calculate quantities and prices
    submit_order(:weexchange ...)
  end

  def take_weexchange_liquidity
    ...
  end

  # Make liquidity
  ...

end
``


Security
--------
All messages to and from your peer are validated.
